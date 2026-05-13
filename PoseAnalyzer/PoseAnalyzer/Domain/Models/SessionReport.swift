import Foundation
import UIKit

/// 한 세션의 모든 분석 결과를 묶은 메모리 객체 (저장 전 단계)
struct SessionReport: Equatable {
    let id: UUID
    let measuredAt: Date
    let frontImage: UIImage
    let sideImage: UIImage
    let frontFrame: PoseFrame
    let sideFrame: PoseFrame
    let postures: [PostureResult]    // 8개 (자세 종류별)
    let asymmetry: AsymmetryResult
    let heightCmAtMeasure: Double?

    /// 특정 자세 결과 조회
    func posture(of type: PostureType) -> PostureResult? {
        postures.first { $0.type == type }
    }

    static func == (lhs: SessionReport, rhs: SessionReport) -> Bool {
        lhs.id == rhs.id &&
        lhs.measuredAt == rhs.measuredAt &&
        lhs.postures == rhs.postures &&
        lhs.asymmetry == rhs.asymmetry &&
        lhs.heightCmAtMeasure == rhs.heightCmAtMeasure
        // UIImage, PoseFrame은 비교 생략 (id로 충분)
    }
}
