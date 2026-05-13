import Foundation

/// 사진의 촬영 시점 시점 (정면 / 측면)
enum SessionView: String, Codable, CaseIterable {
    case front  // 정면
    case side   // 측면

    var koreanName: String {
        switch self {
        case .front: return "정면"
        case .side: return "측면"
        }
    }
}
