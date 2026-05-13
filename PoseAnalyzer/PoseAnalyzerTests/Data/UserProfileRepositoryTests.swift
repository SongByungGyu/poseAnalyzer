import XCTest
import SwiftData
@testable import PoseAnalyzer

@MainActor
final class UserProfileRepositoryTests: XCTestCase {

    var container: ModelContainer!
    var repository: UserProfileRepository!

    override func setUp() async throws {
        let schema = Schema([UserProfile.self, SessionRecord.self, PostureRecord.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, configurations: [config])
        repository = UserProfileRepository(context: container.mainContext)
    }

    func test_초기에는_키_nil() throws {
        XCTAssertNil(try repository.getHeightCm())
    }

    func test_키_저장_후_조회() throws {
        try repository.updateHeightCm(170)
        XCTAssertEqual(try repository.getHeightCm(), 170)
    }

    func test_키_업데이트_시_단일_레코드_유지() throws {
        try repository.updateHeightCm(170)
        try repository.updateHeightCm(175)

        let descriptor = FetchDescriptor<UserProfile>()
        let all = try container.mainContext.fetch(descriptor)
        XCTAssertEqual(all.count, 1, "프로필 레코드는 단일 인스턴스 유지")
        XCTAssertEqual(try repository.getHeightCm(), 175)
    }
}
