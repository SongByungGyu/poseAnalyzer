import XCTest
import Vision
@testable import PoseAnalyzer

final class KneeHyperextensionEvaluatorTests: XCTestCase {
    let evaluator = KneeHyperextensionEvaluator()

    func test_180도_normal() {
        let frame = PoseFrame.sideViewWithAngle(180, atJoints: (.leftHip, .leftKnee, .leftAnkle))
        XCTAssertEqual(evaluator.evaluate(frame).status, .normal)
    }

    func test_187도_caution() {
        let frame = PoseFrame.sideViewWithAngle(187, atJoints: (.leftHip, .leftKnee, .leftAnkle))
        XCTAssertEqual(evaluator.evaluate(frame).status, .caution)
    }

    func test_195도_suspect() {
        let frame = PoseFrame.sideViewWithAngle(195, atJoints: (.leftHip, .leftKnee, .leftAnkle))
        XCTAssertEqual(evaluator.evaluate(frame).status, .suspect)
    }

    func test_관절_누락_unmeasurable() {
        XCTAssertEqual(evaluator.evaluate(.empty()).status, .unmeasurable)
    }
}
