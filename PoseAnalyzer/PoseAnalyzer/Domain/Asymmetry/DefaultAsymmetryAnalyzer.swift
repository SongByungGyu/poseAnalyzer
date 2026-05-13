import Vision
import CoreGraphics

final class DefaultAsymmetryAnalyzer: AsymmetryAnalyzer {

    /// 균형으로 판단할 각도 임계값 (도)
    private let balancedThreshold: Double = 0.5

    func analyze(_ frontFrame: PoseFrame, heightCm: Double?) -> AsymmetryResult {
        let shoulder = analyzePair(
            frontFrame, left: .leftShoulder, right: .rightShoulder, heightCm: heightCm
        )
        let hip = analyzePair(
            frontFrame, left: .leftHip, right: .rightHip, heightCm: heightCm
        )
        return AsymmetryResult(shoulder: shoulder, hip: hip)
    }

    private func analyzePair(
        _ frame: PoseFrame,
        left: VNHumanBodyPoseObservation.JointName,
        right: VNHumanBodyPoseObservation.JointName,
        heightCm: Double?
    ) -> AsymmetryResult.Difference {
        guard let lp = frame.point(left), let rp = frame.point(right) else {
            return AsymmetryResult.Difference(cm: nil, ratio: 0, angleDegrees: 0, direction: .balanced)
        }

        let angle = GeometryMath.absLineAngleFromHorizontal(lp, rp)
        let referenceWidth = GeometryMath.distance(lp, rp)
        let normalizedYDiff = abs(Double(lp.y - rp.y))
        let ratio = referenceWidth > 0 ? (normalizedYDiff / referenceWidth) : 0

        let direction: AsymmetryResult.Direction
        if angle < balancedThreshold {
            direction = .balanced
        } else if lp.y > rp.y {
            // Vision 좌표: Y 큰 쪽이 위. lp.y > rp.y면 왼쪽이 높음
            direction = .leftHigher
        } else {
            direction = .rightHigher
        }

        // cm 환산 — 키 있으면 머리-발목 정규화 거리로 환산 비율 계산
        var cm: Double? = nil
        if let height = heightCm,
           let nose = frame.point(.nose),
           let leftAnkle = frame.point(.leftAnkle),
           let rightAnkle = frame.point(.rightAnkle) {
            let ankleAvgY = Double(leftAnkle.y + rightAnkle.y) / 2
            let bodyPixelHeight = abs(Double(nose.y) - ankleAvgY)
            if bodyPixelHeight > 0 {
                let cmPerNormalized = height / bodyPixelHeight
                cm = normalizedYDiff * cmPerNormalized
            }
        }

        return AsymmetryResult.Difference(
            cm: cm,
            ratio: ratio,
            angleDegrees: angle,
            direction: direction
        )
    }
}
