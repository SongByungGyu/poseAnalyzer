import SwiftUI

/// 디자인 시스템 카드 — 흰 배경 + 라운드 + 가벼운 그림자 + 1px border
struct AppCard<Content: View>: View {

    enum Style {
        case standard  // surface 배경 + shadow + border
        case nested    // surface2 배경 + border only (그림자 없음)
    }

    var style: Style = .standard
    var padding: CGFloat = AppSpacing.s4
    var radius: CGFloat = AppRadius.lg
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .background(background, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .strokeBorder(Color.border1, lineWidth: 1)
            )
            .modifier(ConditionalShadow(applied: style == .standard))
    }

    private var background: Color {
        style == .standard ? Color.bgSurface : Color.bgSurface2
    }
}

private struct ConditionalShadow: ViewModifier {
    let applied: Bool
    func body(content: Content) -> some View {
        if applied { content.appCardShadow() }
        else { content }
    }
}

#Preview {
    VStack(spacing: 16) {
        AppCard {
            VStack(alignment: .leading, spacing: 6) {
                Text("거북목").font(.appH3)
                Text("측정 각도 172°").font(.appCaption).foregroundStyle(Color.fg2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        AppCard(style: .nested) {
            Text("Nested card").font(.appBody)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    .padding()
    .background(Color.bgCanvas)
}
