import Vision

/// 라운드숄더 (Round Shoulder) 판정
/// 측정: 측면 사진에서 어깨가 귀보다 얼마나 앞에 있는지 (수평 거리 / 어깨 폭 비율)
/// 임계값: < 0.15 정상, 0.15~0.25 주의, > 0.25 의심
final class RoundShoulderEvaluator: PostureEvaluator {

    let type: PostureType = .roundShoulder
    let requiredView: SessionView = .side

    private let thresholds = Thresholds(
        normalRange: 0...0.15,
        cautionRange: 0.15...0.25,
        direction: .lowerIsNormal
    )

    func evaluate(_ frame: PoseFrame) -> PostureResult {
        // 어깨 폭 기준 잡기: leftShoulder ~ rightShoulder 거리
        guard let leftShoulder = frame.point(.leftShoulder),
              let rightShoulder = frame.point(.rightShoulder) else {
            return .unmeasurable(type: .roundShoulder, reason: "어깨 관절 인식 부족")
        }
        let shoulderWidth = GeometryMath.distance(leftShoulder, rightShoulder)
        guard shoulderWidth > 0.01 else {
            return .unmeasurable(type: .roundShoulder, reason: "어깨 폭 측정 실패")
        }

        // 좌/우 측 중 confidence 높은 쪽 사용 (귀-어깨)
        let leftReliable = frame.areReliable([.leftEar, .leftShoulder])
        let rightReliable = frame.areReliable([.rightEar, .rightShoulder])

        guard leftReliable || rightReliable else {
            return .unmeasurable(type: .roundShoulder, reason: "귀·어깨 관절 신뢰도 부족")
        }

        let leftConf = leftReliable ? frame.averageConfidence([.leftEar, .leftShoulder]) : 0
        let rightConf = rightReliable ? frame.averageConfidence([.rightEar, .rightShoulder]) : 0
        let useRight = rightConf > leftConf

        let earName: VNHumanBodyPoseObservation.JointName = useRight ? .rightEar : .leftEar
        let shoulderName: VNHumanBodyPoseObservation.JointName = useRight ? .rightShoulder : .leftShoulder

        guard let ear = frame.point(earName),
              let shoulder = frame.point(shoulderName) else {
            return .unmeasurable(type: .roundShoulder, reason: "관절 좌표 누락")
        }

        let ratio = GeometryMath.horizontalGapRatio(from: ear, to: shoulder, referenceWidth: shoulderWidth)
        let status = thresholds.evaluate(ratio)

        return PostureResult(
            type: .roundShoulder,
            status: status,
            primaryMetric: ratio,
            primaryMetricUnit: .ratio,
            thresholds: thresholds,
            usedJointNames: [earName.rawValue.rawValue, shoulderName.rawValue.rawValue],
            confidence: useRight ? rightConf : leftConf,
            advice: status == .normal ? nil : "어깨를 뒤로 펴는 스트레칭을 정기적으로 해주세요."
        )
    }
}
