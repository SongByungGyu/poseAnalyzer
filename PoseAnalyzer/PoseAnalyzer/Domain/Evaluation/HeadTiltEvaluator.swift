import Vision

/// 머리 좌우 기울기 (Head Tilt) — 정면 사진
/// 측정: 양 귀 직선의 수평 대비 기울기 (귀 신뢰도 낮으면 양 눈으로 fallback)
final class HeadTiltEvaluator: PostureEvaluator {

    let type: PostureType = .headTilt
    let requiredView: SessionView = .front

    private let thresholds = Thresholds(
        normalRange: 0...2,
        cautionRange: 2...5,
        direction: .lowerIsNormal
    )

    func evaluate(_ frame: PoseFrame) -> PostureResult {
        let earsReliable = frame.areReliable([.leftEar, .rightEar])
        let eyesReliable = frame.areReliable([.leftEye, .rightEye])

        let leftName: VNHumanBodyPoseObservation.JointName
        let rightName: VNHumanBodyPoseObservation.JointName
        let usedConfidence: Double

        if earsReliable {
            leftName = .leftEar
            rightName = .rightEar
            usedConfidence = frame.averageConfidence([.leftEar, .rightEar])
        } else if eyesReliable {
            leftName = .leftEye
            rightName = .rightEye
            usedConfidence = frame.averageConfidence([.leftEye, .rightEye])
        } else {
            return .unmeasurable(type: .headTilt, reason: "양 귀·양 눈 모두 인식 부족")
        }

        guard let left = frame.point(leftName),
              let right = frame.point(rightName) else {
            return .unmeasurable(type: .headTilt, reason: "관절 좌표 누락")
        }

        let tilt = GeometryMath.absLineAngleFromHorizontal(left, right)
        let status = thresholds.evaluate(tilt)

        return PostureResult(
            type: .headTilt,
            status: status,
            primaryMetric: tilt,
            primaryMetricUnit: .degree,
            thresholds: thresholds,
            usedJointNames: [leftName.rawValue.rawValue, rightName.rawValue.rawValue],
            confidence: usedConfidence,
            advice: status == .normal ? nil : "한쪽으로 머리를 기우는 습관이 있는지 확인해보세요."
        )
    }
}
