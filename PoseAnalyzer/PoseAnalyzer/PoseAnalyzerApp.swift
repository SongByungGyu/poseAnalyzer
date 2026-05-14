import SwiftUI
import SwiftData

@main
struct PoseAnalyzerApp: App {

    @StateObject private var dependencies = AppDependencies()
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                AppTabView()
                    .environmentObject(dependencies)
                    .environment(\.dependencies, dependencies)
                    .modelContainer(dependencies.modelContainer)

                if showSplash {
                    LaunchView()
                        // 사라질 때: 불투명도 + 살짝 확대 (앞으로 살짝 다가오며 페이드)
                        .transition(.asymmetric(
                            insertion: .identity,
                            removal: .opacity.combined(with: .scale(scale: 1.04))
                        ))
                        .task {
                            // 짧게 표시 후 부드럽게 fade. LaunchScreen storyboard가
                            // 콜드 스타트 동안 인디고로 가려주므로 LaunchView 자체는
                            // 마크/워드마크 확인 정도 시간만 노출하면 충분.
                            try? await Task.sleep(for: .seconds(0.7))
                            withAnimation(.smooth(duration: 0.4)) {
                                showSplash = false
                            }
                        }
                }
            }
        }
    }
}
