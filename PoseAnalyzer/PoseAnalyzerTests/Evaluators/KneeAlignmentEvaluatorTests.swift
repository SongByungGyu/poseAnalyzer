import XCTest
import Vision
@testable import PoseAnalyzer

final class KneeAlignmentEvaluatorTests: XCTestCase {
    let evaluator = KneeAlignmentEvaluator()

    private func makeFront(
        leftHip: CGPoint, leftKnee: CGPoint, leftAnkle: CGPoint,
        rightHip: CGPoint, rightKnee: CGPoint, rightAnkle: CGPoint,
        confidence: Float = 0.9
    ) -> PoseFrame {
        PoseFrame.make(view: .front, confidence: confidence, [
            (.leftHip, leftHip),
            (.leftKnee, leftKnee),
            (.leftAnkle, leftAnkle),
            (.rightHip, rightHip),
            (.rightKnee, rightKnee),
            (.rightAnkle, rightAnkle),
        ])
    }

    func test_양다리_수직정렬_normal() {
        // 엉덩이-무릎-발목 직선 (각도 180)
        let frame = makeFront(
            leftHip: CGPoint(x: 0.4, y: 0.5),
            leftKnee: CGPoint(x: 0.4, y: 0.3),
            leftAnkle: CGPoint(x: 0.4, y: 0.1),
            rightHip: CGPoint(x: 0.6, y: 0.5),
            rightKnee: CGPoint(x: 0.6, y: 0.3),
            rightAnkle: CGPoint(x: 0.6, y: 0.1)
        )
        XCTAssertEqual(evaluator.evaluate(frame).status, .normal)
    }

    func test_X자_다리_의심() {
        // 무릎이 안쪽으로 (각도 < 170°)
        // 왼쪽: hip(0.4, 0.5) → knee(0.5, 0.3) → ankle(0.4, 0.1) — 무릎이 안으로
        let frame = makeFront(
            leftHip: CGPoint(x: 0.4, y: 0.5),
            leftKnee: CGPoint(x: 0.5, y: 0.3),
            leftAnkle: CGPoint(x: 0.4, y: 0.1),
            rightHip: CGPoint(x: 0.6, y: 0.5),
            rightKnee: CGPoint(x: 0.5, y: 0.3),
            rightAnkle: CGPoint(x: 0.6, y: 0.1)
        )
        XCTAssertEqual(evaluator.evaluate(frame).status, .suspect)
    }

    func test_관절_누락_unmeasurable() {
        XCTAssertEqual(evaluator.evaluate(.empty()).status, .unmeasurable)
    }
}
