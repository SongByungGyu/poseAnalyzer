import XCTest
@testable import PoseAnalyzer

final class GeometryMathTests: XCTestCase {

    // MARK: - angleBetween (세 점이 이루는 각도)

    func test_세점이_직선이면_각도는_180도() {
        let p1 = CGPoint(x: 0, y: 0)
        let v = CGPoint(x: 1, y: 0)
        let p2 = CGPoint(x: 2, y: 0)
        let angle = GeometryMath.angleBetween(p1: p1, vertex: v, p2: p2)
        XCTAssertEqual(angle, 180, accuracy: 0.01)
    }

    func test_세점이_직각이면_각도는_90도() {
        let p1 = CGPoint(x: 0, y: 1)
        let v = CGPoint(x: 0, y: 0)
        let p2 = CGPoint(x: 1, y: 0)
        let angle = GeometryMath.angleBetween(p1: p1, vertex: v, p2: p2)
        XCTAssertEqual(angle, 90, accuracy: 0.01)
    }

    func test_세점이_겹치면_NaN_또는_0_반환() {
        let p1 = CGPoint(x: 0, y: 0)
        let v = CGPoint(x: 0, y: 0)
        let p2 = CGPoint(x: 1, y: 0)
        let angle = GeometryMath.angleBetween(p1: p1, vertex: v, p2: p2)
        // 분모 0이라 NaN/Inf 가능 — 함수는 0 반환하도록 설계
        XCTAssertTrue(angle.isFinite, "유한 값이어야 함")
    }

    // MARK: - distance (두 점 사이 거리)

    func test_같은_점_사이_거리는_0() {
        let d = GeometryMath.distance(CGPoint(x: 5, y: 5), CGPoint(x: 5, y: 5))
        XCTAssertEqual(d, 0, accuracy: 0.01)
    }

    func test_345_피타고라스_거리는_5() {
        let d = GeometryMath.distance(CGPoint(x: 0, y: 0), CGPoint(x: 3, y: 4))
        XCTAssertEqual(d, 5, accuracy: 0.01)
    }

    // MARK: - lineAngle (수평 대비 두 점이 만드는 직선의 기울기 각도)

    func test_수평_직선_기울기는_0도() {
        let angle = GeometryMath.lineAngleFromHorizontal(
            CGPoint(x: 0, y: 5), CGPoint(x: 10, y: 5)
        )
        XCTAssertEqual(angle, 0, accuracy: 0.01)
    }

    func test_수직_직선_기울기는_90도() {
        let angle = GeometryMath.lineAngleFromHorizontal(
            CGPoint(x: 5, y: 0), CGPoint(x: 5, y: 10)
        )
        XCTAssertEqual(abs(angle), 90, accuracy: 0.01)
    }

    func test_우측이_높은_45도_기울기() {
        // Vision 좌표계: 좌하단 원점, Y 위로 갈수록 증가
        let angle = GeometryMath.lineAngleFromHorizontal(
            CGPoint(x: 0, y: 0), CGPoint(x: 10, y: 10)
        )
        XCTAssertEqual(angle, 45, accuracy: 0.01)
    }

    // MARK: - horizontalGapRatio (어깨-귀 같은 수평 거리 비율 계산)

    func test_수평_거리_비율() {
        // 어깨와 귀가 수평으로 5만큼, 어깨 폭이 20이면 비율 0.25
        let ratio = GeometryMath.horizontalGapRatio(
            from: CGPoint(x: 5, y: 0),  // 귀
            to: CGPoint(x: 0, y: 0),    // 어깨
            referenceWidth: 20
        )
        XCTAssertEqual(ratio, 0.25, accuracy: 0.01)
    }
}
