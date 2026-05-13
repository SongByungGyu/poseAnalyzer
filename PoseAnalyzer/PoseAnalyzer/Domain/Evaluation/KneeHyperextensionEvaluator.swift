import Vision

/// 무릎 과신전 (Knee Hyperextension) 판정
/// 측정: 엉덩이-무릎-발목 각도
/// 임계값: ≤185 정상, 185~190 주의, >190 의심 (한 방향 — 과신전만 평가)
final class KneeHyperextensionEvaluator: PostureEvaluator {

    let type: PostureType = .kneeHyperextension
    let requiredView: SessionView = .side

    private let thresholds = Thresholds(
        normalRange: 0...185,
        cautionRange: 185...190,
        direction: .higherIsNormal
    )

    func evaluate(_ frame: PoseFrame) -> PostureResult {
        let leftJoints: [VNHumanBodyPoseObservation.JointName] = [.leftHip, .leftKnee, .leftAnkle]
        let rightJoints: [VNHumanBodyPoseObservation.JointName] = [.rightHip, .rightKnee, .rightAnkle]

        let leftReliable = frame.areReliable(leftJoints)
        let rightReliable = frame.areReliable(rightJoints)

        guard leftReliable || rightReliable else {
            return .unmeasurable(type: .kneeHyperextension, reason: "엉덩이·무릎·발목 관절 인식 부족")
        }

        let leftConf = leftReliable ? frame.averageConfidence(leftJoints) : 0
        let rightConf = rightReliable ? frame.averageConfidence(rightJoints) : 0
        let useRight = rightConf > leftConf
        let joints = useRight ? rightJoints : leftJoints

        guard let hip = frame.point(joints[0]),
              let knee = frame.point(joints[1]),
              let ankle = frame.point(joints[2]) else {
            return .unmeasurable(type: .kneeHyperextension, reason: "관절 좌표 누락")
        }

        let rawAngle = GeometryMath.angleBetween(p1: hip, vertex: knee, p2: ankle)
        // 과신전(>180°) 방향 감지: 무릎이 엉덩이-발목 라인의 어느 쪽에 있는지를
        // hip→knee, knee→ankle 외적 부호로 판별. 음수이면 과신전 방향으로 간주.
        let cross =
            (Double(knee.x - hip.x) * Double(ankle.y - knee.y)) -
            (Double(knee.y - hip.y) * Double(ankle.x - knee.x))
        let angle = cross < 0 ? (360.0 - rawAngle) : rawAngle
        let status = thresholds.evaluate(angle)

        return PostureResult(
            type: .kneeHyperextension,
            status: status,
            primaryMetric: angle,
            primaryMetricUnit: .degree,
            thresholds: thresholds,
            usedJointNames: joints.map { $0.rawValue.rawValue },
            confidence: useRight ? rightConf : leftConf,
            advice: status == .normal ? nil : "서 있을 때 무릎을 살짝 굽혀 정렬을 유지해보세요."
        )
    }
}
