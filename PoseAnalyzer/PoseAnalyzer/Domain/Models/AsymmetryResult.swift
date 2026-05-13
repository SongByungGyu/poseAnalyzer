import Foundation

/// 정면 사진 기반 좌우 비대칭 분석 결과
struct AsymmetryResult: Equatable {
    let shoulder: Difference
    let hip: Difference

    struct Difference: Equatable {
        let cm: Double?              // 키 입력 있을 때 cm
        let ratio: Double            // 어깨너비 대비 비율 (항상 계산)
        let angleDegrees: Double     // 기울기 (도)
        let direction: Direction
    }

    enum Direction: String, Codable {
        case leftHigher
        case rightHigher
        case balanced

        var koreanName: String {
            switch self {
            case .leftHigher: return "왼쪽이 높음"
            case .rightHigher: return "오른쪽이 높음"
            case .balanced: return "균형"
            }
        }
    }
}
