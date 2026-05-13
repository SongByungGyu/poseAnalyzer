import SwiftUI

/// 디자인 시스템 버튼 — 4 variant × 3 size
struct AppButton<Label: View>: View {

    enum Variant {
        case primary, secondary, ghost, danger

        var bg: Color {
            switch self {
            case .primary: return .brandPrimary
            case .secondary: return .brandPrimarySoft
            case .ghost: return .clear
            case .danger: return .statusSuspect
            }
        }
        var fg: Color {
            switch self {
            case .primary, .danger: return .white
            case .secondary, .ghost: return .brandPrimary
            }
        }
    }

    enum Size {
        case large, medium, small

        var height: CGFloat { self == .large ? 56 : self == .medium ? 48 : 36 }
        var radius: CGFloat { self == .large ? 16 : self == .medium ? 14 : 10 }
        var fontSize: CGFloat { self == .large ? 17 : self == .medium ? 16 : 14 }
        var horizontalPad: CGFloat { self == .large ? 24 : self == .medium ? 20 : 14 }
    }

    var variant: Variant = .primary
    var size: Size = .large
    var isLoading: Bool = false
    var isDisabled: Bool = false
    var action: () -> Void
    @ViewBuilder var label: () -> Label

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView().tint(variant.fg)
                } else {
                    label()
                }
            }
            .font(.system(size: size.fontSize, weight: .semibold))
            .kerning(-0.005)
            .foregroundStyle(isDisabled ? Color.fg4 : variant.fg)
            .frame(maxWidth: .infinity, minHeight: size.height)
            .padding(.horizontal, size.horizontalPad)
            .background(
                (isDisabled ? Color.statusUnknownBG : variant.bg)
                    .opacity(isPressed ? 0.85 : 1.0),
                in: RoundedRectangle(cornerRadius: size.radius, style: .continuous)
            )
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .animation(.easeOut(duration: 0.12), value: isPressed)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled || isLoading)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

/// 텍스트만 받는 편의 이니셜라이저
extension AppButton where Label == Text {
    init(
        _ title: String,
        variant: Variant = .primary,
        size: Size = .large,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.variant = variant
        self.size = size
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.action = action
        self.label = { Text(title) }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 12) {
            AppButton("측정 시작", variant: .primary, size: .large) {}
            AppButton("라이브러리에서 선택", variant: .secondary, size: .large) {}
            AppButton("ghost", variant: .ghost, size: .medium) {}
            AppButton("삭제", variant: .danger, size: .medium) {}
            AppButton("비활성", variant: .primary, size: .large, isDisabled: true) {}
            AppButton("로딩 중", variant: .primary, size: .large, isLoading: true) {}
            AppButton(variant: .primary, size: .medium, action: {}) {
                HStack(spacing: 6) {
                    Image(systemName: "camera.fill")
                    Text("촬영")
                }
            }
        }
        .padding()
    }
    .background(Color.bgCanvas)
}
