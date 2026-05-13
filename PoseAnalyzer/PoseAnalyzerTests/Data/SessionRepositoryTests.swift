import XCTest
import SwiftData
@testable import PoseAnalyzer

@MainActor
final class SessionRepositoryTests: XCTestCase {

    var container: ModelContainer!
    var tempDir: URL!
    var imageStore: ImageStore!
    var repository: SessionRepository!

    override func setUp() async throws {
        let schema = Schema([
            UserProfile.self, SessionRecord.self, PostureRecord.self
        ])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, configurations: [config])

        tempDir = FileManager.default.temporaryDirectory.appendingPathComponent("SessionRepoTests-\(UUID())")
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        imageStore = ImageStore(baseDirectory: tempDir)

        repository = SessionRepository(
            context: container.mainContext,
            imageStore: imageStore
        )
    }

    override func tearDown() async throws {
        try? FileManager.default.removeItem(at: tempDir)
    }

    func test_세션_저장_후_조회() async throws {
        let report = makeReport()
        try repository.save(report)

        let all = try repository.fetchAll()
        XCTAssertEqual(all.count, 1)
        XCTAssertEqual(all.first?.postures.count, 8)
    }

    func test_시간_역순_조회() async throws {
        let oldReport = makeReport(measuredAt: Date(timeIntervalSinceNow: -100))
        let newReport = makeReport(measuredAt: .now)
        try repository.save(oldReport)
        try repository.save(newReport)

        let all = try repository.fetchAll()
        XCTAssertEqual(all.first?.id, newReport.id)
        XCTAssertEqual(all.last?.id, oldReport.id)
    }

    func test_세션_삭제시_사진도_삭제() async throws {
        let report = makeReport()
        try repository.save(report)

        let sessionDir = tempDir
            .appendingPathComponent("sessions")
            .appendingPathComponent(report.id.uuidString)
        XCTAssertTrue(FileManager.default.fileExists(atPath: sessionDir.path))

        try repository.delete(id: report.id)

        XCTAssertFalse(FileManager.default.fileExists(atPath: sessionDir.path))
        let all = try repository.fetchAll()
        XCTAssertEqual(all.count, 0)
    }

    // MARK: - Helper

    private func makeReport(measuredAt: Date = .now) -> SessionReport {
        let image = UIGraphicsImageRenderer(size: CGSize(width: 10, height: 10)).image { ctx in
            UIColor.gray.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 10, height: 10))
        }
        let dummyFrame = PoseFrame.empty()
        let postures = PostureType.allCases.map { type in
            PostureResult(
                type: type, status: .normal, primaryMetric: 180,
                primaryMetricUnit: .degree,
                thresholds: Thresholds(normalRange: 170...360, cautionRange: 160...170, direction: .higherIsNormal),
                usedJointNames: [], confidence: 0.9, advice: nil
            )
        }
        let asymmetry = AsymmetryResult(
            shoulder: .init(cm: nil, ratio: 0, angleDegrees: 0, direction: .balanced),
            hip: .init(cm: nil, ratio: 0, angleDegrees: 0, direction: .balanced)
        )
        return SessionReport(
            id: UUID(), measuredAt: measuredAt,
            frontImage: image, sideImage: image,
            frontFrame: dummyFrame, sideFrame: dummyFrame,
            postures: postures, asymmetry: asymmetry, heightCmAtMeasure: 170
        )
    }
}
