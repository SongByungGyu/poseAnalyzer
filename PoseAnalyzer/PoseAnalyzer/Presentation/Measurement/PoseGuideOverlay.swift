import SwiftUI

/// 카메라 프리뷰 위에 표시되는 자세 가이드 오버레이 (Variant B — 측정 도구 톤)
///
/// Variant B 특징
/// - 채움 없는 점선 외곽선 (clinical / 측정 도구 느낌)
/// - 측정 관절마다 mint **십자선 (crosshair)** 마커
/// - 정면: 양 어깨 / 양 골반 수평 정렬선
/// - 측면: 귀–어깨–엉덩이–무릎–발목 수직 plumb-line + Korean joint labels (귀·어깨·엉덩이·무릎·발목)
/// - 상단 STEP 배지 + 안내 텍스트 (vibrancy)
/// - 실루엣 외부는 dim, 내부는 카메라 프리뷰 그대로
///
/// 기존 PoseGuideOverlay와 동일한 시그니처: `PoseGuideOverlay(view:)`
/// 추가 옵션: `step` — 상단 STEP 배지에 표시 (없으면 배지만 단순)
struct PoseGuideOverlay: View {

    let view: SessionView

    /// 현재 단계 (1...3). 옵션 — nil이면 STEP 숫자 없이 제목만 표시.
    var step: Int? = nil
    var totalSteps: Int = 3

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                // 1) 실루엣 영역을 제외한 배경 dim
                Color.black.opacity(0.38)
                    .ignoresSafeArea()
                    .mask(
                        Rectangle()
                            .overlay(
                                guideArea(in: proxy.size)
                                    .blendMode(.destinationOut)
                            )
                            .compositingGroup()
                    )

                // 2) 점선 실루엣 + 정렬선 + 십자선 + 라벨
                // 사이즈와 위치는 화면에서 시각적으로 가운데 + 텍스트/셔터와 여유 있게.
                PoseSilhouetteB(view: view)
                    .frame(
                        width: proxy.size.width * 0.55,
                        height: proxy.size.height * 0.62
                    )
                    .position(
                        x: proxy.size.width * 0.5,
                        y: proxy.size.height * 0.50
                    )

                // 3) 상단 STEP 배지 + 안내 텍스트
                VStack(spacing: AppSpacing.s3) {
                    if let step {
                        StepBadge(step: step, total: totalSteps, title: view.title)
                    } else {
                        Capsule()
                            .fill(Color.black.opacity(0.55))
                            .overlay(
                                Text(view.title)
                                    .font(.appMicro)
                                    .foregroundStyle(Color.white)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 6)
                            )
                            .fixedSize()
                    }
                    Text(view.hint)
                        .font(.appCallout)
                        .foregroundStyle(Color.white.opacity(0.92))
                        .multilineTextAlignment(.center)
                        .shadow(color: .black.opacity(0.55), radius: 8, y: 1)
                        .padding(.horizontal, AppSpacing.s5)
                }
                .padding(.top, AppSpacing.s10)
                .frame(maxHeight: .infinity, alignment: .top)
            }
        }
        .allowsHitTesting(false)
    }

    /// dim 마스크용 — 실루엣의 bounding 영역 (살짝 padding)
    /// PoseSilhouetteB의 frame과 동일한 비율 유지.
    private func guideArea(in size: CGSize) -> some Shape {
        let w = size.width * 0.55
        let h = size.height * 0.62
        return RoundedRectangle(cornerRadius: 60, style: .continuous)
            .size(width: w * 1.10, height: h * 1.06)
            .offset(x: (size.width - w * 1.10) / 2,
                    y: (size.height - h * 1.06) / 2)
    }
}

// MARK: - SessionView 안내 카피

private extension SessionView {
    var title: String {
        switch self {
        case .front: "정면 사진"
        case .side:  "측면 사진"
        }
    }
    var hint: String {
        switch self {
        case .front: "어깨와 골반이 보이도록\n정면을 향해 서주세요"
        case .side:  "한쪽 옆모습 전체가\n보이도록 서주세요"
        }
    }
}

// MARK: - 상단 STEP 배지

private struct StepBadge: View {
    let step: Int
    let total: Int
    let title: String

    var body: some View {
        HStack(spacing: AppSpacing.s2) {
            ZStack {
                Circle().fill(Color.brandPrimary)
                Text("\(step)")
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundStyle(Color.white)
                    .monospacedDigit()
            }
            .frame(width: 22, height: 22)

            HStack(spacing: 4) {
                Text("STEP")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.55))
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.white)
            }
            .padding(.trailing, 4)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color.black.opacity(0.55))
                .overlay(
                    Capsule()
                        .strokeBorder(Color.white.opacity(0.18), lineWidth: 0.5)
                )
        )
    }
}

// MARK: - 실루엣 + 십자선 + 라벨 (Variant B)

/// 점선 외곽선 + 측정 관절 십자선 마커 + (측면) plumb-line + (측면) 한글 라벨
///
/// 좌표계: 200×470 viewBox 기준. 실제 화면 크기에 맞춰 scale + 중앙 정렬.
private struct PoseSilhouetteB: View {
    let view: SessionView

    private let baseSize = CGSize(width: 200, height: 470)

    var body: some View {
        GeometryReader { proxy in
            let scale = min(proxy.size.width  / baseSize.width,
                            proxy.size.height / baseSize.height)
            let scaledW = baseSize.width  * scale
            let scaledH = baseSize.height * scale
            let dx = (proxy.size.width  - scaledW) / 2
            let dy = (proxy.size.height - scaledH) / 2

            ZStack(alignment: .topLeading) {
                // 1) 점선 외곽선 (살짝 채움 — 카메라 위에서 영역 인지를 돕기 위해 매우 옅게)
                bodyPath
                    .fill(Color.white.opacity(0.03))
                    .frame(width: scaledW, height: scaledH)
                    .offset(x: dx, y: dy)

                bodyPath
                    .stroke(
                        Color.white,
                        style: StrokeStyle(lineWidth: 2, lineJoin: .round, dash: [6, 6])
                    )
                    .frame(width: scaledW, height: scaledH)
                    .offset(x: dx, y: dy)

                // 2) 정렬선
                alignmentGuides
                    .frame(width: scaledW, height: scaledH)
                    .offset(x: dx, y: dy)

                // 3) plumb-line 라벨 (측면만)
                if view == .side {
                    plumbLineLabel(scale: scale)
                        .offset(x: dx, y: dy)
                }

                // 4) 십자선 마커
                crosshairs(scale: scale)
                    .offset(x: dx, y: dy)

                // 5) 관절 한글 라벨 (측면만 — 정면은 너무 빽빽해짐)
                if view == .side {
                    sideJointLabels(scale: scale)
                        .offset(x: dx, y: dy)
                }
            }
        }
    }

    // MARK: 본체 path

    private var bodyPath: Path {
        switch view {
        case .front: return Self.frontPath
        case .side:  return Self.sidePath
        }
    }

    /// 정면 사람 실루엣
    private static let frontPath: Path = {
        var p = Path()
        p.move(to: CGPoint(x: 100, y: 28))
        p.addCurve(to: CGPoint(x: 132, y: 84),
                   control1: CGPoint(x: 130, y: 28),
                   control2: CGPoint(x: 142, y: 56))
        p.addLine(to: CGPoint(x: 162, y: 116))
        p.addLine(to: CGPoint(x: 168, y: 196))
        p.addLine(to: CGPoint(x: 144, y: 216))
        p.addLine(to: CGPoint(x: 142, y: 268))
        p.addLine(to: CGPoint(x: 156, y: 460))
        p.addLine(to: CGPoint(x: 130, y: 460))
        p.addLine(to: CGPoint(x: 116, y: 304))
        p.addLine(to: CGPoint(x: 100, y: 280))
        p.addLine(to: CGPoint(x: 84, y: 304))
        p.addLine(to: CGPoint(x: 70, y: 460))
        p.addLine(to: CGPoint(x: 44, y: 460))
        p.addLine(to: CGPoint(x: 58, y: 268))
        p.addLine(to: CGPoint(x: 56, y: 216))
        p.addLine(to: CGPoint(x: 32, y: 196))
        p.addLine(to: CGPoint(x: 38, y: 116))
        p.addLine(to: CGPoint(x: 68, y: 84))
        p.addCurve(to: CGPoint(x: 100, y: 28),
                   control1: CGPoint(x: 58, y: 56),
                   control2: CGPoint(x: 70, y: 28))
        p.closeSubpath()
        return p
    }()

    /// 측면 사람 실루엣 (얼굴은 오른쪽 방향)
    private static let sidePath: Path = {
        var p = Path()
        p.move(to: CGPoint(x: 116, y: 28))
        p.addCurve(to: CGPoint(x: 144, y: 76),
                   control1: CGPoint(x: 138, y: 28),
                   control2: CGPoint(x: 148, y: 50))
        p.addLine(to: CGPoint(x: 150, y: 88))
        p.addLine(to: CGPoint(x: 142, y: 96))
        p.addLine(to: CGPoint(x: 138, y: 104))
        p.addLine(to: CGPoint(x: 122, y: 110))
        p.addLine(to: CGPoint(x: 124, y: 124))
        p.addLine(to: CGPoint(x: 142, y: 138))
        p.addCurve(to: CGPoint(x: 128, y: 230),
                   control1: CGPoint(x: 140, y: 168),
                   control2: CGPoint(x: 134, y: 200))
        p.addLine(to: CGPoint(x: 134, y: 260))
        p.addCurve(to: CGPoint(x: 132, y: 320),
                   control1: CGPoint(x: 138, y: 280),
                   control2: CGPoint(x: 138, y: 300))
        p.addLine(to: CGPoint(x: 138, y: 360))
        p.addCurve(to: CGPoint(x: 128, y: 460),
                   control1: CGPoint(x: 138, y: 400),
                   control2: CGPoint(x: 134, y: 430))
        p.addLine(to: CGPoint(x: 104, y: 460))
        p.addLine(to: CGPoint(x: 102, y: 432))
        p.addLine(to: CGPoint(x: 108, y: 380))
        p.addLine(to: CGPoint(x: 102, y: 320))
        p.addCurve(to: CGPoint(x: 102, y: 246),
                   control1: CGPoint(x: 96, y: 296),
                   control2: CGPoint(x: 96, y: 270))
        p.addLine(to: CGPoint(x: 96, y: 226))
        p.addLine(to: CGPoint(x: 92, y: 196))
        p.addCurve(to: CGPoint(x: 86, y: 124),
                   control1: CGPoint(x: 86, y: 168),
                   control2: CGPoint(x: 84, y: 138))
        p.addCurve(to: CGPoint(x: 82, y: 92),
                   control1: CGPoint(x: 80, y: 116),
                   control2: CGPoint(x: 78, y: 104))
        p.addLine(to: CGPoint(x: 80, y: 80))
        p.addCurve(to: CGPoint(x: 96, y: 38),
                   control1: CGPoint(x: 78, y: 66),
                   control2: CGPoint(x: 84, y: 50))
        p.addCurve(to: CGPoint(x: 116, y: 28),
                   control1: CGPoint(x: 102, y: 32),
                   control2: CGPoint(x: 108, y: 28))
        p.closeSubpath()
        return p
    }()

    // MARK: 정렬선 (정면: 가로 / 측면: 세로 plumb-line)

    private var alignmentGuides: some View {
        Path { p in
            switch view {
            case .front:
                // 어깨 + 골반 수평선
                p.move(to: CGPoint(x: 48,  y: 116));  p.addLine(to: CGPoint(x: 152, y: 116))
                p.move(to: CGPoint(x: 58,  y: 216));  p.addLine(to: CGPoint(x: 142, y: 216))
            case .side:
                // 귀–어깨–엉덩이–무릎–발목 수직 plumb-line
                p.move(to: CGPoint(x: 118, y: 64))
                p.addLine(to: CGPoint(x: 118, y: 450))
            }
        }
        .stroke(
            Color.brandMint.opacity(view == .side ? 0.7 : 0.65),
            style: StrokeStyle(lineWidth: 1, dash: [3, 4])
        )
    }

    // MARK: plumb-line 작은 라벨 ("정렬선")

    private func plumbLineLabel(scale: CGFloat) -> some View {
        Text("정렬선")
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(Color.brandMint)
            .padding(.horizontal, 9)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(Color.brandMint.opacity(0.16))
                    .overlay(Capsule().strokeBorder(Color.brandMint.opacity(0.6), lineWidth: 0.8))
            )
            .position(x: 156 * scale, y: 232 * scale)
    }

    // MARK: 십자선 마커

    private struct Crosshair: View {
        let center: CGPoint
        let size: CGFloat
        let scale: CGFloat
        var body: some View {
            ZStack {
                Path { p in
                    p.move(to: CGPoint(x: -size, y: 0));  p.addLine(to: CGPoint(x: size, y: 0))
                    p.move(to: CGPoint(x: 0, y: -size));  p.addLine(to: CGPoint(x: 0, y: size))
                }
                .stroke(Color.brandMint, style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
                .frame(width: size * 2, height: size * 2)
            }
            .position(x: center.x * scale, y: center.y * scale)
        }
    }

    @ViewBuilder
    private func crosshairs(scale: CGFloat) -> some View {
        let crosses: [(CGPoint, CGFloat)] = {
            switch view {
            case .front:
                return [
                    (CGPoint(x: 84,  y: 56), 6),    // 좌 귀
                    (CGPoint(x: 116, y: 56), 6),    // 우 귀
                    (CGPoint(x: 48,  y: 116), 8),   // 좌 어깨
                    (CGPoint(x: 152, y: 116), 8),   // 우 어깨
                    (CGPoint(x: 58,  y: 216), 8),   // 좌 골반
                    (CGPoint(x: 142, y: 216), 8),   // 우 골반
                    (CGPoint(x: 74,  y: 340), 8),   // 좌 무릎
                    (CGPoint(x: 126, y: 340), 8),   // 우 무릎
                    (CGPoint(x: 60,  y: 450), 8),   // 좌 발목
                    (CGPoint(x: 140, y: 450), 8),   // 우 발목
                ]
            case .side:
                return [
                    (CGPoint(x: 118, y: 64),  8),   // 귀
                    (CGPoint(x: 118, y: 140), 8),   // 어깨
                    (CGPoint(x: 118, y: 246), 8),   // 엉덩이
                    (CGPoint(x: 118, y: 340), 8),   // 무릎
                    (CGPoint(x: 118, y: 450), 8),   // 발목
                ]
            }
        }()
        ZStack {
            ForEach(0..<crosses.count, id: \.self) { i in
                let (pt, sz) = crosses[i]
                Crosshair(center: pt, size: sz, scale: scale)
            }
        }
    }

    // MARK: 측면 관절 한글 라벨

    private func sideJointLabels(scale: CGFloat) -> some View {
        ZStack {
            label("귀",     at: CGPoint(x: 80,  y: 68),  scale: scale, anchor: .trailing)
            label("어깨",   at: CGPoint(x: 80,  y: 144), scale: scale, anchor: .trailing)
            label("엉덩이", at: CGPoint(x: 80,  y: 250), scale: scale, anchor: .trailing)
            label("무릎",   at: CGPoint(x: 156, y: 344), scale: scale, anchor: .leading)
            label("발목",   at: CGPoint(x: 156, y: 454), scale: scale, anchor: .leading)
        }
    }

    private func label(_ text: String, at pt: CGPoint, scale: CGFloat, anchor: HorizontalAlignment) -> some View {
        Text(text)
            .font(.system(size: 9, weight: .semibold))
            .foregroundStyle(Color.white.opacity(0.7))
            .fixedSize()
            .alignmentGuide(.leading)   { d in anchor == .leading   ? 0     : d.width }
            .alignmentGuide(.trailing)  { d in anchor == .trailing  ? d.width : 0    }
            .position(x: pt.x * scale, y: pt.y * scale)
    }
}

// MARK: - Previews

#Preview("Front · step 1") {
    ZStack {
        LinearGradient(colors: [Color(white: 0.30), Color(white: 0.18)],
                       startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
        PoseGuideOverlay(view: .front, step: 1)
    }
    .preferredColorScheme(.dark)
}

#Preview("Side · step 2") {
    ZStack {
        LinearGradient(colors: [Color(white: 0.30), Color(white: 0.18)],
                       startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
        PoseGuideOverlay(view: .side, step: 2)
    }
    .preferredColorScheme(.dark)
}
