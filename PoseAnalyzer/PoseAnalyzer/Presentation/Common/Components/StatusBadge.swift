import SwiftUI

/// 4단계 판정 상태를 표시하는 pill 배지
/// soft (배경 tint) / solid (full color) 두 톤
struct StatusBadge: View {

    enum Tone {
        case soft, solid
    }

    enum Size {
        case small, regular

        var verticalPad: CGFloat { self == .small ? 3 : 5 }
        var horizontalPad: CGFloat { self == .small ? 9 : 11 }
        var fontSize: CGFloat { self == .small ? 11 : 12 }
        var dotSize: CGFloat { self == .small ? 7 : 8 }
    }

    let status: PostureStatus
    var tone: Tone = .soft
    var size: Size = .small

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(tone == .soft ? status.color : Color.white.opacity(0.85))
                .frame(width: size.dotSize, height: size.dotSize)
            Text(status.koreanName)
                .font(.system(size: size.fontSize, weight: .bold))
                .kerning(-0.005)
        }
        .foregroundStyle(textColor)
        .padding(.vertical, size.verticalPad)
        .padding(.horizontal, size.horizontalPad)
        .background(backgroundColor, in: Capsule())
    }

    private var backgroundColor: Color {
        tone == .soft ? status.backgroundColor : status.color
    }
    private var textColor: Color {
        tone == .soft ? status.color : Color.white
    }
}

#Preview {
    VStack(spacing: 16) {
        ForEach([PostureStatus.normal, .caution, .suspect, .unmeasurable], id: \.self) { s in
            HStack(spacing: 12) {
                StatusBadge(status: s, tone: .soft, size: .small)
                StatusBadge(status: s, tone: .soft, size: .regular)
                StatusBadge(status: s, tone: .solid, size: .small)
                StatusBadge(status: s, tone: .solid, size: .regular)
            }
        }
    }
    .padding()
    .background(Color.bgCanvas)
}
