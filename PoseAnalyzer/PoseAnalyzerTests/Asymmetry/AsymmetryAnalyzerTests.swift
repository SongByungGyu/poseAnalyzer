import XCTest
import Vision
@testable import PoseAnalyzer

final class AsymmetryAnalyzerTests: XCTestCase {
    let analyzer: AsymmetryAnalyzer = DefaultAsymmetryAnalyzer()

    func test_어깨_엉덩이_수평이면_balanced() {
        let frame = PoseFrame.make(view: .front, [
            (.leftShoulder, CGPoint(x: 0.4, y: 0.7)),
            (.rightShoulder, CGPoint(x: 0.6, y: 0.7)),
            (.leftHip, CGPoint(x: 0.4, y: 0.4)),
            (.rightHip, CGPoint(x: 0.6, y: 0.4)),
            (.nose, CGPoint(x: 0.5, y: 0.9)),
            (.leftAnkle, CGPoint(x: 0.4, y: 0.05)),
            (.rightAnkle, CGPoint(x: 0.6, y: 0.05)),
        ])
        let r = analyzer.analyze(frame, heightCm: nil)
        XCTAssertEqual(r.shoulder.direction, .balanced)
        XCTAssertEqual(r.hip.direction, .balanced)
        XCTAssertEqual(r.shoulder.cm, nil)  // 키 없음
    }

    func test_우측_어깨_높음_rightHigher() {
        let frame = PoseFrame.make(view: .front, [
            (.leftShoulder, CGPoint(x: 0.4, y: 0.7)),
            (.rightShoulder, CGPoint(x: 0.6, y: 0.72)),  // 위쪽
            (.leftHip, CGPoint(x: 0.4, y: 0.4)),
            (.rightHip, CGPoint(x: 0.6, y: 0.4)),
            (.nose, CGPoint(x: 0.5, y: 0.9)),
            (.leftAnkle, CGPoint(x: 0.4, y: 0.05)),
            (.rightAnkle, CGPoint(x: 0.6, y: 0.05)),
        ])
        let r = analyzer.analyze(frame, heightCm: nil)
        XCTAssertEqual(r.shoulder.direction, .rightHigher)
        XCTAssertGreaterThan(r.shoulder.angleDegrees, 0)
    }

    func test_키_입력시_cm_환산() {
        // 머리에서 발목까지 정규화 거리 0.85, 키 170cm → 1정규화단위 = 200cm
        let frame = PoseFrame.make(view: .front, [
            (.leftShoulder, CGPoint(x: 0.4, y: 0.7)),
            (.rightShoulder, CGPoint(x: 0.6, y: 0.71)),  // 0.01 차이
            (.leftHip, CGPoint(x: 0.4, y: 0.4)),
            (.rightHip, CGPoint(x: 0.6, y: 0.4)),
            (.nose, CGPoint(x: 0.5, y: 0.9)),
            (.leftAnkle, CGPoint(x: 0.4, y: 0.05)),
            (.rightAnkle, CGPoint(x: 0.6, y: 0.05)),
        ])
        let r = analyzer.analyze(frame, heightCm: 170)
        XCTAssertNotNil(r.shoulder.cm)
        // 0.01 정규화 거리 × (170 / 0.85) ≈ 2cm
        XCTAssertEqual(r.shoulder.cm!, 2.0, accuracy: 0.5)
    }
}
