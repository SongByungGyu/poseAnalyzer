import XCTest
import Vision
@testable import PoseAnalyzer

final class ForwardHeadEvaluatorTests: XCTestCase {

    let evaluator = ForwardHeadEvaluator()

    func test_정상_각도_175도_normal_반환() {
        let frame = PoseFrame.sideViewWithAngle(
            175,
            atJoints: (.leftEar, .leftShoulder, .leftHip)
        )
        let result = evaluator.evaluate(frame)
        XCTAssertEqual(result.status, .normal)
        XCTAssertEqual(result.primaryMetric, 175, accuracy: 1)
    }

    func test_경계_각도_165도_caution_반환() {
        let frame = PoseFrame.sideViewWithAngle(
            165,
            atJoints: (.leftEar, .leftShoulder, .leftHip)
        )
        let result = evaluator.evaluate(frame)
        XCTAssertEqual(result.status, .caution)
    }

    func test_의심_각도_150도_suspect_반환() {
        let frame = PoseFrame.sideViewWithAngle(
            150,
            atJoints: (.leftEar, .leftShoulder, .leftHip)
        )
        let result = evaluator.evaluate(frame)
        XCTAssertEqual(result.status, .suspect)
    }

    func test_관절_누락_unmeasurable_반환() {
        let frame = PoseFrame.empty()
        let result = evaluator.evaluate(frame)
        XCTAssertEqual(result.status, .unmeasurable)
    }

    func test_신뢰도_낮음_unmeasurable_반환() {
        let frame = PoseFrame.sideViewWithAngle(
            175,
            atJoints: (.leftEar, .leftShoulder, .leftHip),
            confidence: 0.2  // < 0.3
        )
        let result = evaluator.evaluate(frame)
        XCTAssertEqual(result.status, .unmeasurable)
    }

    func test_우측이_더_신뢰도_높으면_우측_사용() {
        // 좌측: 낮은 신뢰도, 우측: 정상
        var joints: [VNHumanBodyPoseObservation.JointName: PoseFrame.Joint] = [:]
        joints[.leftEar] = .init(name: .leftEar, location: .init(x: 0.5, y: 0.7), confidence: 0.1)
        joints[.leftShoulder] = .init(name: .leftShoulder, location: .init(x: 0.5, y: 0.5), confidence: 0.1)
        joints[.leftHip] = .init(name: .leftHip, location: .init(x: 0.5, y: 0.3), confidence: 0.1)
        // 우측: 정상 직선 (각도 180)
        joints[.rightEar] = .init(name: .rightEar, location: .init(x: 0.5, y: 0.7), confidence: 0.9)
        joints[.rightShoulder] = .init(name: .rightShoulder, location: .init(x: 0.5, y: 0.5), confidence: 0.9)
        joints[.rightHip] = .init(name: .rightHip, location: .init(x: 0.5, y: 0.3), confidence: 0.9)

        let frame = PoseFrame(joints: joints, view: .side, imageSize: CGSize(width: 1000, height: 1000))
        let result = evaluator.evaluate(frame)
        XCTAssertEqual(result.status, .normal)
        XCTAssertTrue(result.usedJointNames.contains { $0.contains("right") })
    }
}
