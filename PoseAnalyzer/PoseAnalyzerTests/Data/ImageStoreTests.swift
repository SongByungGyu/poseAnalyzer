import XCTest
@testable import PoseAnalyzer

final class ImageStoreTests: XCTestCase {

    var tempDir: URL!
    var store: ImageStore!

    override func setUpWithError() throws {
        tempDir = FileManager.default.temporaryDirectory.appendingPathComponent("ImageStoreTests-\(UUID())")
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        store = ImageStore(baseDirectory: tempDir)
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: tempDir)
    }

    func test_저장_로드_라운드트립() throws {
        let image = makeTestImage(color: .red)
        let sessionID = UUID()

        let path = try store.save(image, for: sessionID, view: .front)
        XCTAssertFalse(path.isEmpty)

        let loaded = store.load(path: path)
        XCTAssertNotNil(loaded)
    }

    func test_삭제_후_파일_없음() throws {
        let image = makeTestImage(color: .blue)
        let sessionID = UUID()
        _ = try store.save(image, for: sessionID, view: .front)
        _ = try store.save(image, for: sessionID, view: .side)

        try store.delete(for: sessionID)

        let sessionDir = tempDir.appendingPathComponent("sessions").appendingPathComponent(sessionID.uuidString)
        XCTAssertFalse(FileManager.default.fileExists(atPath: sessionDir.path))
    }

    func test_정면_측면_파일_분리() throws {
        let image = makeTestImage(color: .green)
        let sessionID = UUID()
        let frontPath = try store.save(image, for: sessionID, view: .front)
        let sidePath = try store.save(image, for: sessionID, view: .side)
        XCTAssertNotEqual(frontPath, sidePath)
        XCTAssertTrue(frontPath.contains("front"))
        XCTAssertTrue(sidePath.contains("side"))
    }

    private func makeTestImage(color: UIColor) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 10, height: 10))
        return renderer.image { ctx in
            color.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 10, height: 10))
        }
    }
}
