import SwiftUI
import SwiftData

@main
struct PoseAnalyzerApp: App {

    @StateObject private var dependencies = AppDependencies()

    var body: some Scene {
        WindowGroup {
            AppTabView()
                .environmentObject(dependencies)
                .environment(\.dependencies, dependencies)
                .modelContainer(dependencies.modelContainer)
        }
    }
}
