import Vision

/// 골반 전방경사 / 후방경사 판정
/// 측정: 어깨-엉덩이-무릎 세 점 각도
/// 임계값: 175~185 정상, 170~175 / 185~190 주의, 그 바깥 의심
final class AnteriorPelvicTiltEvaluator: PostureEvaluator {

    let type: PostureType = .anteriorPelvicTilt
    let requiredView: SessionView = .side

    private let thresholds = Thresholds(
        normalRange: 175...185,
        cautionRange: 170...190,   // 정상 범위 바깥 + caution 범위 안 = caution
        direction: .centeredOnRange
    )

    func evaluate(_ frame: PoseFrame) -> PostureResult {
        let leftJoints: [VNHumanBodyPoseObservation.JointName] = [.leftShoulder, .leftHip, .leftKnee]
        let rightJoints: [VNHumanBodyPoseObservation.JointName] = [.rightShoulder, .rightHip, .rightKnee]

        let leftReliable = frame.areReliable(leftJoints)
        let rightReliable = frame.areReliable(rightJoints)

        guard leftReliable || rightReliable else {
            return .unmeasurable(type: .anteriorPelvicTilt, reason: "어깨·엉덩이·무릎 관절 인식 부족")
        }

        let leftConf = leftReliable ? frame.averageConfidence(leftJoints) : 0
        let rightConf = rightReliable ? frame.averageConfidence(rightJoints) : 0
        let useRight = rightConf > leftConf
        let joints = useRight ? rightJoints : leftJoints

        guard let shoulder = frame.point(joints[0]),
              let hip = frame.point(joints[1]),
              let knee = frame.point(joints[2]) else {
            return .unmeasurable(type: .anteriorPelvicTilt, reason: "관절 좌표 누락")
        }

        let angle = GeometryMath.angleBetween(p1: shoulder, vertex: hip, p2: knee)
        let status = thresholds.evaluate(angle)

        let direction: String
        if angle < 175 { direction = "전방경사 경향" }
        else if angle > 185 { direction = "후방경사 경향" }
        else { direction = "" }

        return PostureResult(
            type: .anteriorPelvicTilt,
            status: status,
            primaryMetric: angle,
            primaryMetricUnit: .degree,
            thresholds: thresholds,
            usedJointNames: joints.map { $0.rawValue.rawValue },
            confidence: useRight ? rightConf : leftConf,
            advice: status == .normal ? nil : "\(direction). 코어 강화와 골반 정렬 운동을 권장합니다."
        )
    }
}
