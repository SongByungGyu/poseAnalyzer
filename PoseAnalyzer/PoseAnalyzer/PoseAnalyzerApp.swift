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
                        .transition(.opacity)
                        .task {
                            // 1.2초 동안 스플래시 표시 후 메인 탭으로 fade out
                            try? await Task.sleep(for: .seconds(1.2))
                            withAnimation(.easeOut(duration: 0.35)) {
                                showSplash = false
                            }
                        }
                }
            }
        }
    }
}
