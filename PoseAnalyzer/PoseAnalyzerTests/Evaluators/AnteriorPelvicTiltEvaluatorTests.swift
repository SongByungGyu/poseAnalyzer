import XCTest
import Vision
@testable import PoseAnalyzer

final class AnteriorPelvicTiltEvaluatorTests: XCTestCase {
    let evaluator = AnteriorPelvicTiltEvaluator()

    func test_180도_normal() {
        let frame = PoseFrame.sideViewWithAngle(180, atJoints: (.leftShoulder, .leftHip, .leftKnee))
        XCTAssertEqual(evaluator.evaluate(frame).status, .normal)
    }

    func test_172도_caution_전방경사_주의() {
        let frame = PoseFrame.sideViewWithAngle(172, atJoints: (.leftShoulder, .leftHip, .leftKnee))
        XCTAssertEqual(evaluator.evaluate(frame).status, .caution)
    }

    func test_165도_suspect_전방경사_의심() {
        let frame = PoseFrame.sideViewWithAngle(165, atJoints: (.leftShoulder, .leftHip, .leftKnee))
        XCTAssertEqual(evaluator.evaluate(frame).status, .suspect)
    }

    func test_188도_caution_후방경사_주의() {
        let frame = PoseFrame.sideViewWithAngle(188, atJoints: (.leftShoulder, .leftHip, .leftKnee))
        XCTAssertEqual(evaluator.evaluate(frame).status, .caution)
    }

    func test_관절_누락_unmeasurable() {
        XCTAssertEqual(evaluator.evaluate(.empty()).status, .unmeasurable)
    }
}
