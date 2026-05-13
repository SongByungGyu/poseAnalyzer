import SwiftUI
import CoreGraphics

/// 4pt 기준 간격 (iOS 컨벤션)
enum AppSpacing {
    static let s1: CGFloat = 4
    static let s2: CGFloat = 8
    static let s3: CGFloat = 12
    static let s4: CGFloat = 16
    static let s5: CGFloat = 20
    static let s6: CGFloat = 24
    static let s7: CGFloat = 32
    static let s8: CGFloat = 40
    static let s9: CGFloat = 56
    static let s10: CGFloat = 72
}

/// 라운드 코너 반지름
enum AppRadius {
    /// 작은 칩
    static let xs: CGFloat = 6
    /// 작은 배지, 칩
    static let sm: CGFloat = 10
    /// 버튼, 입력, 리스트 행
    static let md: CGFloat = 14
    /// 카드, 시트
    static let lg: CGFloat = 20
    /// bottom sheet 상단, 대형 카드
    static let xl: CGFloat = 28
    /// pill 형태 (상태 배지, 세그먼트)
    static let pill: CGFloat = 999
}

/// 그림자 토큰 (View modifier)
extension View {
    /// 카드 그림자 — 라이트/다크 자동 조절
    func appCardShadow() -> some View {
        modifier(AppCardShadowModifier())
    }
    /// 모달/팝업 그림자 — 더 강한 elevation
    func appPopShadow() -> some View {
        modifier(AppPopShadowModifier())
    }
}

private struct AppCardShadowModifier: ViewModifier {
    @Environment(\.colorScheme) private var scheme
    func body(content: Content) -> some View {
        let isDark = scheme == .dark
        return content
            .shadow(
                color: .black.opacity(isDark ? 0.40 : 0.04),
                radius: isDark ? 2 : 1, x: 0, y: 1
            )
            .shadow(
                color: .black.opacity(isDark ? 0.35 : 0.05),
                radius: isDark ? 12 : 8, x: 0, y: isDark ? 8 : 4
            )
    }
}

private struct AppPopShadowModifier: ViewModifier {
    @Environment(\.colorScheme) private var scheme
    func body(content: Content) -> some View {
        let isDark = scheme == .dark
        return content
            .shadow(
                color: .black.opacity(isDark ? 0.55 : 0.08),
                radius: isDark ? 16 : 6, x: 0, y: 4
            )
            .shadow(
                color: .black.opacity(isDark ? 0.30 : 0.10),
                radius: isDark ? 24 : 16, x: 0, y: 12
            )
    }
}
