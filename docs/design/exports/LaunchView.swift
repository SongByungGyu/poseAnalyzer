import SwiftUI

/// 앱 첫 실행 화면 (Splash / LaunchScreen 대체)
///
/// 디자인 방향 2 — Full-bleed indigo. 인디고 그라디언트 풀블리드, 마크 + 워드마크.
/// Storyboard 대신 SwiftUI로 작성 — PoseAnalyzer는 SwiftUI 앱이므로
/// `PoseAnalyzerApp.swift`에서 첫 N초 동안 이 뷰를 띄운 후 메인 탭으로 전환합니다.
///
/// 사용 예 (PoseAnalyzerApp.swift):
/// ```swift
/// @main
/// struct PoseAnalyzerApp: App {
///     @State private var showSplash = true
///     var body: some Scene {
///         WindowGroup {
///             ZStack {
///                 AppTabView()
///                 if showSplash {
///                     LaunchView()
///                         .transition(.opacity)
///                         .task {
///                             try? await Task.sleep(for: .seconds(1.2))
///                             withAnimation(.easeOut(duration: 0.35)) {
///                                 showSplash = false
///                             }
///                         }
///                 }
///             }
///         }
///     }
/// }
/// ```
///
/// 또한 진짜 정적 LaunchScreen이 별도로 필요한 경우 — Xcode의
/// **Project → Info → Launch Screen** 설정에서 `Background Color = Pose Indigo
/// (#3B5BDB)`, `Image = LaunchMark`만 지정해두면 SwiftUI LaunchView가 뜨기
/// 직전 1프레임이 자연스럽게 이어집니다.
struct LaunchView: View {

    var body: some View {
        ZStack {
            // 1) 인디고 그라디언트 풀블리드
            LinearGradient(
                colors: [
                    Color(red: 0x5B/255, green: 0x6E/255, blue: 0xE8/255),
                    Color(red: 0x3B/255, green: 0x5B/255, blue: 0xDB/255),
                    Color(red: 0x2A/255, green: 0x47/255, blue: 0xC3/255),
                ],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            // 2) 상단에서 내려오는 부드러운 광원 (subtle radial)
            RadialGradient(
                colors: [
                    Color.white.opacity(0.18),
                    Color.white.opacity(0.0),
                ],
                center: UnitPoint(x: 0.5, y: 0.28),
                startRadius: 0,
                endRadius: 360
            )
            .ignoresSafeArea()

            // 3) 마크 + 워드마크
            VStack(spacing: AppSpacing.s5) {
                LaunchMark()
                    .frame(width: 120, height: 120)
                Text("PoseAnalyzer")
                    .font(.system(size: 28, weight: .heavy))
                    .kerning(-0.6)
                    .foregroundStyle(Color.white)
            }
            .offset(y: -32)

            // 4) 하단 캡션
            VStack {
                Spacer()
                Text("POSTURE ANALYSIS · 자세 분석")
                    .font(.system(size: 12, weight: .medium))
                    .tracking(2.0)
                    .foregroundStyle(Color.white.opacity(0.65))
                    .padding(.bottom, AppSpacing.s9)
            }
        }
        // LaunchView는 항상 라이트/다크 무관하게 인디고 톤이 정체성이므로 강제
        .preferredColorScheme(.light)
    }
}

/// 브랜드 마크 (Aligned column — 머리 + 어깨 바 + 척추 + 골반 바 + mint 정렬 도트)
/// AppIcon과 시각 언어 동일.
struct LaunchMark: View {
    var body: some View {
        Canvas { ctx, size in
            // viewBox 200×200으로 그리고 size에 맞춰 scale
            let s = min(size.width, size.height) / 200.0
            let t = CGAffineTransform(scaleX: s, y: s)
                .translatedBy(x: (size.width / s - 200) / 2,
                              y: (size.height / s - 200) / 2)
            ctx.concatenate(t)

            // 머리
            let headRect = CGRect(x: 86, y: 42, width: 28, height: 28)
            ctx.fill(Path(ellipseIn: headRect), with: .color(.white))

            // 어깨 바
            var shoulder = Path()
            shoulder.move(to: CGPoint(x: 60, y: 80))
            shoulder.addLine(to: CGPoint(x: 140, y: 80))
            ctx.stroke(shoulder, with: .color(.white),
                       style: StrokeStyle(lineWidth: 8, lineCap: .round))

            // 척추 컬럼
            var spine = Path()
            spine.move(to: CGPoint(x: 100, y: 74))
            spine.addLine(to: CGPoint(x: 100, y: 140))
            ctx.stroke(spine, with: .color(.white),
                       style: StrokeStyle(lineWidth: 10, lineCap: .round))

            // 골반 바
            var hip = Path()
            hip.move(to: CGPoint(x: 74, y: 136))
            hip.addLine(to: CGPoint(x: 126, y: 136))
            ctx.stroke(hip, with: .color(.white),
                       style: StrokeStyle(lineWidth: 8, lineCap: .round))

            // mint 정렬 도트 (center of gravity)
            let mint = Color(red: 0x56/255, green: 0xBA/255, blue: 0xB0/255)
            let dotRect = CGRect(x: 95.5, y: 102.5, width: 9, height: 9)
            ctx.fill(Path(ellipseIn: dotRect), with: .color(mint))
        }
    }
}

#Preview {
    LaunchView()
}
