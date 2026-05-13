import SwiftUI

/// 개별 자세 결과 카드 — 좌측 status indicator strip + 자세명 + 배지 + 핵심 수치 + 게이지
struct PostureResultCard: View {

    let result: PostureResult

    var body: some View {
        ZStack(alignment: .leading) {
            // 좌측 status indicator strip
            Rectangle()
                .fill(result.status.color)
                .frame(width: 4)
                .frame(maxHeight: .infinity)
                .padding(.vertical, AppSpacing.s3)

            VStack(alignment: .leading, spacing: AppSpacing.s2) {
                header
                metric
                if result.status != .unmeasurable {
                    gauge
                }
                if let advice = result.advice {
                    Text(advice)
                        .font(.appCaption)
                        .foregroundStyle(Color.fg2)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.leading, AppSpacing.s4)
            .padding(.trailing, AppSpacing.s4)
            .padding(.vertical, AppSpacing.s3)
        }
        .background(Color.bgSurface, in: RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                .strokeBorder(Color.border1, lineWidth: 1)
        )
        .appCardShadow()
    }

    // MARK: - Pieces

    private var header: some View {
        HStack {
            Text(result.type.koreanName)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(Color.fg1)
            Spacer()
            StatusBadge(status: result.status, tone: .soft, size: .small)
        }
    }

    private var metric: some View {
        HStack(alignment: .firstTextBaseline, spacing: 3) {
            if result.status == .unmeasurable {
                Text("—")
                    .font(.system(size: 26, weight: .bold).monospacedDigit())
                    .foregroundStyle(Color.fg3)
            } else {
                Text(formattedMetric)
                    .font(.system(size: 26, weight: .bold).monospacedDigit())
                    .foregroundStyle(Color.fg1)
                Text(result.primaryMetricUnit.symbol)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.fg3)
            }
        }
    }

    private var formattedMetric: String {
        let v = result.primaryMetric
        let isAngle = result.primaryMetricUnit == .degree
        return isAngle
            ? String(format: "%.0f", v)
            : String(format: "%.2f", v)
    }

    private var gauge: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.statusNormal,
                                Color.statusCaution,
                                Color.statusSuspect,
                            ],
                            startPoint: .leading, endPoint: .trailing
                        ).opacity(0.22)
                    )

                let markerX = markerPosition(width: proxy.size.width)
                Rectangle()
                    .fill(Color.brandInk)
                    .frame(width: 3, height: 10)
                    .offset(x: markerX - 1.5, y: -3)
            }
        }
        .frame(height: 4)
        .clipShape(Capsule())
    }

    private func markerPosition(width: CGFloat) -> CGFloat {
        switch result.status {
        case .normal: return width * 0.18
        case .caution: return width * 0.52
        case .suspect: return width * 0.84
        case .unmeasurable: return width * 0.50
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        PostureResultCard(result: .init(
            type: .forwardHead, status: .normal,
            primaryMetric: 172, primaryMetricUnit: .degree,
            thresholds: Thresholds(normalRange: 170...360, cautionRange: 160...170, direction: .higherIsNormal),
            usedJointNames: [], confidence: 0.9,
            advice: nil
        ))
        PostureResultCard(result: .init(
            type: .roundShoulder, status: .caution,
            primaryMetric: 0.21, primaryMetricUnit: .ratio,
            thresholds: Thresholds(normalRange: 0...0.15, cautionRange: 0.15...0.25, direction: .lowerIsNormal),
            usedJointNames: [], confidence: 0.85,
            advice: "어깨를 뒤로 펴는 스트레칭을 정기적으로 해주세요."
        ))
        PostureResultCard(result: .unmeasurable(type: .scoliosis, reason: "양 어깨 관절 신뢰도 부족"))
    }
    .padding()
    .background(Color.bgCanvas)
}
