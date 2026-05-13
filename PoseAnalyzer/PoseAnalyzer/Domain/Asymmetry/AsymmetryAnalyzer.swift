import Foundation

/// 정면 사진 기반 좌우 비대칭 분석
protocol AsymmetryAnalyzer {
    /// - Parameters:
    ///   - frontFrame: 정면 사진 PoseFrame
    ///   - heightCm: 사용자 키 (옵션, 있으면 cm 환산)
    func analyze(_ frontFrame: PoseFrame, heightCm: Double?) -> AsymmetryResult
}
