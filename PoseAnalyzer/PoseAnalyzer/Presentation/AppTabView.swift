import SwiftUI

/// 앱 루트 — 측정/기록 2개 탭 골격
/// 각 탭의 실제 내용은 Plan 2b, 2c에서 채움
struct AppTabView: View {

    @State private var selectedTab: Tab = .measurement

    enum Tab: String, Hashable {
        case measurement, history
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            // 측정 탭 (Plan 2b에서 채움)
            MeasurementTabPlaceholder()
                .tabItem {
                    Image(systemName: "camera.fill")
                    Text("측정")
                }
                .tag(Tab.measurement)

            // 기록 탭 (Plan 2c에서 채움)
            HistoryTabPlaceholder()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("기록")
                }
                .tag(Tab.history)
        }
        .tint(Color.brandPrimary)
    }
}

/// 측정 탭 임시 화면 (Plan 2b에서 HomeView 등으로 교체)
private struct MeasurementTabPlaceholder: View {
    var body: some View {
        NavigationStack {
            VStack {
                AppEmptyState(
                    icon: "figure.stand",
                    title: "측정 화면",
                    message: "Plan 2b에서 작성됩니다."
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.bgCanvas)
        }
    }
}

/// 기록 탭 임시 화면 (Plan 2c에서 HistoryListView로 교체)
private struct HistoryTabPlaceholder: View {
    var body: some View {
        NavigationStack {
            AppEmptyState(
                icon: "chart.bar.fill",
                title: "기록 화면",
                message: "Plan 2c에서 작성됩니다."
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.bgCanvas)
        }
    }
}

#Preview("Light") {
    AppTabView().preferredColorScheme(.light)
}

#Preview("Dark") {
    AppTabView().preferredColorScheme(.dark)
}
