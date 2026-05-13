import Foundation

/// 판정 가능한 자세 종류 (MVP 8개)
enum PostureType: String, Codable, CaseIterable {
    case forwardHead         // 거북목
    case roundShoulder       // 라운드숄더
    case kyphosis            // 흉추 후만증
    case anteriorPelvicTilt  // 골반 전방경사
    case kneeHyperextension  // 무릎 과신전
    case scoliosis           // 척추측만
    case headTilt            // 머리 좌우 기울기
    case kneeAlignment       // 무릎 X자/O자

    var koreanName: String {
        switch self {
        case .forwardHead: return "거북목"
        case .roundShoulder: return "라운드숄더"
        case .kyphosis: return "흉추 후만증"
        case .anteriorPelvicTilt: return "골반 전방경사"
        case .kneeHyperextension: return "무릎 과신전"
        case .scoliosis: return "척추측만"
        case .headTilt: return "머리 좌우 기울기"
        case .kneeAlignment: return "무릎 X/O자"
        }
    }

    var requiredView: SessionView {
        switch self {
        case .forwardHead, .roundShoulder, .kyphosis,
             .anteriorPelvicTilt, .kneeHyperextension:
            return .side
        case .scoliosis, .headTilt, .kneeAlignment:
            return .front
        }
    }
}
