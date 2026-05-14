import SwiftUI

/// 카메라 프리뷰 위에 표시되는 자세 가이드 오버레이
/// 정면/측면별로 다른 실루엣 + 안내 텍스트
struct PoseGuideOverlay: View {

    let view: SessionView

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                // 1) 배경 어둡게 (실루엣 영역 제외)
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                    .mask(
                        Rectangle()
                            .overlay(
                                guideShape(in: proxy.size)
                                    .blendMode(.destinationOut)
                            )
                            .compositingGroup()
                    )

                // 2) 가이드 외곽선 (점선)
                guideShape(in: proxy.size)
                    .stroke(
                        Color.white.opacity(0.85),
                        style: StrokeStyle(lineWidth: 2, dash: [8, 6])
                    )

                // 3) 안내 텍스트 (상단)
                VStack {
                    Text(view == .front ? "정면 가이드" : "측면 가이드")
                        .font(.appMicro)
                        .foregroundStyle(Color.white)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 12)
                        .background(Color.black.opacity(0.55), in: Capsule())
                    Text(view == .front
                        ? "어깨와 골반이 보이도록 정면을 향해주세요"
                        : "한쪽 옆모습 전체가 보이도록 서주세요")
                        .font(.appCaption)
                        .foregroundStyle(Color.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AppSpacing.s5)
                        .padding(.top, AppSpacing.s2)
                    Spacer()
                }
                .padding(.top, AppSpacing.s10)
            }
        }
        .allowsHitTesting(false)
    }

    /// 자세 실루엣 모양 (세로 직사각형 + 사람 형태 윤곽)
    /// 화면 중앙에 위치, 전신이 들어가는 영역
    private func guideShape(in size: CGSize) -> some Shape {
        PoseSilhouetteShape(view: view)
            .size(width: size.width * 0.55, height: size.height * 0.72)
            .offset(x: size.width * 0.225, y: size.height * 0.14)
    }
}

/// 정면/측면 사람 실루엣 외곽선
private struct PoseSilhouetteShape: Shape {
    let view: SessionView
    var width: CGFloat = 200
    var height: CGFloat = 500
    var offsetX: CGFloat = 0
    var offsetY: CGFloat = 0

    func size(width: CGFloat, height: CGFloat) -> PoseSilhouetteShape {
        var copy = self
        copy.width = width
        copy.height = height
        return copy
    }

    func offset(x: CGFloat, y: CGFloat) -> PoseSilhouetteShape {
        var copy = self
        copy.offsetX = x
        copy.offsetY = y
        return copy
    }

    func path(in rect: CGRect) -> Path {
        let w = width
        let h = height
        let ox = offsetX
        let oy = offsetY
        return Path { p in
            switch view {
            case .front:
                // 정면 실루엣: 머리, 어깨, 몸통, 다리
                let headW = w * 0.22, headH = h * 0.13
                let shoulderY = oy + h * 0.18
                let waistY = oy + h * 0.50
                let legSplitY = oy + h * 0.55
                let footY = oy + h * 0.98

                // 머리 (타원)
                p.addEllipse(in: CGRect(
                    x: ox + (w - headW) / 2,
                    y: oy + h * 0.02,
                    width: headW, height: headH
                ))
                // 목
                p.move(to: CGPoint(x: ox + w / 2, y: oy + h * 0.15))
                p.addLine(to: CGPoint(x: ox + w / 2, y: shoulderY))
                // 어깨 라인
                p.move(to: CGPoint(x: ox + w * 0.1, y: shoulderY + h * 0.02))
                p.addLine(to: CGPoint(x: ox + w * 0.9, y: shoulderY + h * 0.02))
                // 몸통 외곽
                p.move(to: CGPoint(x: ox + w * 0.18, y: shoulderY + h * 0.02))
                p.addLine(to: CGPoint(x: ox + w * 0.22, y: waistY))
                p.move(to: CGPoint(x: ox + w * 0.82, y: shoulderY + h * 0.02))
                p.addLine(to: CGPoint(x: ox + w * 0.78, y: waistY))
                // 골반 라인
                p.move(to: CGPoint(x: ox + w * 0.22, y: waistY))
                p.addLine(to: CGPoint(x: ox + w * 0.78, y: waistY))
                // 다리
                p.move(to: CGPoint(x: ox + w * 0.30, y: legSplitY))
                p.addLine(to: CGPoint(x: ox + w * 0.35, y: footY))
                p.move(to: CGPoint(x: ox + w * 0.70, y: legSplitY))
                p.addLine(to: CGPoint(x: ox + w * 0.65, y: footY))

            case .side:
                // 측면 실루엣: 옆모습
                let headW = w * 0.22, headH = h * 0.13
                let shoulderY = oy + h * 0.18
                let waistY = oy + h * 0.48
                let kneeY = oy + h * 0.74
                let footY = oy + h * 0.98

                // 머리 (타원)
                p.addEllipse(in: CGRect(
                    x: ox + (w - headW) / 2 + w * 0.05,  // 살짝 앞으로 (얼굴 방향)
                    y: oy + h * 0.02,
                    width: headW, height: headH
                ))
                // 목 → 어깨
                p.move(to: CGPoint(x: ox + w * 0.55, y: oy + h * 0.15))
                p.addLine(to: CGPoint(x: ox + w * 0.50, y: shoulderY))
                // 척추 (어깨 → 골반, S자 약간)
                p.move(to: CGPoint(x: ox + w * 0.50, y: shoulderY))
                p.addCurve(
                    to: CGPoint(x: ox + w * 0.48, y: waistY),
                    control1: CGPoint(x: ox + w * 0.46, y: shoulderY + h * 0.1),
                    control2: CGPoint(x: ox + w * 0.52, y: waistY - h * 0.05)
                )
                // 골반 → 무릎 → 발
                p.addLine(to: CGPoint(x: ox + w * 0.50, y: kneeY))
                p.addLine(to: CGPoint(x: ox + w * 0.48, y: footY))
            }
        }
    }
}

#Preview("Front") {
    ZStack {
        Color.gray
        PoseGuideOverlay(view: .front)
    }
    .ignoresSafeArea()
}

#Preview("Side") {
    ZStack {
        Color.gray
        PoseGuideOverlay(view: .side)
    }
    .ignoresSafeArea()
}
