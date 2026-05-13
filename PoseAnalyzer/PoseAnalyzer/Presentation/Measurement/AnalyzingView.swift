import SwiftUI

/// 분석 중 표시 화면 — "관절 인식 중…" → "자세 분석 중…"
struct AnalyzingView: View {

    let phase: String

    @State private var pulse = false

    var body: some View {
        VStack(spacing: AppSpacing.s5) {
            Spacer()

            ZStack {
                Circle()
                    .stroke(Color.brandPrimary.opacity(0.15), lineWidth: 6)
                    .frame(width: 120, height: 120)
                Circle()
                    .stroke(Color.brandPrimary, lineWidth: 6)
                    .frame(width: 120, height: 120)
                    .scaleEffect(pulse ? 1.0 : 0.85)
                    .opacity(pulse ? 0 : 1.0)
                    .animation(
                        .easeInOut(duration: 1.4)
                            .repeatForever(autoreverses: false),
                        value: pulse
                    )
                Image(systemName: "figure.stand")
                    .font(.system(size: 48, weight: .light))
                    .foregroundStyle(Color.brandPrimary)
            }
            .onAppear { pulse = true }

            VStack(spacing: AppSpacing.s2) {
                Text("분석 중…")
                    .font(.appH2)
                    .foregroundStyle(Color.fg1)
                Text(phase)
                    .font(.appCallout)
                    .foregroundStyle(Color.fg2)
                    .id(phase)
                    .transition(.opacity)
                    .animation(.easeOut(duration: 0.22), value: phase)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.bgCanvas)
        .toolbar(.hidden)
    }
}

#Preview {
    AnalyzingView(phase: "관절 인식 중…")
}
