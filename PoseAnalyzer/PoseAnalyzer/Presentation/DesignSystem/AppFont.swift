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
                Text("°").font(.appH2).foregroundStyle(Color.fg3)
            }
        }
        .padding()
    }
    .background(Color.bgCanvas)
}

private func ramp(_ label: String, _ sample: String, _ font: Font) -> some View {
    VStack(alignment: .leading, spacing: 2) {
        Text(label).font(.appMicro).foregroundStyle(Color.fg3)
        Text(sample).font(font).foregroundStyle(Color.fg1)
    }
}
