import SwiftUI

/// Plan 2c에서 실제 AnalysisResultView로 교체될 임시 결과 화면
struct ResultPlaceholderView: View {

    let report: SessionReport

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.s4) {
                AppCard {
                    VStack(alignment: .leading, spacing: AppSpacing.s2) {
                        Text("측정 완료")
                            .font(.appH2)
                            .foregroundStyle(Color.fg1)
                        Text("측정 시각: \(report.measuredAt.formatted(date: .abbreviated, time: .shortened))")
                            .font(.appCaption)
                            .foregroundStyle(Color.fg2)
                        Text("자세 결과: \(report.postures.count)개")
                            .font(.appCaption)
                            .foregroundStyle(Color.fg2)
                        Text("키: \(report.heightCmAtMeasure.map { "\(Int($0))cm" } ?? "미입력")")
                            .font(.appCaption)
                            .foregroundStyle(Color.fg2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                ForEach(report.postures.indices, id: \.self) { i in
                    let p = report.postures[i]
                    HStack {
                        Text(p.type.koreanName)
                            .font(.appBody)
                            .foregroundStyle(Color.fg1)
                        Spacer()
                        StatusBadge(status: p.status, tone: .soft, size: .small)
                        Text("\(String(format: "%.1f", p.primaryMetric))\(p.primaryMetricUnit.symbol)")
                            .font(.appCaption.monospacedDigit())
                            .foregroundStyle(Color.fg2)
                    }
                    .padding(.horizontal, AppSpacing.s4)
                    .padding(.vertical, AppSpacing.s2)
                    .background(Color.bgSurface, in: RoundedRectangle(cornerRadius: AppRadius.md))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.md)
                            .strokeBorder(Color.border1, lineWidth: 1)
                    )
                }

                Text("Plan 2c에서 사진 + 관절 오버레이 + 비대칭 + 직전 대비 변화 추가")
                    .font(.appCaption)
                    .foregroundStyle(Color.fg3)
                    .padding(.top, AppSpacing.s4)
            }
            .padding(.horizontal, AppSpacing.s4)
            .padding(.bottom, AppSpacing.s10)
        }
        .background(Color.bgCanvas)
        .navigationTitle("분석 결과")
        .navigationBarTitleDisplayMode(.inline)
    }
}
