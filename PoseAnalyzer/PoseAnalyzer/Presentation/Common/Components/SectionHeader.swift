import SwiftUI

/// 섹션 제목 + 옵션 액션 버튼
struct SectionHeader<Trailing: View>: View {
    let title: String
    var subtitle: String? = nil
    @ViewBuilder var trailing: () -> Trailing

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.appH3)
                    .foregroundStyle(Color.fg1)
                if let subtitle {
                    Text(subtitle)
                        .font(.appCaption)
                        .foregroundStyle(Color.fg3)
                }
            }
            Spacer()
            trailing()
        }
    }
}

extension SectionHeader where Trailing == EmptyView {
    init(_ title: String, subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.trailing = { EmptyView() }
    }
}

#Preview {
    VStack(spacing: 24) {
        SectionHeader("최근 측정")
        SectionHeader("분석 가능한 자세 8가지", subtitle: "정면 3 + 측면 5")
        SectionHeader(title: "기록") {
            Button("전체 보기 ›") {}
                .font(.appCaption)
                .foregroundStyle(Color.brandPrimary)
        }
    }
    .padding()
    .background(Color.bgCanvas)
}
