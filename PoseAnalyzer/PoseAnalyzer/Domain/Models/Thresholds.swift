import Foundation

/// 자세 판정 임계값
/// - 단일 값 기준 (각도, 비율 등)
/// - 범위 기준 (예: 무릎 과신전은 175-185 정상, 185-190 주의, >190 의심)
struct Thresholds: Equatable {
    /// 정상 범위 (이 안에 들면 normal)
    let normalRange: ClosedRange<Double>
    /// 주의 범위 (정상 바깥, 의심보다 약한 범위)
    let cautionRange: ClosedRange<Double>?
    /// 평가 방향 (값이 클수록 좋은지, 작을수록 좋은지, 또는 정상범위에서 멀수록 나쁜지)
    let direction: Direction

    enum Direction: Equatable {
        case higherIsNormal     // 값이 클수록 정상 (예: 거북목 각도, 175°↑)
        case lowerIsNormal      // 값이 작을수록 정상 (예: 어깨 기울기, <2°)
        case centeredOnRange    // 정상 범위 안이면 정상, 바깥은 멀수록 나쁨 (예: 무릎 과신전)
    }

    /// 측정값을 평가하여 PostureStatus 반환
    func evaluate(_ value: Double) -> PostureStatus {
        if normalRange.contains(value) {
            return .normal
        }
        if let caution = cautionRange, caution.contains(value) {
            return .caution
        }
        return .suspect
    }
}
