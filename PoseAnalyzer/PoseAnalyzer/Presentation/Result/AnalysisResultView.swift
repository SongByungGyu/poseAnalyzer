import SwiftUI

/// 분석 결과 화면 — 사진 + 관절 오버레이 + 8 자세 카드 + 비대칭 + 직전 비교
struct AnalysisResultView: View {

    let report: SessionReport
    var isReadOnly: Bool = false  // 기록 탭에서 진입 시 true

    @Environment(\.dependencies) private var dependencies
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: AnalysisResultViewModel?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.s5) {
                photosSection
                if let vm = viewModel {
                    posturesSection(vm)
                    asymmetrySection
                    if !isReadOnly { previousComparisonSection(vm) }
                }
            }
            .padding(.horizontal, AppSpacing.s4)
            .padding(.bottom, AppSpacing.s10)
        }
        .background(Color.bgCanvas)
        .navigationTitle("분석 결과")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !isReadOnly, let vm = viewModel, !vm.isSaved {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { vm.save() }) {
                        if vm.isSaving {
                            ProgressView()
                        } else {
                            Text("저장")
                                .font(.appCaption.bold())
                                .foregroundStyle(Color.brandPrimary)
                        }
                    }
                    .disabled(vm.isSaving)
                }
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = AnalysisResultViewModel(
                    report: report,
                    sessionRepository: dependencies.sessionRepository
                )
            }
        }
        .alert("저장 실패", isPresented: Binding(
            get: { viewModel?.errorMessage != nil },
            set: { if !$0 { viewModel?.errorMessage = nil } }
        )) {
            Button("확인", role: .cancel) {}
        } message: {
            Text(viewModel?.errorMessage ?? "")
        }
    }

    // MARK: - Sections

    private var photosSection: some View {
        HStack(spacing: AppSpacing.s2) {
            photoCard(image: report.frontImage, frame: report.frontFrame, label: "정면")
            photoCard(image: report.sideImage, frame: report.sideFrame, label: "측면")
        }
        .padding(.top, AppSpacing.s2)
    }

    private func photoCard(image: UIImage, frame: PoseFrame, label: String) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.s1) {
            Text(label)
                .font(.appMicro)
                .foregroundStyle(Color.fg3)
                .textCase(.uppercase)
            PoseOverlayView(image: image, frame: frame)
                .aspectRatio(3/4, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                        .strokeBorder(Color.border1, lineWidth: 1)
                )
        }
    }

    private func posturesSection(_ vm: AnalysisResultViewModel) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.s2) {
            SectionHeader("자세 판정 (8가지)")
            VStack(spacing: AppSpacing.s2) {
                ForEach(report.postures.indices, id: \.self) { i in
                    PostureResultCard(result: report.postures[i])
                }
            }
        }
    }

    private var asymmetrySection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.s2) {
            SectionHeader("좌우 비대칭")
            AppCard {
                VStack(alignment: .leading, spacing: AppSpacing.s2) {
                    asymmetryRow(label: "어깨", diff: report.asymmetry.shoulder)
                    Divider()
                    asymmetryRow(label: "골반", diff: report.asymmetry.hip)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private func asymmetryRow(label: String, diff: AsymmetryResult.Difference) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label)
                .font(.appBody)
                .foregroundStyle(Color.fg2)
                .frame(width: 40, alignment: .leading)
            Text(diff.direction.koreanName)
                .font(.appBody.bold())
                .foregroundStyle(diff.direction == .balanced ? Color.statusNormal : Color.statusCaution)
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                if let cm = diff.cm {
                    Text("\(String(format: "%.1f", cm))cm 차이")
                        .font(.appCaption.monospacedDigit())
                        .foregroundStyle(Color.fg1)
                }
                Text("기울기 \(String(format: "%.1f", diff.angleDegrees))°")
                    .font(.appMicro.monospacedDigit())
                    .foregroundStyle(Color.fg3)
            }
        }
    }

    @ViewBuilder
    private func previousComparisonSection(_ vm: AnalysisResultViewModel) -> some View {
        if vm.previousSession != nil {
            VStack(alignment: .leading, spacing: AppSpacing.s2) {
                SectionHeader("직전 측정 대비")
                AppCard {
                    VStack(alignment: .leading, spacing: AppSpacing.s2) {
                        ForEach(report.postures.indices, id: \.self) { i in
                            let type = report.postures[i].type
                            if let d = vm.delta(for: type) {
                                comparisonRow(type: type, delta: d, unit: report.postures[i].primaryMetricUnit)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }

    private func comparisonRow(type: PostureType, delta: Double, unit: PostureResult.MetricUnit) -> some View {
        let isImproved = abs(delta) < 0.5
        let symbol = delta > 0.05 ? "arrow.up.right" : delta < -0.05 ? "arrow.down.right" : "arrow.right"
        let color = isImproved ? Color.fg3 : (delta > 0 ? Color.statusCaution : Color.statusNormal)
        return HStack {
            Text(type.koreanName)
                .font(.appCallout)
                .foregroundStyle(Color.fg1)
            Spacer()
            Image(systemName: symbol)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(color)
            Text("\(delta > 0 ? "+" : "")\(String(format: "%.1f", delta))\(unit.symbol)")
                .font(.appCaption.bold().monospacedDigit())
                .foregroundStyle(color)
        }
    }
}
