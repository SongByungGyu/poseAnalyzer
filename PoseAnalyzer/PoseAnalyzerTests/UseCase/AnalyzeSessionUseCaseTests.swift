import XCTest
import Vision
@testable import PoseAnalyzer

final class AnalyzeSessionUseCaseTests: XCTestCase {

    func test_정상_세션_8개_PostureResult_반환() async throws {
        let detector = MockPoseDetector()
        // 정면 사진: 어깨/엉덩이/머리 등
        detector.frontFrameToReturn = PoseFrame.make(view: .front, [
            (.leftShoulder, CGPoint(x: 0.4, y: 0.7)),
            (.rightShoulder, CGPoint(x: 0.6, y: 0.7)),
            (.leftHip, CGPoint(x: 0.4, y: 0.4)),
            (.rightHip, CGPoint(x: 0.6, y: 0.4)),
            (.leftEar, CGPoint(x: 0.45, y: 0.85)),
            (.rightEar, CGPoint(x: 0.55, y: 0.85)),
            (.leftKnee, CGPoint(x: 0.4, y: 0.25)),
            (.rightKnee, CGPoint(x: 0.6, y: 0.25)),
            (.leftAnkle, CGPoint(x: 0.4, y: 0.1)),
            (.rightAnkle, CGPoint(x: 0.6, y: 0.1)),
            (.nose, CGPoint(x: 0.5, y: 0.9)),
        ])
        // 측면 사진: 거북목/라운드숄더 등
        detector.sideFrameToReturn = PoseFrame.sideViewWithAngle(180, atJoints: (.leftEar, .leftShoulder, .leftHip))

        let evaluators: [PostureEvaluator] = [
            ForwardHeadEvaluator(),
            RoundShoulderEvaluator(),
            KyphosisEvaluator(),
            AnteriorPelvicTiltEvaluator(),
            KneeHyperextensionEvaluator(),
            ScoliosisEvaluator(),
            HeadTiltEvaluator(),
            KneeAlignmentEvaluator(),
        ]
        let useCase = AnalyzeSessionUseCase(
            detector: detector,
            evaluators: evaluators,
            asymmetryAnalyzer: DefaultAsymmetryAnalyzer()
        )

        let image = UIImage()
        let report = try await useCase.analyze(front: image, side: image, heightCm: 170)

        XCTAssertEqual(report.postures.count, 8)
        XCTAssertEqual(Set(report.postures.map { $0.type }), Set(PostureType.allCases))
        XCTAssertEqual(report.heightCmAtMeasure, 170)
    }

    func test_detector_에러시_throw() async {
        let detector = MockPoseDetector()
        detector.errorToThrow = PoseDetectionError.noPersonDetected

        let useCase = AnalyzeSessionUseCase(
            detector: detector,
            evaluators: [],
            asymmetryAnalyzer: DefaultAsymmetryAnalyzer()
        )

        do {
            _ = try await useCase.analyze(front: UIImage(), side: UIImage(), heightCm: nil)
            XCTFail("에러를 던져야 함")
        } catch let error as PoseDetectionError {
            XCTAssertEqual(error, PoseDetectionError.noPersonDetected)
        } catch {
            XCTFail("예상하지 못한 에러: \(error)")
        }
    }
}
