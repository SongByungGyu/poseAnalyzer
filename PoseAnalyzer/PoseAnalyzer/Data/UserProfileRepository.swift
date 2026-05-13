import Foundation
import SwiftData

/// 사용자 키 등 단일 프로필 저장/조회 (앱당 1개 레코드만 유지)
@MainActor
final class UserProfileRepository {

    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func getHeightCm() throws -> Double? {
        return try fetchProfile()?.heightCm
    }

    func updateHeightCm(_ value: Double?) throws {
        if let profile = try fetchProfile() {
            profile.heightCm = value
            profile.updatedAt = .now
        } else {
            let profile = UserProfile(heightCm: value)
            context.insert(profile)
        }
        try context.save()
    }

    private func fetchProfile() throws -> UserProfile? {
        let descriptor = FetchDescriptor<UserProfile>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        return try context.fetch(descriptor).first
    }
}
