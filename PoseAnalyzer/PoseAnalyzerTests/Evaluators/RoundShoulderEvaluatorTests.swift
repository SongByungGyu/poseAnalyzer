import XCTest
import Vision
@testable import PoseAnalyzer

final class RoundShoulderEvaluatorTests: XCTestCase {

    let evaluator = RoundShoulderEvaluator()

    private func makeFrame(earX: Double, shoulderX: Double, shoulderWidth: Double, confidence: Float = 0.9) -> PoseFrame {
        // 측면이라 한쪽만 신뢰 가능
        // 어깨 폭은 leftShoulder-rightShoulder 거리로 추정 (측면에선 X 좌표 차이 거의 0이므로 어깨 폭은 별도로 주입)
        // 라운드숄더 측정은 동측 어깨와 동측 귀의 X 좌표 차이를 어깨 폭(reference)으로 나눈 비율
        return PoseFrame.make(view: .side, confidence: confidence, [
            (.leftEar, CGPoint(x: earX, y: 0.7)),
            (.leftShoulder, CGPoint(x: shoulderX, y: 0.5)),
            (.rightShoulder, CGPoint(x: shoulderX + shoulderWidth, y: 0.5)),  // 폭 추정용
        ])
    }

    func test_어깨와_귀_수직정렬_정상() {
        let frame = makeFrame(earX: 0.5, shoulderX: 0.5, shoulderWidth: 0.2)
        let result = evaluator.evaluate(frame)
        XCTAssertEqual(result.status, .normal)
    }

    func test_어깨가_귀보다_20퍼센트_앞_주의() {
        // 비율 0.2 → 0.15-0.25 사이 → caution
        let frame = makeFrame(earX: 0.5, shoulderX: 0.54, shoulderWidth: 0.2)
        let result = evaluator.evaluate(frame)
        XCTAssertEqual(result.status, .caution)
    }

    func test_어깨가_귀보다_심하게_앞_의심() {
        // 비율 0.4 → > 0.25 → suspect
        let frame = makeFrame(earX: 0.5, shoulderX: 0.58, shoulderWidth: 0.2)
        let result = evaluator.evaluate(frame)
        XCTAssertEqual(result.status, .suspect)
    }

    func test_관절_없으면_unmeasurable() {
        let frame = PoseFrame.empty()
        let result = evaluator.evaluate(frame)
        XCTAssertEqual(result.status, .unmeasurable)
    }
}
