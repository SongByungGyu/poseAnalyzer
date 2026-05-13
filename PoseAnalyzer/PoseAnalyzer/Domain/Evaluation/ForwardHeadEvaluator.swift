import Vision

/// 거북목 (Forward Head Posture) 판정
/// 측정: 귀-어깨-엉덩이 세 점이 이루는 각도
/// 임계값: 정상 ≥170°, 주의 160~170°, 의심 <170° (의심은 normalRange/cautionRange 둘 다 벗어남)
final class ForwardHeadEvaluator: PostureEvaluator {

    let type: PostureType = .forwardHead
    let requiredView: SessionView = .side

    private let thresholds = Thresholds(
        normalRange: 170...360,        // 170 이상 정상 (수학적으로 180까지)
        cautionRange: 160...170,
        direction: .higherIsNormal
    )

    func evaluate(_ frame: PoseFrame) -> PostureResult {
        // 좌/우 측 중 신뢰도 높은 쪽 자동 선택
        let leftJoints: [VNHumanBodyPoseObservation.JointName] = [.leftEar, .leftShoulder, .leftHip]
        let rightJoints: [VNHumanBodyPoseObservation.JointName] = [.rightEar, .rightShoulder, .rightHip]

        let leftReliable = frame.areReliable(leftJoints)
        let rightReliable = frame.areReliable(rightJoints)

        guard leftReliable || rightReliable else {
            return .unmeasurable(type: .forwardHead, reason: "측면 귀·어깨·엉덩이 관절 인식 부족")
        }

        let leftConf = leftReliable ? frame.averageConfidence(leftJoints) : 0
        let rightConf = rightReliable ? frame.averageConfidence(rightJoints) : 0

        let useRight = rightConf > leftConf
        let joints = useRight ? rightJoints : leftJoints

        guard let ear = frame.point(joints[0]),
              let shoulder = frame.point(joints[1]),
              let hip = frame.point(joints[2]) else {
            return .unmeasurable(type: .forwardHead, reason: "관절 좌표 누락")
        }

        let angle = GeometryMath.angleBetween(p1: ear, vertex: shoulder, p2: hip)
        let status = thresholds.evaluate(angle)

        return PostureResult(
            type: .forwardHead,
            status: status,
            primaryMetric: angle,
            primaryMetricUnit: .degree,
            thresholds: thresholds,
            usedJointNames: joints.map { $0.rawValue.rawValue },
            confidence: useRight ? rightConf : leftConf,
            advice: status == .normal ? nil : "장시간 고개를 숙이지 마시고, 모니터 높이를 눈높이로 맞춰주세요."
        )
    }
}
