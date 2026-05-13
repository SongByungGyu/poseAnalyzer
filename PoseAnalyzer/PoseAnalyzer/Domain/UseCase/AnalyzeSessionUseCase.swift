import Foundation
import UIKit

/// View가 호출하는 단일 진입점: 정면+측면 사진 → SessionReport
final class AnalyzeSessionUseCase {

    private let detector: PoseDetector
    private let evaluators: [PostureEvaluator]
    private let asymmetryAnalyzer: AsymmetryAnalyzer

    init(detector: PoseDetector, evaluators: [PostureEvaluator], asymmetryAnalyzer: AsymmetryAnalyzer) {
        self.detector = detector
        self.evaluators = evaluators
        self.asymmetryAnalyzer = asymmetryAnalyzer
    }

    func analyze(front: UIImage, side: UIImage, heightCm: Double?) async throws -> SessionReport {
        // 1) 두 사진 병렬 분석
        async let frontFrameTask = detector.detect(image: front, view: .front)
        async let sideFrameTask = detector.detect(image: side, view: .side)
        let frontFrame = try await frontFrameTask
        let sideFrame = try await sideFrameTask

        // 2) 각 Evaluator 실행 (해당 view에 맞춰 분배)
        var results: [PostureResult] = []
        for evaluator in evaluators {
            let frame = (evaluator.requiredView == .front) ? frontFrame : sideFrame
            results.append(evaluator.evaluate(frame))
        }

        // 3) 비대칭 분석 (정면 사진)
        let asymmetry = asymmetryAnalyzer.analyze(frontFrame, heightCm: heightCm)

        return SessionReport(
            id: UUID(),
            measuredAt: .now,
            frontImage: front,
            sideImage: side,
            frontFrame: frontFrame,
            sideFrame: sideFrame,
            postures: results,
            asymmetry: asymmetry,
            heightCmAtMeasure: heightCm
        )
    }
}
