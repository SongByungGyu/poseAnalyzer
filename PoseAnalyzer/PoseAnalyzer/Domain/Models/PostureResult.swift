import Foundation
import Vision

/// 단일 자세 판정 결과
struct PostureResult: Equatable {
    let type: PostureType
    let status: PostureStatus
    let primaryMetric: Double              // 핵심 수치 (각도 또는 비율)
    let primaryMetricUnit: MetricUnit
    let thresholds: Thresholds
    let usedJointNames: [String]           // 디버그·이력용 (raw name)
    let confidence: Double                 // 사용 관절 평균 신뢰도 (0~1)
    let advice: String?                    // 간단한 권장 멘트

    enum MetricUnit: String, Codable {
        case degree     // 도
        case ratio      // 비율 (0~1)
        case centimeter // cm

        var symbol: String {
            switch self {
            case .degree: return "°"
            case .ratio: return ""
            case .centimeter: return "cm"
            }
        }
    }

    /// 측정 불가 결과 생성 헬퍼
    static func unmeasurable(type: PostureType, reason: String) -> PostureResult {
        PostureResult(
            type: type,
            status: .unmeasurable,
            primaryMetric: 0,
            primaryMetricUnit: .degree,
            thresholds: Thresholds(normalRange: 0...0, cautionRange: nil, direction: .higherIsNormal),
            usedJointNames: [],
            confidence: 0,
            advice: reason
        )
    }
}
