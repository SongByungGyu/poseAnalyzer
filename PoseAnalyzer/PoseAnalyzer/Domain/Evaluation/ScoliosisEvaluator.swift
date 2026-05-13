import Vision

/// 척추측만 (Scoliosis) — 어깨/엉덩이 좌우 기울기로 추정
/// 측정: 양 어깨 직선과 수평 사이 각도 + 양 엉덩이 직선과 수평 사이 각도
/// 임계값: 두 값 모두 <2° 정상, 둘 중 하나 2~5° 주의, 5°초과 의심
final class ScoliosisEvaluator: PostureEvaluator {

    let type: PostureType = .scoliosis
    let requiredView: SessionView = .front

    private let thresholds = Thresholds(
        normalRange: 0...2,
        cautionRange: 2...5,
        direction: .lowerIsNormal
    )

    func evaluate(_ frame: PoseFrame) -> PostureResult {
        let needed: [VNHumanBodyPoseObservation.JointName] = [
            .leftShoulder, .rightShoulder, .leftHip, .rightHip
        ]
        guard frame.areReliable(needed) else {
            return .unmeasurable(type: .scoliosis, reason: "양 어깨·엉덩이 관절 신뢰도 부족")
        }

        guard let ls = frame.point(.leftShoulder),
              let rs = frame.point(.rightShoulder),
              let lh = frame.point(.leftHip),
              let rh = frame.point(.rightHip) else {
            return .unmeasurable(type: .scoliosis, reason: "관절 좌표 누락")
        }

        let shoulderTilt = GeometryMath.absLineAngleFromHorizontal(ls, rs)
        let hipTilt = GeometryMath.absLineAngleFromHorizontal(lh, rh)

        // 더 큰 기울기를 primaryMetric으로 사용
        let primary = max(shoulderTilt, hipTilt)
        let status = thresholds.evaluate(primary)

        return PostureResult(
            type: .scoliosis,
            status: status,
            primaryMetric: primary,
            primaryMetricUnit: .degree,
            thresholds: thresholds,
            usedJointNames: needed.map { $0.rawValue.rawValue },
            confidence: frame.averageConfidence(needed),
            advice: status == .normal ? nil : "어깨 기울기 \(String(format: "%.1f", shoulderTilt))° / 골반 기울기 \(String(format: "%.1f", hipTilt))°. 전문가 상담을 권장합니다."
        )
    }
}
