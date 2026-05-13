import Foundation

/// 판정 결과 상태 (4단계)
enum PostureStatus: String, Codable {
    case normal         // 정상 🟢
    case caution        // 주의 🟡
    case suspect        // 의심 🟠
    case unmeasurable   // 측정 불가 ⚪

    var koreanName: String {
        switch self {
        case .normal: return "정상"
        case .caution: return "주의"
        case .suspect: return "의심"
        case .unmeasurable: return "측정 불가"
        }
    }
}
