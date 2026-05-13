import Vision

/// 무릎 X자(Genu Valgum) / O자(Genu Varum) 다리 정렬 판정
/// 측정: 좌·우 다리 각각 엉덩이-무릎-발목 각도
/// 임계값: 175~180 정상, 170~175 / 180~185 주의, <170 X자(의심) / >185 O자(의심)
final class KneeAlignmentEvaluator: PostureEvaluator {

    let type: PostureType = .kneeAlignment
    let requiredView: SessionView = .front

    private let thresholds = Thresholds(
        normalRange: 175...180,
        cautionRange: 170...185,
        direction: .centeredOnRange
    )

    func evaluate(_ frame: PoseFrame) -> PostureResult {
        let leftJoints: [VNHumanBodyPoseObservation.JointName] = [.leftHip, .leftKnee, .leftAnkle]
        let rightJoints: [VNHumanBodyPoseObservation.JointName] = [.rightHip, .rightKnee, .rightAnkle]

        guard frame.areReliable(leftJoints) && frame.areReliable(rightJoints) else {
            return .unmeasurable(type: .kneeAlignment, reason: "양 다리 관절 신뢰도 부족")
        }

        guard let lh = frame.point(.leftHip), let lk = frame.point(.leftKnee), let la = frame.point(.leftAnkle),
              let rh = frame.point(.rightHip), let rk = frame.point(.rightKnee), let ra = frame.point(.rightAnkle) else {
            return .unmeasurable(type: .kneeAlignment, reason: "관절 좌표 누락")
        }

        let leftAngle = GeometryMath.angleBetween(p1: lh, vertex: lk, p2: la)
        let rightAngle = GeometryMath.angleBetween(p1: rh, vertex: rk, p2: ra)

        // 정상 범위에서 더 멀리 떨어진 다리의 각도를 primary로 사용
        let leftDeviation = min(abs(leftAngle - 175), abs(leftAngle - 180))
        let rightDeviation = min(abs(rightAngle - 175), abs(rightAngle - 180))
        let primary = leftDeviation > rightDeviation ? leftAngle : rightAngle
        let status = thresholds.evaluate(primary)

        let pattern: String
        if leftAngle < 175 && rightAngle < 175 { pattern = "X자(내반슬) 경향" }
        else if leftAngle > 180 && rightAngle > 180 { pattern = "O자(외반슬) 경향" }
        else { pattern = "한쪽 다리 정렬 이상" }

        return PostureResult(
            type: .kneeAlignment,
            status: status,
            primaryMetric: primary,
            primaryMetricUnit: .degree,
            thresholds: thresholds,
            usedJointNames: (leftJoints + rightJoints).map { $0.rawValue.rawValue },
            confidence: frame.averageConfidence(leftJoints + rightJoints),
            advice: status == .normal ? nil : "\(pattern). 좌측 \(String(format: "%.0f", leftAngle))° / 우측 \(String(format: "%.0f", rightAngle))°"
        )
    }
}
