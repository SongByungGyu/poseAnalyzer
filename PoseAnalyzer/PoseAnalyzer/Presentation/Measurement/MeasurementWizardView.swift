import SwiftUI

/// 측정 마법사 — Step 1(정면) → Step 2(측면) → Step 3(키) → Analyzing → Done
struct MeasurementWizardView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.dependencies) private var dependencies

    /// 분석 완료 시 SessionReport 전달 (호출자에서 결과 화면으로 라우팅)
    var onCompleted: (SessionReport) -> Void

    @State private var viewModel: MeasurementViewModel?

    var body: some View {
        NavigationStack {
            Group {
                if let vm = viewModel {
                    content(vm)
                } else {
                    ProgressView().onAppear {
                        viewModel = MeasurementViewModel(
                            analyzeUseCase: dependencies.analyzeSessionUseCase,
                            userProfileRepository: dependencies.userProfileRepository
                        )
                    }
                }
            }
        }
        .interactiveDismissDisabled(viewModel?.step == .analyzing)
        .alert("분석 실패", isPresented: Binding(
            get: { viewModel?.errorMessage != nil },
            set: { if !$0 { viewModel?.errorMessage = nil } }
        )) {
            Button("다시 측정") { viewModel?.retryFromBeginning() }
            Button("닫기", role: .cancel) { dismiss() }
        } message: {
            if let msg = viewModel?.errorMessage { Text(msg) }
        }
    }

    @ViewBuilder
    private func content(_ vm: MeasurementViewModel) -> some View {
        switch vm.step {
        case .front:
            WizardStepView(
                view: .front,
                stepIndex: 1,
                totalSteps: 3,
                onPicked: { image in vm.setFrontImage(image) },
                onBack: { dismiss() }
            )
        case .side:
            WizardStepView(
                view: .side,
                stepIndex: 2,
                totalSteps: 3,
                onPicked: { image in vm.setSideImage(image) },
                onBack: { vm.retryFromBeginning() }
            )
        case .height:
            WizardHeightStepView(
                heightCm: Binding(get: { vm.heightCm }, set: { vm.heightCm = $0 }),
                isValid: vm.isHeightValid,
                onBack: { /* 키 단계에서 뒤로는 dismiss로 단순화 (재측정은 alert 흐름) */ dismiss() },
                onSubmit: { vm.submitHeight() },
                onSkip: { vm.skipHeight() }
            )
        case .analyzing:
            AnalyzingView(phase: vm.analyzingPhase)
        case .done:
            // Plan 2c 결과 화면으로 라우팅
            DoneRouter(report: vm.report) { report in
                onCompleted(report)
                dismiss()
            }
        }
    }
}

/// step==.done일 때 SessionReport를 부모에 전달 후 dismiss (Plan 2c에서 결과 화면으로 push)
private struct DoneRouter: View {
    let report: SessionReport?
    var onReady: (SessionReport) -> Void
    var body: some View {
        ZStack {
            Color.bgCanvas.ignoresSafeArea()
            ProgressView()
        }
        .onAppear {
            if let report {
                onReady(report)
            }
        }
    }
}
