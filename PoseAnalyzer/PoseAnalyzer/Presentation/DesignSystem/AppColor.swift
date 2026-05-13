import SwiftUI

/// 디자인 시스템 컬러 토큰
/// 출처: docs/design/colors_and_type.css
/// 다크모드는 Color literal에 light/dark variant 직접 정의 (Asset Catalog 없이)
extension Color {

    // MARK: - Brand
    /// 딥 네이비 — 워드마크, 라이트 모드 primary 텍스트
    static let brandInk = Color(light: 0x0F1B2D, dark: 0xF2F4F8)
    /// Pose Indigo — primary CTA, focus, links
    static let brandPrimary = Color(light: 0x3B5BDB, dark: 0x5B6EE8)
    /// CTA pressed 상태
    static let brandPrimaryPress = Color(light: 0x2A47C3, dark: 0x4054BB)
    /// Tinted background (selected 상태)
    static let brandPrimarySoft = Color(
        light: 0xE6EBFB, lightAlpha: 1.0,
        dark: 0x5B6EE8, darkAlpha: 0.18
    )
    /// 부드러운 보라-인디고 (강조용)
    static let brandAccent = Color(light: 0x5B6EE8, dark: 0x7A8BEC)
    /// 민트 — wellness, 보조 강조, 관절 오버레이 노드
    static let brandMint = Color(light: 0x56BAB0, dark: 0x68C9C0)

    // MARK: - Status (4단계 판정)
    static let statusNormal = Color(light: 0x22A06B, dark: 0x2EB97D)
    static let statusNormalBG = Color(
        light: 0xE3F4EC, lightAlpha: 1.0,
        dark: 0x22A06B, darkAlpha: 0.18
    )
    static let statusCaution = Color(light: 0xD9A106, dark: 0xE8B523)
    static let statusCautionBG = Color(
        light: 0xFBF1D2, lightAlpha: 1.0,
        dark: 0xD9A106, darkAlpha: 0.18
    )
    static let statusSuspect = Color(light: 0xE0683A, dark: 0xEB804E)
    static let statusSuspectBG = Color(
        light: 0xFBE5D7, lightAlpha: 1.0,
        dark: 0xE0683A, darkAlpha: 0.18
    )
    static let statusUnknown = Color(light: 0x8A94A6, dark: 0xA2ABBC)
    static let statusUnknownBG = Color(
        light: 0xECEEF2, lightAlpha: 1.0,
        dark: 0x8A94A6, darkAlpha: 0.18
    )

    // MARK: - Surfaces
    /// 앱 배경 (라이트는 따뜻한 회색, 다크는 깊은 슬레이트)
    static let bgCanvas = Color(light: 0xF4F6FA, dark: 0x0B0F18)
    /// 카드/시트 표면
    static let bgSurface = Color(light: 0xFFFFFF, dark: 0x161B26)
    /// 중첩 카드
    static let bgSurface2 = Color(light: 0xF7F8FA, dark: 0x1F2532)

    // MARK: - Foregrounds
    /// 1차 텍스트 (가장 진함)
    static let fg1 = Color(light: 0x0F1B2D, dark: 0xF2F4F8)
    /// 2차 텍스트 (부제목, 설명)
    static let fg2 = Color(light: 0x4F5868, dark: 0xB4BCCB)
    /// 3차 텍스트 (caption, hint)
    static let fg3 = Color(light: 0x707A8E, dark: 0x8A94A6)
    /// disabled / 비활성
    static let fg4 = Color(light: 0xA2ABBC, dark: 0x5C6577)

    // MARK: - Borders
    static let border1 = Color(light: 0xE2E6EE, dark: 0x232A38)
    static let border2 = Color(light: 0xEEF1F5, dark: 0x1F2532)
    static let borderStrong = Color(light: 0xCBD2DE, dark: 0x353D4B)

    // MARK: - Helpers
    /// Hex 정수 + 옵션 alpha + light/dark variant
    fileprivate init(light: Int, lightAlpha: Double = 1.0, dark: Int, darkAlpha: Double = 1.0) {
        self.init(uiColor: UIColor { trait in
            let hex = (trait.userInterfaceStyle == .dark) ? dark : light
            let alpha = (trait.userInterfaceStyle == .dark) ? darkAlpha : lightAlpha
            return UIColor(red:   Double((hex >> 16) & 0xFF) / 255.0,
                           green: Double((hex >> 8) & 0xFF) / 255.0,
                           blue:  Double(hex & 0xFF) / 255.0,
                           alpha: alpha)
        })
    }
}

// MARK: - PostureStatus → Color 매핑 헬퍼

extension PostureStatus {
    /// 카드/뱃지 메인 색상 (foreground)
    var color: Color {
        switch self {
        case .normal: return .statusNormal
        case .caution: return .statusCaution
        case .suspect: return .statusSuspect
        case .unmeasurable: return .statusUnknown
        }
    }
    /// 뱃지 배경 (soft)
    var backgroundColor: Color {
        switch self {
        case .normal: return .statusNormalBG
        case .caution: return .statusCautionBG
        case .suspect: return .statusSuspectBG
        case .unmeasurable: return .statusUnknownBG
        }
    }
    /// SF Symbol 이름 (색만 의존하지 않음 — 접근성)
    var iconName: String {
        switch self {
        case .normal: return "checkmark.circle.fill"
        case .caution: return "exclamationmark.circle.fill"
        case .suspect: return "exclamationmark.triangle.fill"
        case .unmeasurable: return "questionmark.circle.fill"
        }
    }
}

// MARK: - Preview

#Preview("Light", traits: .sizeThatFitsLayout) {
    AppColorPreview()
        .preferredColorScheme(.light)
        .padding()
}

#Preview("Dark", traits: .sizeThatFitsLayout) {
    AppColorPreview()
        .preferredColorScheme(.dark)
        .padding()
}

private struct AppColorPreview: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                section("Brand", colors: [
                    ("ink", .brandInk),
                    ("primary", .brandPrimary),
                    ("primary press", .brandPrimaryPress),
                    ("primary soft", .brandPrimarySoft),
                    ("accent", .brandAccent),
                    ("mint", .brandMint),
                ])
                section("Status", colors: [
                    ("normal", .statusNormal),
                    ("caution", .statusCaution),
                    ("suspect", .statusSuspect),
                    ("unknown", .statusUnknown),
                ])
                section("Foreground", colors: [
                    ("fg1", .fg1), ("fg2", .fg2), ("fg3", .fg3), ("fg4", .fg4),
                ])
                section("Surface", colors: [
                    ("canvas", .bgCanvas),
                    ("surface", .bgSurface),
                    ("surface2", .bgSurface2),
                ])
            }
        }
        .background(Color.bgCanvas)
    }

    private func section(_ title: String, colors: [(String, Color)]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.subheadline).bold().foregroundStyle(Color.fg2)
            ForEach(colors, id: \.0) { name, color in
                HStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(color)
                        .frame(width: 36, height: 24)
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.border1, lineWidth: 1))
                    Text(name).font(.caption).foregroundStyle(Color.fg1)
                }
            }
        }
    }
}
