# PoseAnalyzer UI Foundation 구현 계획 (Plan 2a/2d)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development. Steps use checkbox (`- [ ]`) syntax.

**Goal:** UI 구현의 시각 토대 구축 — 디자인 시스템(`docs/design/`)의 컬러/타입/간격/그림자 토큰을 SwiftUI로 옮기고, 모든 화면에서 재사용할 공통 컴포넌트 7개(StatusBadge, AppButton, AppCard, SectionHeader, AppNavBar, AppEmptyState, AppToast)를 만든다. 다크모드 1급 지원. 끝나면 모든 토큰과 컴포넌트가 Preview로 시각 확인 가능한 상태.

**Architecture:** SwiftUI 기반. 디자인 토큰은 `Presentation/DesignSystem/` 폴더에 `Color`, `Font`, `AppSpacing`, `AppRadius` extension으로 정의. 컴포넌트는 `Presentation/Common/Components/` 폴더. 모든 토큰·컴포넌트는 SwiftUI Preview를 포함해서 시각 검증 가능.

**Tech Stack:** SwiftUI (iOS 17.6+), 외부 라이브러리 0개. Pretendard 폰트는 1차 MVP에서는 System Font(SF Pro / Apple SD Gothic Neo) fallback (Plan 2d 에서 번들 추가 검토).

**선행 문서:**
- `docs/specs/2026-05-13-pose-analyzer-design.md` (스펙)
- `docs/design/README.md`, `docs/design/colors_and_type.css` (디자인 시스템)
- `docs/plans/2026-05-13-poseanalyzer-foundation.md` (Plan 1 완료됨, tag: `plan-1-foundation-complete`)

**완료 후 상태:** 디자인 토큰 + 공통 컴포넌트 모두 작성 완료. `RootPlaceholderView`는 임시 TabView 골격으로 교체 (탭만 보이고 내용은 빈 화면). 빌드 통과, 다크모드 정상 동작 확인. Plan 1의 단위테스트 60개 그대로 통과.

---

## 사전 정보

- 작업 디렉토리: `/Users/byunggyusong/1_개발폴더/마스터프로젝트/PoseAnalyzer`
- 시뮬레이터 UDID: `BF407CD0-C970-45EF-91FD-7FEB05483871` (iPhone 16 Pro / iOS 18.2)
- Xcode 16+ synchronized folders 사용 — `project.pbxproj` 직접 수정 금지
- 모든 코드 한국어 코멘트 (RULES.md)
- 디자인 토큰 값은 `docs/design/colors_and_type.css` 기준 (변경 시 반드시 css 먼저 업데이트)

---

## Phase 1: 디자인 토큰

### Task 1: Color 토큰

**파일/경로:**
- 생성: `PoseAnalyzer/Presentation/DesignSystem/AppColor.swift`

- [ ] **Step 1: AppColor.swift 작성**

```swift
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
            Text(title).font(.subheadline).bold().foregroundStyle(.fg2)
            ForEach(colors, id: \.0) { name, color in
                HStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(color)
                        .frame(width: 36, height: 24)
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(.border1, lineWidth: 1))
                    Text(name).font(.caption).foregroundStyle(.fg1)
                }
            }
        }
    }
}
```

- [ ] **Step 2: 빌드 확인**

```bash
cd "/Users/byunggyusong/1_개발폴더/마스터프로젝트/PoseAnalyzer/PoseAnalyzer"
xcodebuild build \
  -project PoseAnalyzer.xcodeproj \
  -scheme PoseAnalyzer \
  -destination 'platform=iOS Simulator,id=BF407CD0-C970-45EF-91FD-7FEB05483871' \
  2>&1 | tail -10
```

Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 3: commit**

```bash
cd "/Users/byunggyusong/1_개발폴더/마스터프로젝트/PoseAnalyzer"
git add PoseAnalyzer/PoseAnalyzer/Presentation/DesignSystem/AppColor.swift
git commit -m "feat(ui): add Color 디자인 토큰 (브랜드/상태/표면/전경/테두리)

Plan 2a Task 1: 디자인 시스템 컬러 토큰

- Brand: ink, primary(Pose Indigo), primaryPress, primarySoft, accent, mint
- Status: 4단계 (normal/caution/suspect/unknown) + bg variants
- Surfaces: canvas, surface, surface2 (라이트/다크 자동 전환)
- Foreground: fg1~fg4 (계층화)
- Borders: 1/2/strong
- PostureStatus → color/backgroundColor/iconName 매핑 헬퍼
- Light/Dark Preview"
```

---

### Task 2: Font 토큰 (iOS Type Ramp)

**파일/경로:**
- 생성: `PoseAnalyzer/Presentation/DesignSystem/AppFont.swift`

- [ ] **Step 1: AppFont.swift 작성**

```swift
import SwiftUI

/// 디자인 시스템 타입 토큰
/// 출처: docs/design/colors_and_type.css
/// MVP는 System Font fallback (SF Pro / Apple SD Gothic Neo).
/// Pretendard 번들은 Plan 2d 마무리 단계에서 검토.
extension Font {
    
    /// Display 34 / Bold — Hero numbers, splash
    static let appDisplay = Font.system(size: 34, weight: .bold).leading(.tight)
    /// H1 28 / Bold — 화면 타이틀
    static let appH1 = Font.system(size: 28, weight: .bold).leading(.tight)
    /// H2 22 / Bold — 섹션 타이틀
    static let appH2 = Font.system(size: 22, weight: .bold).leading(.tight)
    /// H3 18 / Semibold — 카드 타이틀
    static let appH3 = Font.system(size: 18, weight: .semibold).leading(.tight)
    /// Title 17 / Semibold — 인라인 강조
    static let appTitle = Font.system(size: 17, weight: .semibold)
    /// Body 16 / Regular — 본문
    static let appBody = Font.system(size: 16, weight: .regular)
    /// Callout 15 / Medium — 보조 본문
    static let appCallout = Font.system(size: 15, weight: .medium)
    /// Caption 13 / Medium — 메타정보
    static let appCaption = Font.system(size: 13, weight: .medium)
    /// Micro 11 / Semibold — UPPERCASE 마이크로 라벨
    static let appMicro = Font.system(size: 11, weight: .semibold)
    /// Metric 40 / Bold — 핵심 수치 (각도 등). monospaced digit
    static let appMetric = Font.system(size: 40, weight: .bold).monospacedDigit()
    /// Mono — 디버그/raw 데이터
    static let appMono = Font.system(.body, design: .monospaced)
}

// MARK: - Preview

#Preview("Type Ramp") {
    ScrollView {
        VStack(alignment: .leading, spacing: 14) {
            ramp("Display", "오늘의 자세를 측정", .appDisplay)
            ramp("H1", "측정 결과", .appH1)
            ramp("H2", "최근 측정", .appH2)
            ramp("H3", "거북목", .appH3)
            ramp("Title", "전체 보기", .appTitle)
            ramp("Body", "정면·측면 사진 2장이면 충분합니다.", .appBody)
            ramp("Callout", "장시간 고개를 숙이지 마세요.", .appCallout)
            ramp("Caption", "2026.05.13 화 · 19:24", .appCaption)
            ramp("Micro", "STEP 1 / 3", .appMicro)
            HStack(alignment: .firstTextBaseline) {
                Text("172").font(.appMetric)
                Text("°").font(.appH2).foregroundStyle(.fg3)
            }
        }
        .padding()
    }
    .background(Color.bgCanvas)
}

private func ramp(_ label: String, _ sample: String, _ font: Font) -> some View {
    VStack(alignment: .leading, spacing: 2) {
        Text(label).font(.appMicro).foregroundStyle(.fg3)
        Text(sample).font(font).foregroundStyle(.fg1)
    }
}
```

- [ ] **Step 2: 빌드 + commit**

```bash
cd "/Users/byunggyusong/1_개발폴더/마스터프로젝트/PoseAnalyzer/PoseAnalyzer"
xcodebuild build -project PoseAnalyzer.xcodeproj -scheme PoseAnalyzer \
  -destination 'platform=iOS Simulator,id=BF407CD0-C970-45EF-91FD-7FEB05483871' \
  2>&1 | tail -5
```

```bash
cd "/Users/byunggyusong/1_개발폴더/마스터프로젝트/PoseAnalyzer"
git add PoseAnalyzer/PoseAnalyzer/Presentation/DesignSystem/AppFont.swift
git commit -m "feat(ui): add Font 디자인 토큰 (iOS Type Ramp)

Plan 2a Task 2: 타입 시스템

- Display(34)/H1(28)/H2(22)/H3(18)/Title(17)/Body(16)/Callout(15)/Caption(13)/Micro(11)
- Metric: 40pt monospacedDigit (각도 등 수치용)
- System Font fallback (Pretendard는 Plan 2d 검토)
- Preview 포함"
```

---

### Task 3: Spacing & Radius 토큰

**파일/경로:**
- 생성: `PoseAnalyzer/Presentation/DesignSystem/AppSpacing.swift`

- [ ] **Step 1: AppSpacing.swift 작성**

```swift
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
```

- [ ] **Step 2: 빌드 + commit**

```bash
cd "/Users/byunggyusong/1_개발폴더/마스터프로젝트/PoseAnalyzer/PoseAnalyzer"
xcodebuild build -project PoseAnalyzer.xcodeproj -scheme PoseAnalyzer \
  -destination 'platform=iOS Simulator,id=BF407CD0-C970-45EF-91FD-7FEB05483871' \
  2>&1 | tail -5
```

```bash
cd "/Users/byunggyusong/1_개발폴더/마스터프로젝트/PoseAnalyzer"
git add PoseAnalyzer/PoseAnalyzer/Presentation/DesignSystem/AppSpacing.swift
git commit -m "feat(ui): add Spacing/Radius/Shadow 토큰

Plan 2a Task 3: 간격·반지름·그림자

- AppSpacing: 4pt 스케일 s1(4)~s10(72)
- AppRadius: xs(6)/sm(10)/md(14)/lg(20)/xl(28)/pill
- View.appCardShadow() / .appPopShadow() — 라이트/다크 자동 조절"
```

---

## Phase 2: 공통 컴포넌트

### Task 4: StatusBadge 컴포넌트

**파일/경로:**
- 생성: `PoseAnalyzer/Presentation/Common/Components/StatusBadge.swift`

- [ ] **Step 1: StatusBadge.swift 작성**

```swift
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
                .fill(tone == .soft ? status.color : .white.opacity(0.85))
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
        tone == .soft ? status.color : .white
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
```

- [ ] **Step 2: 빌드 + commit**

```bash
cd "/Users/byunggyusong/1_개발폴더/마스터프로젝트/PoseAnalyzer/PoseAnalyzer"
xcodebuild build -project PoseAnalyzer.xcodeproj -scheme PoseAnalyzer \
  -destination 'platform=iOS Simulator,id=BF407CD0-C970-45EF-91FD-7FEB05483871' \
  2>&1 | tail -5
```

```bash
cd "/Users/byunggyusong/1_개발폴더/마스터프로젝트/PoseAnalyzer"
git add PoseAnalyzer/PoseAnalyzer/Presentation/Common/Components/StatusBadge.swift
git commit -m "feat(ui): add StatusBadge 컴포넌트 (4단계 판정 pill)

Plan 2a Task 4: 자세 판정 상태 시각화

- 4 상태(normal/caution/suspect/unmeasurable) 매핑
- 2 톤(soft 배경/solid full-color)
- 2 사이즈(small/regular)
- 색맹 접근성: dot + 텍스트 함께 (색만 의존 X)"
```

---

### Task 5: AppButton 컴포넌트

**파일/경로:**
- 생성: `PoseAnalyzer/Presentation/Common/Components/AppButton.swift`

- [ ] **Step 1: AppButton.swift 작성**

```swift
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
            .foregroundStyle(isDisabled ? .fg4 : variant.fg)
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
```

- [ ] **Step 2: 빌드 + commit**

```bash
cd "/Users/byunggyusong/1_개발폴더/마스터프로젝트/PoseAnalyzer/PoseAnalyzer"
xcodebuild build -project PoseAnalyzer.xcodeproj -scheme PoseAnalyzer \
  -destination 'platform=iOS Simulator,id=BF407CD0-C970-45EF-91FD-7FEB05483871' \
  2>&1 | tail -5
```

```bash
cd "/Users/byunggyusong/1_개발폴더/마스터프로젝트/PoseAnalyzer"
git add PoseAnalyzer/PoseAnalyzer/Presentation/Common/Components/AppButton.swift
git commit -m "feat(ui): add AppButton 컴포넌트 (4 variant × 3 size)

Plan 2a Task 5: 디자인 시스템 버튼

- Variant: primary/secondary/ghost/danger
- Size: large(56h)/medium(48h)/small(36h)
- 프레스 애니메이션: scale 0.97 + 배경 dim
- isLoading: ProgressView, isDisabled: gray
- AnyView 없이 generic Label 지원 (icon+text 자유)"
```

---

### Task 6: AppCard 컴포넌트

**파일/경로:**
- 생성: `PoseAnalyzer/Presentation/Common/Components/AppCard.swift`

- [ ] **Step 1: AppCard.swift 작성**

```swift
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
        style == .standard ? .bgSurface : .bgSurface2
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
                Text("측정 각도 172°").font(.appCaption).foregroundStyle(.fg2)
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
```

- [ ] **Step 2: 빌드 + commit**

```bash
cd "/Users/byunggyusong/1_개발폴더/마스터프로젝트/PoseAnalyzer/PoseAnalyzer"
xcodebuild build -project PoseAnalyzer.xcodeproj -scheme PoseAnalyzer \
  -destination 'platform=iOS Simulator,id=BF407CD0-C970-45EF-91FD-7FEB05483871' \
  2>&1 | tail -5
```

```bash
cd "/Users/byunggyusong/1_개발폴더/마스터프로젝트/PoseAnalyzer"
git add PoseAnalyzer/PoseAnalyzer/Presentation/Common/Components/AppCard.swift
git commit -m "feat(ui): add AppCard 컴포넌트 (standard / nested)

Plan 2a Task 6: 기본 카드

- standard: bgSurface + shadow + border
- nested: bgSurface2 + border only (중첩 카드용)
- 커스텀 padding/radius 지원"
```

---

### Task 7: SectionHeader 컴포넌트

**파일/경로:**
- 생성: `PoseAnalyzer/Presentation/Common/Components/SectionHeader.swift`

- [ ] **Step 1: SectionHeader.swift 작성**

```swift
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
                    .foregroundStyle(.fg1)
                if let subtitle {
                    Text(subtitle)
                        .font(.appCaption)
                        .foregroundStyle(.fg3)
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
                .foregroundStyle(.brandPrimary)
        }
    }
    .padding()
    .background(Color.bgCanvas)
}
```

- [ ] **Step 2: 빌드 + commit**

```bash
cd "/Users/byunggyusong/1_개발폴더/마스터프로젝트/PoseAnalyzer/PoseAnalyzer"
xcodebuild build -project PoseAnalyzer.xcodeproj -scheme PoseAnalyzer \
  -destination 'platform=iOS Simulator,id=BF407CD0-C970-45EF-91FD-7FEB05483871' \
  2>&1 | tail -5
```

```bash
cd "/Users/byunggyusong/1_개발폴더/마스터프로젝트/PoseAnalyzer"
git add PoseAnalyzer/PoseAnalyzer/Presentation/Common/Components/SectionHeader.swift
git commit -m "feat(ui): add SectionHeader 컴포넌트 (제목 + trailing action)

Plan 2a Task 7: 섹션 헤더

- 제목 + 옵션 부제목 + trailing trailing 액션 (generic)
- '전체 보기 ›' 같은 액션 버튼 케이스 지원
- 편의 init: 액션 없는 단순 제목 버전"
```

---

### Task 8: AppNavBar 컴포넌트 (custom navigation)

**파일/경로:**
- 생성: `PoseAnalyzer/Presentation/Common/Components/AppNavBar.swift`

- [ ] **Step 1: AppNavBar.swift 작성**

```swift
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
                            .foregroundStyle(.brandPrimary)
                    }
                    .accessibilityLabel("뒤로")
                }
            }
            .frame(width: 44, height: 44)
            
            // Center title
            VStack(spacing: 1) {
                Text(title)
                    .font(.appTitle)
                    .foregroundStyle(.fg1)
                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 11, weight: .semibold))
                        .kerning(0.01)
                        .foregroundStyle(.fg3)
                }
            }
            .frame(maxWidth: .infinity)
            
            // Trailing 44pt slot
            ZStack {
                if let icon = trailingIcon, let action = trailingAction {
                    Button(action: action) {
                        Image(systemName: icon)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.brandPrimary)
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
```

- [ ] **Step 2: 빌드 + commit**

```bash
cd "/Users/byunggyusong/1_개발폴더/마스터프로젝트/PoseAnalyzer/PoseAnalyzer"
xcodebuild build -project PoseAnalyzer.xcodeproj -scheme PoseAnalyzer \
  -destination 'platform=iOS Simulator,id=BF407CD0-C970-45EF-91FD-7FEB05483871' \
  2>&1 | tail -5
```

```bash
cd "/Users/byunggyusong/1_개발폴더/마스터프로젝트/PoseAnalyzer"
git add PoseAnalyzer/PoseAnalyzer/Presentation/Common/Components/AppNavBar.swift
git commit -m "feat(ui): add AppNavBar 컴포넌트 (44pt 슬롯 + 제목/부제목)

Plan 2a Task 8: 커스텀 상단 네비게이션

- 양쪽 44pt 액션 슬롯 (옵션 leading/trailing icon + action)
- 중앙 제목 + 옵션 부제목 (STEP 1/3 등)
- SF Symbol 아이콘, brandPrimary 색상"
```

---

### Task 9: AppEmptyState 컴포넌트

**파일/경로:**
- 생성: `PoseAnalyzer/Presentation/Common/Components/AppEmptyState.swift`

- [ ] **Step 1: AppEmptyState.swift 작성**

```swift
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
                .foregroundStyle(.fg4)
            VStack(spacing: 4) {
                Text(title)
                    .font(.appH3)
                    .foregroundStyle(.fg2)
                    .multilineTextAlignment(.center)
                if let message {
                    Text(message)
                        .font(.appCaption)
                        .foregroundStyle(.fg3)
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
```

- [ ] **Step 2: 빌드 + commit**

```bash
cd "/Users/byunggyusong/1_개발폴더/마스터프로젝트/PoseAnalyzer/PoseAnalyzer"
xcodebuild build -project PoseAnalyzer.xcodeproj -scheme PoseAnalyzer \
  -destination 'platform=iOS Simulator,id=BF407CD0-C970-45EF-91FD-7FEB05483871' \
  2>&1 | tail -5
```

```bash
cd "/Users/byunggyusong/1_개발폴더/마스터프로젝트/PoseAnalyzer"
git add PoseAnalyzer/PoseAnalyzer/Presentation/Common/Components/AppEmptyState.swift
git commit -m "feat(ui): add AppEmptyState 컴포넌트 (빈 상태 안내)

Plan 2a Task 9: 데이터 없음 안내

- SF Symbol 아이콘 + 제목 + 옵션 메시지 + 옵션 액션
- generic Action으로 버튼 등 자유 슬롯"
```

---

## Phase 3: 임시 TabView 골격

### Task 10: AppTabView (탭 골격 + RootPlaceholderView 교체)

**파일/경로:**
- 생성: `PoseAnalyzer/Presentation/AppTabView.swift`
- 수정: `PoseAnalyzer/PoseAnalyzerApp.swift`
- 삭제: `PoseAnalyzer/Presentation/Common/RootPlaceholderView.swift`

- [ ] **Step 1: AppTabView.swift 작성**

```swift
import SwiftUI

/// 앱 루트 — 측정/기록 2개 탭 골격
/// 각 탭의 실제 내용은 Plan 2b, 2c에서 채움
struct AppTabView: View {
    
    @State private var selectedTab: Tab = .measurement
    
    enum Tab: String, Hashable {
        case measurement, history
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 측정 탭 (Plan 2b에서 채움)
            MeasurementTabPlaceholder()
                .tabItem {
                    Image(systemName: "camera.fill")
                    Text("측정")
                }
                .tag(Tab.measurement)
            
            // 기록 탭 (Plan 2c에서 채움)
            HistoryTabPlaceholder()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("기록")
                }
                .tag(Tab.history)
        }
        .tint(.brandPrimary)
    }
}

/// 측정 탭 임시 화면 (Plan 2b에서 HomeView 등으로 교체)
private struct MeasurementTabPlaceholder: View {
    var body: some View {
        NavigationStack {
            VStack {
                AppEmptyState(
                    icon: "figure.stand",
                    title: "측정 화면",
                    message: "Plan 2b에서 작성됩니다."
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.bgCanvas)
        }
    }
}

/// 기록 탭 임시 화면 (Plan 2c에서 HistoryListView로 교체)
private struct HistoryTabPlaceholder: View {
    var body: some View {
        NavigationStack {
            AppEmptyState(
                icon: "chart.bar.fill",
                title: "기록 화면",
                message: "Plan 2c에서 작성됩니다."
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.bgCanvas)
        }
    }
}

#Preview("Light") {
    AppTabView().preferredColorScheme(.light)
}

#Preview("Dark") {
    AppTabView().preferredColorScheme(.dark)
}
```

- [ ] **Step 2: PoseAnalyzerApp.swift 수정**

기존 RootPlaceholderView 참조를 AppTabView로 교체:

```swift
import SwiftUI
import SwiftData

@main
struct PoseAnalyzerApp: App {
    
    @StateObject private var dependencies = AppDependencies()
    
    var body: some Scene {
        WindowGroup {
            AppTabView()
                .environmentObject(dependencies)
                .modelContainer(dependencies.modelContainer)
        }
    }
}
```

- [ ] **Step 3: RootPlaceholderView.swift 삭제**

```bash
rm "/Users/byunggyusong/1_개발폴더/마스터프로젝트/PoseAnalyzer/PoseAnalyzer/PoseAnalyzer/Presentation/Common/RootPlaceholderView.swift"
```

- [ ] **Step 4: 빌드 + 시뮬레이터 실행**

```bash
cd "/Users/byunggyusong/1_개발폴더/마스터프로젝트/PoseAnalyzer/PoseAnalyzer"
xcodebuild build -project PoseAnalyzer.xcodeproj -scheme PoseAnalyzer \
  -destination 'platform=iOS Simulator,id=BF407CD0-C970-45EF-91FD-7FEB05483871' \
  2>&1 | tail -10
```

Expected: `** BUILD SUCCEEDED **`

시뮬레이터에서 `⌘R` 또는 `xcrun simctl install` 등으로 실행해도 하단 두 탭(측정/기록) 보이면 OK.

- [ ] **Step 5: commit**

```bash
cd "/Users/byunggyusong/1_개발폴더/마스터프로젝트/PoseAnalyzer"
git add PoseAnalyzer/PoseAnalyzer/Presentation/AppTabView.swift \
        PoseAnalyzer/PoseAnalyzer/PoseAnalyzerApp.swift
git add -u PoseAnalyzer/PoseAnalyzer/Presentation/Common/RootPlaceholderView.swift 2>/dev/null || true
git commit -m "feat(ui): replace RootPlaceholder with AppTabView (측정/기록 탭 골격)

Plan 2a Task 10: 탭 진입 골격

- AppTabView: TabView (측정 = camera, 기록 = chart.bar)
- brandPrimary 액센트
- 각 탭 내용은 placeholder (Plan 2b/2c에서 채움)
- RootPlaceholderView 제거"
```

---

## Phase 4: 마무리 검증

### Task 11: Plan 1 테스트 회귀 + 전체 빌드 검증

- [ ] **Step 1: 전체 테스트 실행 (Plan 1 회귀)**

```bash
cd "/Users/byunggyusong/1_개발폴더/마스터프로젝트/PoseAnalyzer/PoseAnalyzer"
xcodebuild test -project PoseAnalyzer.xcodeproj -scheme PoseAnalyzer \
  -destination 'platform=iOS Simulator,id=BF407CD0-C970-45EF-91FD-7FEB05483871' \
  2>&1 | tail -20
```

Expected: `** TEST SUCCEEDED **` — Plan 1의 60개 테스트가 그대로 통과해야 함.

- [ ] **Step 2: 라이트/다크 시뮬레이터 확인**

시뮬레이터에서 Settings → Developer → Dark Appearance toggle.
- 라이트: bgCanvas 따뜻한 회색, 탭바 흰 톤
- 다크: bgCanvas 깊은 슬레이트, 탭바 어두운 톤

- [ ] **Step 3: Plan 2a tag**

```bash
cd "/Users/byunggyusong/1_개발폴더/마스터프로젝트/PoseAnalyzer"
git tag -a plan-2a-ui-foundation-complete -m "Plan 2a (UI Foundation) 완료

디자인 토큰 + 공통 컴포넌트 7개 + 탭 골격 구현.
Plan 1 단위테스트 60/60 그대로 통과.
다음: Plan 2b (Measurement Flow)."
```

---

## ✅ Plan 2a 완료 정의

- [ ] 디자인 토큰 3 파일 (AppColor / AppFont / AppSpacing)
- [ ] 공통 컴포넌트 6개 (StatusBadge, AppButton, AppCard, SectionHeader, AppNavBar, AppEmptyState)
- [ ] AppTabView 탭 골격 (측정/기록)
- [ ] RootPlaceholderView 제거
- [ ] PoseAnalyzerApp이 AppTabView 사용
- [ ] 빌드 SUCCEEDED, 시뮬레이터에서 탭 정상 표시
- [ ] 라이트/다크모드 정상 전환
- [ ] Plan 1 단위테스트 60/60 통과 (회귀 없음)
- [ ] `plan-2a-ui-foundation-complete` git tag

---

## ⏭ 다음 단계 (Plan 2b)

Plan 2a 완료 후 Plan 2b 작성:
- 권한 화면 (카메라/사진 접근)
- ImagePicker (UIImagePickerController wrapper)
- PhotosPicker (SwiftUI native)
- CameraView (촬영 후 확인 단계)
- MeasurementWizardView + ViewModel (Step 1-3)
- AnalyzingView (분석 중 로딩)
- HomeView (측정 시작 진입점)
