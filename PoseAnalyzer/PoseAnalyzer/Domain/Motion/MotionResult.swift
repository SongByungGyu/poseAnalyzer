import Foundation

/// 영상 기반 동적 자세 분석 결과 (2차 확장용 — MVP에서는 사용 안 함)
struct MotionResult: Equatable {
    let timestamp: TimeInterval
    let motionType: String        // 향후: enum으로 ("squat", "running" 등)
    let phase: String             // 동작 단계 (예: "descent", "bottom", "ascent")
    let metrics: [String: Double] // 동작별 측정값 (예: ["knee_angle": 90, "depth": 0.4])
    let qualityScore: Double      // 0~1
}
