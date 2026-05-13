import Foundation
import SwiftData

/// 한 번의 측정 세션 (정면+측면 사진 1세트)
@Model
final class SessionRecord {
    @Attribute(.unique) var id: UUID
    var measuredAt: Date
    var frontImagePath: String      // 상대 경로 (Documents 기준)
    var sideImagePath: String
    var heightCmAtMeasure: Double?

    @Relationship(deleteRule: .cascade, inverse: \PostureRecord.session)
    var postures: [PostureRecord]

    // 비대칭 결과
    var asymmetryShoulderCm: Double?
    var asymmetryShoulderRatio: Double
    var asymmetryShoulderAngle: Double
    var asymmetryShoulderDirectionRaw: String
    var asymmetryHipCm: Double?
    var asymmetryHipRatio: Double
    var asymmetryHipAngle: Double
    var asymmetryHipDirectionRaw: String

    init(
        id: UUID = UUID(),
        measuredAt: Date = .now,
        frontImagePath: String,
        sideImagePath: String,
        heightCmAtMeasure: Double?,
        asymmetryShoulderCm: Double?,
        asymmetryShoulderRatio: Double,
        asymmetryShoulderAngle: Double,
        asymmetryShoulderDirection: AsymmetryResult.Direction,
        asymmetryHipCm: Double?,
        asymmetryHipRatio: Double,
        asymmetryHipAngle: Double,
        asymmetryHipDirection: AsymmetryResult.Direction
    ) {
        self.id = id
        self.measuredAt = measuredAt
        self.frontImagePath = frontImagePath
        self.sideImagePath = sideImagePath
        self.heightCmAtMeasure = heightCmAtMeasure
        self.postures = []
        self.asymmetryShoulderCm = asymmetryShoulderCm
        self.asymmetryShoulderRatio = asymmetryShoulderRatio
        self.asymmetryShoulderAngle = asymmetryShoulderAngle
        self.asymmetryShoulderDirectionRaw = asymmetryShoulderDirection.rawValue
        self.asymmetryHipCm = asymmetryHipCm
        self.asymmetryHipRatio = asymmetryHipRatio
        self.asymmetryHipAngle = asymmetryHipAngle
        self.asymmetryHipDirectionRaw = asymmetryHipDirection.rawValue
    }

    // 편의 접근자
    var asymmetryShoulderDirection: AsymmetryResult.Direction {
        AsymmetryResult.Direction(rawValue: asymmetryShoulderDirectionRaw) ?? .balanced
    }
    var asymmetryHipDirection: AsymmetryResult.Direction {
        AsymmetryResult.Direction(rawValue: asymmetryHipDirectionRaw) ?? .balanced
    }
}
