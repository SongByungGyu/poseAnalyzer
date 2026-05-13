import XCTest
import Vision
@testable import PoseAnalyzer

final class HeadTiltEvaluatorTests: XCTestCase {
    let evaluator = HeadTiltEvaluator()

    func test_양귀_수평_normal() {
        let frame = PoseFrame.make(view: .front, [
            (.leftEar, CGPoint(x: 0.4, y: 0.8)),
            (.rightEar, CGPoint(x: 0.6, y: 0.8)),
        ])
        XCTAssertEqual(evaluator.evaluate(frame).status, .normal)
    }

    func test_귀_3도_기울기_caution() {
        let frame = PoseFrame.make(view: .front, [
            (.leftEar, CGPoint(x: 0.4, y: 0.8)),
            (.rightEar, CGPoint(x: 0.6, y: 0.8 + 0.0105)),
        ])
        XCTAssertEqual(evaluator.evaluate(frame).status, .caution)
    }

    func test_귀_7도_기울기_suspect() {
        let frame = PoseFrame.make(view: .front, [
            (.leftEar, CGPoint(x: 0.4, y: 0.8)),
            (.rightEar, CGPoint(x: 0.6, y: 0.8 + 0.0246)),
        ])
        XCTAssertEqual(evaluator.evaluate(frame).status, .suspect)
    }

    func test_귀_없으면_눈으로_fallback() {
        let frame = PoseFrame.make(view: .front, [
            (.leftEye, CGPoint(x: 0.4, y: 0.8)),
            (.rightEye, CGPoint(x: 0.6, y: 0.8)),
        ])
        XCTAssertEqual(evaluator.evaluate(frame).status, .normal)
    }

    func test_관절_없으면_unmeasurable() {
        XCTAssertEqual(evaluator.evaluate(.empty()).status, .unmeasurable)
    }
}
