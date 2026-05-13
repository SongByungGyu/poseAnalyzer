import Combine
import Foundation
import SwiftData
import UIKit

/// 앱 전역 의존성을 보관하고 주입하는 단순 Service Locator
/// SwiftUI Environment를 통해 View에 전달
@MainActor
final class AppDependencies: ObservableObject {

    let modelContainer: ModelContainer
    let imageStore: ImageStore
    let sessionRepository: SessionRepository
    let userProfileRepository: UserProfileRepository
    let analyzeSessionUseCase: AnalyzeSessionUseCase

    init(modelContainer: ModelContainer? = nil) {
        // 1) ModelContainer
        let schema = Schema([
            UserProfile.self,
            SessionRecord.self,
            PostureRecord.self,
        ])
        if let container = modelContainer {
            self.modelContainer = container
        } else {
            do {
                let config = ModelConfiguration(schema: schema)
                self.modelContainer = try ModelContainer(for: schema, configurations: [config])
            } catch {
                fatalError("ModelContainer 생성 실패: \(error)")
            }
        }

        // 2) ImageStore
        self.imageStore = ImageStore()

        // 3) Repository
        let context = self.modelContainer.mainContext
        self.sessionRepository = SessionRepository(context: context, imageStore: imageStore)
        self.userProfileRepository = UserProfileRepository(context: context)

        // 4) Domain
        let detector: PoseDetector = VisionPoseDetector()
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
        let asymmetryAnalyzer: AsymmetryAnalyzer = DefaultAsymmetryAnalyzer()
        self.analyzeSessionUseCase = AnalyzeSessionUseCase(
            detector: detector,
            evaluators: evaluators,
            asymmetryAnalyzer: asymmetryAnalyzer
        )
    }
}
