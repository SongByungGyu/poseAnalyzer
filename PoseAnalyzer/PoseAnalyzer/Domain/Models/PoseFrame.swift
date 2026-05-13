import CoreGraphics
import Vision

/// 한 장의 사진에서 추출된 관절 좌표 묶음
struct PoseFrame: Equatable {
    /// 관절 1개 정보
    struct Joint: Equatable {
        let name: VNHumanBodyPoseObservation.JointName
        let location: CGPoint    // 정규화 좌표 (0~1, Vision은 좌하단 원점)
        let confidence: Float
    }

    /// 관절명 → Joint
    let joints: [VNHumanBodyPoseObservation.JointName: Joint]

    /// 어느 시점(정면/측면)의 사진인지
    let view: SessionView

    /// 사진 크기 (오버레이 좌표 변환용)
    let imageSize: CGSize

    /// 특정 관절의 신뢰도가 임계값 이상인지 확인
    func isReliable(_ name: VNHumanBodyPoseObservation.JointName, threshold: Float = 0.3) -> Bool {
        guard let joint = joints[name] else { return false }
        return joint.confidence >= threshold
    }

    /// 여러 관절이 모두 신뢰 가능한지
    func areReliable(_ names: [VNHumanBodyPoseObservation.JointName], threshold: Float = 0.3) -> Bool {
        return names.allSatisfy { isReliable($0, threshold: threshold) }
    }

    /// 관절 좌표 반환 (신뢰도 무관)
    func point(_ name: VNHumanBodyPoseObservation.JointName) -> CGPoint? {
        joints[name]?.location
    }

    /// 평균 신뢰도 계산
    func averageConfidence(_ names: [VNHumanBodyPoseObservation.JointName]) -> Double {
        let validJoints = names.compactMap { joints[$0] }
        guard !validJoints.isEmpty else { return 0 }
        let sum = validJoints.map { Double($0.confidence) }.reduce(0, +)
        return sum / Double(validJoints.count)
    }
}
