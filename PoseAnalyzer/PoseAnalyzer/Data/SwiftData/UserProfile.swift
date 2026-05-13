import Foundation
import SwiftData

/// 사용자 프로필 (앱당 1개 인스턴스 유지)
@Model
final class UserProfile {
    var heightCm: Double?
    var updatedAt: Date

    init(heightCm: Double? = nil) {
        self.heightCm = heightCm
        self.updatedAt = .now
    }
}
