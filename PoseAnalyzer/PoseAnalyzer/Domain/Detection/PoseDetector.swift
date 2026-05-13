import UIKit

/// 사진 또는 영상 프레임에서 사람 관절을 검출하는 책임
protocol PoseDetector {
    /// 단일 사진에서 PoseFrame 추출
    /// - Parameters:
    ///   - image: 분석할 사진
    ///   - view: 정면/측면 (PoseFrame에 메타로 들어감)
    /// - Throws: `PoseDetectionError`
    func detect(image: UIImage, view: SessionView) async throws -> PoseFrame
}

/// PoseDetector가 던질 수 있는 에러
enum PoseDetectionError: LocalizedError, Equatable {
    case noPersonDetected
    case multiplePersonsDetected(count: Int)
    case visionFailed(message: String)
    case invalidImage

    var errorDescription: String? {
        switch self {
        case .noPersonDetected:
            return "사람을 인식할 수 없습니다."
        case .multiplePersonsDetected(let n):
            return "여러 명(\(n)명)이 감지되었습니다. 한 명만 보이는 사진을 사용해주세요."
        case .visionFailed(let msg):
            return "분석 중 오류가 발생했습니다: \(msg)"
        case .invalidImage:
            return "사진 형식이 올바르지 않습니다."
        }
    }
}
