import Foundation
import SwiftData

/// 한 세션 안의 개별 자세 판정 결과
@Model
final class PostureRecord {
    @Attribute(.unique) var id: UUID
    var typeRaw: String              // PostureType.rawValue
    var statusRaw: String            // PostureStatus.rawValue
    var primaryMetric: Double
    var primaryMetricUnitRaw: String // PostureResult.MetricUnit.rawValue
    var confidence: Double
    var advice: String?

    var session: SessionRecord?

    init(
        id: UUID = UUID(),
        type: PostureType,
        status: PostureStatus,
        primaryMetric: Double,
        primaryMetricUnit: PostureResult.MetricUnit,
        confidence: Double,
        advice: String?
    ) {
        self.id = id
        self.typeRaw = type.rawValue
        self.statusRaw = status.rawValue
        self.primaryMetric = primaryMetric
        self.primaryMetricUnitRaw = primaryMetricUnit.rawValue
        self.confidence = confidence
        self.advice = advice
    }

    // 편의 접근자
    var type: PostureType { PostureType(rawValue: typeRaw) ?? .forwardHead }
    var status: PostureStatus { PostureStatus(rawValue: statusRaw) ?? .unmeasurable }
    var primaryMetricUnit: PostureResult.MetricUnit {
        PostureResult.MetricUnit(rawValue: primaryMetricUnitRaw) ?? .degree
    }
}
