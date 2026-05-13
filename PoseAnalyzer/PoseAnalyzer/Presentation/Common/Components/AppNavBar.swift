import SwiftUI

/// 디자인 시스템 상단 네비게이션 바 (커스텀)
/// 양쪽 44pt 액션 슬롯 + 중앙 제목/부제목
struct AppNavBar: View {
    let title: String
    var subtitle: String? = nil
    var leadingIcon: String? = nil
    var trailingIcon: String? = nil
    var leadingAction: (() -> Void)? = nil
    var trailingAction: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 0) {
            // Leading 44pt slot
            ZStack {
                if let icon = leadingIcon, let action = leadingAction {
                    Button(action: action) {
                        Image(systemName: icon)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Color.brandPrimary)
                    }
                    .accessibilityLabel("뒤로")
                }
            }
            .frame(width: 44, height: 44)

            // Center title
            VStack(spacing: 1) {
                Text(title)
                    .font(.appTitle)
                    .foregroundStyle(Color.fg1)
                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 11, weight: .semibold))
                        .kerning(0.01)
                        .foregroundStyle(Color.fg3)
                }
            }
            .frame(maxWidth: .infinity)

            // Trailing 44pt slot
            ZStack {
                if let icon = trailingIcon, let action = trailingAction {
                    Button(action: action) {
                        Image(systemName: icon)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Color.brandPrimary)
                    }
                }
            }
            .frame(width: 44, height: 44)
        }
        .padding(.horizontal, AppSpacing.s2)
        .frame(height: 44)
    }
}

#Preview {
    VStack(spacing: 8) {
        AppNavBar(title: "PoseAnalyzer", trailingIcon: "gearshape", trailingAction: {})
            .background(Color.bgCanvas)
        AppNavBar(
            title: "정면 사진",
            subtitle: "STEP 1 / 3",
            leadingIcon: "chevron.left",
            leadingAction: {}
        )
        .background(Color.bgCanvas)
        AppNavBar(title: "기록")
            .background(Color.bgCanvas)
    }
    .background(Color.bgCanvas)
}
