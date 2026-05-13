import XCTest
import Vision
@testable import PoseAnalyzer

final class KyphosisEvaluatorTests: XCTestCase {
    let evaluator = KyphosisEvaluator()

    func test_정상_180도_normal() {
        // neck, shoulder, hip 직선 → 180도
        let frame = PoseFrame.sideViewWithAngle(180, atJoints: (.neck, .leftShoulder, .leftHip))
        let result = evaluator.evaluate(frame)
        XCTAssertEqual(result.status, .normal)
    }

    func test_경계_170도_caution() {
        let frame = PoseFrame.sideViewWithAngle(170, atJoints: (.neck, .leftShoulder, .leftHip))
        let result = evaluator.evaluate(frame)
        XCTAssertEqual(result.status, .caution)
    }

    func test_의심_160도_suspect() {
        let frame = PoseFrame.sideViewWithAngle(160, atJoints: (.neck, .leftShoulder, .leftHip))
        let result = evaluator.evaluate(frame)
        XCTAssertEqual(result.status, .suspect)
    }

    func test_관절_누락_unmeasurable() {
        let frame = PoseFrame.empty()
        let result = evaluator.evaluate(frame)
        XCTAssertEqual(result.status, .unmeasurable)
    }
}
