import Vision

/// 흉추 후만증 (Kyphosis) — 등 위쪽 굽음 판정
/// 측정: 목-어깨-엉덩이 세 점 각도
/// 임계값: ≥175° 정상, 165~175° 주의, <165° 의심
final class KyphosisEvaluator: PostureEvaluator {

    let type: PostureType = .kyphosis
    let requiredView: SessionView = .side

    private let thresholds = Thresholds(
        normalRange: 175...360,
        cautionRange: 165...175,
        direction: .higherIsNormal
    )

    func evaluate(_ frame: PoseFrame) -> PostureResult {
        let leftJoints: [VNHumanBodyPoseObservation.JointName] = [.neck, .leftShoulder, .leftHip]
        let rightJoints: [VNHumanBodyPoseObservation.JointName] = [.neck, .rightShoulder, .rightHip]

        let leftReliable = frame.areReliable(leftJoints)
        let rightReliable = frame.areReliable(rightJoints)

        guard leftReliable || rightReliable else {
            return .unmeasurable(type: .kyphosis, reason: "목·어깨·엉덩이 관절 인식 부족")
        }

        let leftConf = leftReliable ? frame.averageConfidence(leftJoints) : 0
        let rightConf = rightReliable ? frame.averageConfidence(rightJoints) : 0
        let useRight = rightConf > leftConf
        let joints = useRight ? rightJoints : leftJoints

        guard let neck = frame.point(joints[0]),
              let shoulder = frame.point(joints[1]),
              let hip = frame.point(joints[2]) else {
            return .unmeasurable(type: .kyphosis, reason: "관절 좌표 누락")
        }

        let angle = GeometryMath.angleBetween(p1: neck, vertex: shoulder, p2: hip)
        let status = thresholds.evaluate(angle)

        return PostureResult(
            type: .kyphosis,
            status: status,
            primaryMetric: angle,
            primaryMetricUnit: .degree,
            thresholds: thresholds,
            usedJointNames: joints.map { $0.rawValue.rawValue },
            confidence: useRight ? rightConf : leftConf,
            advice: status == .normal ? nil : "흉추 신전 스트레칭(폼롤러)을 권장합니다."
        )
    }
}
