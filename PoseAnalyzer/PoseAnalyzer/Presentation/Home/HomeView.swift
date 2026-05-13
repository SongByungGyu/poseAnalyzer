import SwiftUI

/// 홈 화면 — 측정 진입점 + 최근 측정 요약
/// (Plan 2b Task 11에서 8 자세 grid + 상세 최근 측정 추가)
struct HomeView: View {

    @Environment(\.dependencies) private var dependencies
    @State private var viewModel: HomeViewModel?
    @State private var latestReport: SessionReport?
    @State private var showResult: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.s5) {
                hero
                if let vm = viewModel, vm.latestSession != nil {
                    recentSection(vm)
                }
            }
            .padding(.horizontal, AppSpacing.s4)
            .padding(.bottom, AppSpacing.s10)
        }
        .background(Color.bgCanvas)
        .navigationTitle("PoseAnalyzer")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if viewModel == nil {
                viewModel = HomeViewModel(sessionRepository: dependencies.sessionRepository)
            }
            viewModel?.refresh()
        }
        .sheet(isPresented: Binding(
            get: { viewModel?.isWizardPresented ?? false },
            set: { viewModel?.isWizardPresented = $0 }
        )) {
            MeasurementWizardView { report in
                // 분석 완료: 결과 화면으로 push
                latestReport = report
                showResult = true
            }
            .presentationDetents([.large])
        }
        .navigationDestination(isPresented: $showResult) {
            if let report = latestReport {
                ResultPlaceholderView(report: report)
            }
        }
    }

    // MARK: - Sections

    private var hero: some View {
        VStack(alignment: .leading, spacing: AppSpacing.s4) {
            VStack(alignment: .leading, spacing: AppSpacing.s1) {
                Text("오늘의 자세를\n측정해보세요")
                    .font(.appH1)
                    .foregroundStyle(Color.fg1)
                Text("정면·측면 사진 2장이면 충분합니다.")
                    .font(.appCallout)
                    .foregroundStyle(Color.fg2)
            }
            .padding(.top, AppSpacing.s2)

            ctaCard
        }
    }

    private var ctaCard: some View {
        Button {
            viewModel?.startMeasurement()
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("3 STEPS · 약 30초")
                        .font(.appMicro)
                        .kerning(0.04)
                        .textCase(.uppercase)
                        .foregroundStyle(Color.white.opacity(0.85))
                    Text("측정 시작")
                        .font(.appH2)
                        .foregroundStyle(Color.white)
                }
                Spacer()
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.18))
                        .frame(width: 52, height: 52)
                    Image(systemName: "camera.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(Color.white)
                }
            }
            .padding(.horizontal, AppSpacing.s5)
            .padding(.vertical, AppSpacing.s4)
            .background(
                LinearGradient(
                    colors: [Color.brandPrimary, Color.brandAccent],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: AppRadius.xl - 6, style: .continuous)
            )
            .appPopShadow()
        }
        .buttonStyle(.plain)
    }

    private func recentSection(_ vm: HomeViewModel) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.s2) {
            SectionHeader(title: "최근 측정") {
                NavigationLink(destination: Text("기록 화면 (Plan 2c)")) {
                    Text("전체 보기 ›")
                        .font(.appCaption)
                        .foregroundStyle(Color.brandPrimary)
                }
            }
            if let s = vm.latestSession {
                AppCard {
                    HStack(spacing: AppSpacing.s3) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(s.measuredAt, style: .date)
                                .font(.appCaption.bold())
                                .foregroundStyle(Color.fg1)
                            Text("자세 8가지 분석 완료")
                                .font(.appCaption)
                                .foregroundStyle(Color.fg2)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.fg3)
                    }
                }
            }
        }
    }
}

// MARK: - Environment

private struct DependenciesKey: EnvironmentKey {
    static let defaultValue: AppDependencies = AppDependencies()
}

extension EnvironmentValues {
    var dependencies: AppDependencies {
        get { self[DependenciesKey.self] }
        set { self[DependenciesKey.self] = newValue }
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
}
