import UIKit
@testable import PoseAnalyzer

final class MockPoseDetector: PoseDetector {
    var frontFrameToReturn: PoseFrame?
    var sideFrameToReturn: PoseFrame?
    var errorToThrow: Error?

    func detect(image: UIImage, view: SessionView) async throws -> PoseFrame {
        if let error = errorToThrow {
            throw error
        }
        switch view {
        case .front:
            return frontFrameToReturn ?? .empty(view: .front)
        case .side:
            return sideFrameToReturn ?? .empty(view: .side)
        }
    }
}
