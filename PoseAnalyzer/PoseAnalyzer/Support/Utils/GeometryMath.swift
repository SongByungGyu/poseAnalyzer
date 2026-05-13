import CoreGraphics
import Foundation

/// 관절 좌표 기반 기하 계산 유틸 (순수 함수 모음)
enum GeometryMath {

    /// 세 점이 이루는 각도 (vertex를 중심으로 한 ∠p1·vertex·p2). 단위: 도
    /// 분모가 0인 경우 0 반환 (NaN 방지).
    static func angleBetween(p1: CGPoint, vertex: CGPoint, p2: CGPoint) -> Double {
        let v1 = CGVector(dx: p1.x - vertex.x, dy: p1.y - vertex.y)
        let v2 = CGVector(dx: p2.x - vertex.x, dy: p2.y - vertex.y)
        let dot = Double(v1.dx * v2.dx + v1.dy * v2.dy)
        let mag1 = sqrt(Double(v1.dx * v1.dx + v1.dy * v1.dy))
        let mag2 = sqrt(Double(v2.dx * v2.dx + v2.dy * v2.dy))
        guard mag1 > 0, mag2 > 0 else { return 0 }
        var cosTheta = dot / (mag1 * mag2)
        cosTheta = max(-1, min(1, cosTheta))  // acos 범위 보호
        return acos(cosTheta) * 180 / .pi
    }

    /// 두 점 사이 유클리드 거리
    static func distance(_ a: CGPoint, _ b: CGPoint) -> Double {
        let dx = Double(a.x - b.x)
        let dy = Double(a.y - b.y)
        return sqrt(dx * dx + dy * dy)
    }

    /// 수평선 대비 두 점을 잇는 직선의 기울기 각도 (도). 양수 = 두번째 점이 위.
    /// 결과 범위: -90 ~ 90
    static func lineAngleFromHorizontal(_ a: CGPoint, _ b: CGPoint) -> Double {
        let dx = Double(b.x - a.x)
        let dy = Double(b.y - a.y)
        return atan2(dy, dx) * 180 / .pi
    }

    /// 두 점의 수평(X축) 거리 / 기준 폭 비율 (절댓값)
    static func horizontalGapRatio(from a: CGPoint, to b: CGPoint, referenceWidth: Double) -> Double {
        guard referenceWidth > 0 else { return 0 }
        return abs(Double(a.x - b.x)) / referenceWidth
    }

    /// 두 점 잇는 직선의 수평 대비 기울기 (절댓값, 도). 항상 0~90.
    static func absLineAngleFromHorizontal(_ a: CGPoint, _ b: CGPoint) -> Double {
        return abs(lineAngleFromHorizontal(a, b))
    }
}
