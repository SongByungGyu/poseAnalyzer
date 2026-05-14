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
                            // 1.2초 동안 스플래시 표시 후 메인 탭으로 부드럽게 fade out
                            try? await Task.sleep(for: .seconds(1.2))
                            withAnimation(.smooth(duration: 0.55)) {
                                showSplash = false
                            }
                        }
                }
            }
        }
    }
}
