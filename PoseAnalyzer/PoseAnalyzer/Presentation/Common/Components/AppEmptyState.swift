import SwiftUI

/// 데이터 없음 안내 (기록 0개, 검색 결과 없음 등)
struct AppEmptyState<Action: View>: View {
    let icon: String          // SF Symbol
    let title: String
    var message: String? = nil
    @ViewBuilder var action: () -> Action

    var body: some View {
        VStack(spacing: AppSpacing.s4) {
            Image(systemName: icon)
                .font(.system(size: 44, weight: .light))
                .foregroundStyle(Color.fg4)
            VStack(spacing: 4) {
                Text(title)
                    .font(.appH3)
                    .foregroundStyle(Color.fg2)
                    .multilineTextAlignment(.center)
                if let message {
                    Text(message)
                        .font(.appCaption)
                        .foregroundStyle(Color.fg3)
                        .multilineTextAlignment(.center)
                }
            }
            action()
        }
        .padding(.horizontal, AppSpacing.s6)
        .padding(.vertical, AppSpacing.s7)
        .frame(maxWidth: .infinity)
    }
}

extension AppEmptyState where Action == EmptyView {
    init(icon: String, title: String, message: String? = nil) {
        self.icon = icon
        self.title = title
        self.message = message
        self.action = { EmptyView() }
    }
}

#Preview {
    VStack(spacing: 32) {
        AppEmptyState(
            icon: "chart.bar.fill",
            title: "아직 기록이 없습니다",
            message: "측정을 시작하면 여기에 표시됩니다."
        )
        AppEmptyState(
            icon: "figure.stand",
            title: "측정을 시작해보세요"
        ) {
            AppButton("측정 시작", size: .medium) {}
                .padding(.horizontal, 32)
        }
    }
    .background(Color.bgCanvas)
}
