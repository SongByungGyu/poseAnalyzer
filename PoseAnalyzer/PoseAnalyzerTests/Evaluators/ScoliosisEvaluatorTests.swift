import XCTest
import Vision
@testable import PoseAnalyzer

final class ScoliosisEvaluatorTests: XCTestCase {
    let evaluator = ScoliosisEvaluator()

    private func makeFront(
        leftShoulder: CGPoint, rightShoulder: CGPoint,
        leftHip: CGPoint, rightHip: CGPoint,
        confidence: Float = 0.9
    ) -> PoseFrame {
        return PoseFrame.make(view: .front, confidence: confidence, [
            (.leftShoulder, leftShoulder),
            (.rightShoulder, rightShoulder),
            (.leftHip, leftHip),
            (.rightHip, rightHip),
        ])
    }

    func test_어깨_엉덩이_수평_normal() {
        let frame = makeFront(
            leftShoulder: CGPoint(x: 0.4, y: 0.7), rightShoulder: CGPoint(x: 0.6, y: 0.7),
            leftHip: CGPoint(x: 0.4, y: 0.4), rightHip: CGPoint(x: 0.6, y: 0.4)
        )
        XCTAssertEqual(evaluator.evaluate(frame).status, .normal)
    }

    func test_어깨_3도_기울기_caution() {
        // tan(3°) ≈ 0.0524 → 어깨 폭 0.2면 높이차 약 0.0105
        let frame = makeFront(
            leftShoulder: CGPoint(x: 0.4, y: 0.7), rightShoulder: CGPoint(x: 0.6, y: 0.7 + 0.0105),
            leftHip: CGPoint(x: 0.4, y: 0.4), rightHip: CGPoint(x: 0.6, y: 0.4)
        )
        XCTAssertEqual(evaluator.evaluate(frame).status, .caution)
    }

    func test_어깨_7도_기울기_suspect() {
        let frame = makeFront(
            leftShoulder: CGPoint(x: 0.4, y: 0.7), rightShoulder: CGPoint(x: 0.6, y: 0.7 + 0.0246),
            leftHip: CGPoint(x: 0.4, y: 0.4), rightHip: CGPoint(x: 0.6, y: 0.4)
        )
        XCTAssertEqual(evaluator.evaluate(frame).status, .suspect)
    }

    func test_관절_없으면_unmeasurable() {
        XCTAssertEqual(evaluator.evaluate(.empty()).status, .unmeasurable)
    }
}
