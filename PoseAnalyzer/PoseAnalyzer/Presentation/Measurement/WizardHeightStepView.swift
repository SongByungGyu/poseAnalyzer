import SwiftUI

/// 마법사 Step 3 — 키 입력
struct WizardHeightStepView: View {

    @Binding var heightCm: String
    var isValid: Bool
    var onBack: () -> Void
    var onSubmit: () -> Void
    var onSkip: () -> Void

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // 진행 바
            progressBar

            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.s4) {
                    Text("키를 입력하면 cm 단위로 비대칭을 분석합니다")
                        .font(.appCallout)
                        .foregroundStyle(Color.fg2)
                        .padding(.top, AppSpacing.s4)

                    AppCard {
                        VStack(alignment: .leading, spacing: AppSpacing.s2) {
                            Text("키 (cm)")
                                .font(.appCaption.bold())
                                .foregroundStyle(Color.fg2)
                            HStack {
                                TextField("170", text: $heightCm)
                                    .keyboardType(.numberPad)
                                    .font(.appMetric)
                                    .foregroundStyle(Color.fg1)
                                    .focused($isFocused)
                                Text("cm")
                                    .font(.appH2)
                                    .foregroundStyle(Color.fg3)
                            }
                            if !heightCm.isEmpty && !isValid {
                                Text("50~250cm 범위로 입력해주세요")
                                    .font(.appCaption)
                                    .foregroundStyle(Color.statusSuspect)
                            }
                        }
                    }

                    Text("한 번 입력한 키는 다음 측정에 자동으로 적용됩니다.")
                        .font(.appCaption)
                        .foregroundStyle(Color.fg3)
                        .padding(.top, AppSpacing.s1)

                    Spacer(minLength: AppSpacing.s7)

                    AppButton("분석 시작", isDisabled: !isValid, action: onSubmit)
                    AppButton("건너뛰기 (키 없이 진행)", variant: .ghost, size: .medium, action: onSkip)
                }
                .padding(.horizontal, AppSpacing.s4)
                .padding(.bottom, AppSpacing.s10)
            }
        }
        .background(Color.bgCanvas)
        .navigationTitle("키 입력")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(Color.brandPrimary)
                }
            }
            ToolbarItem(placement: .principal) {
                VStack(spacing: 1) {
                    Text("키 입력")
                        .font(.appTitle)
                    Text("STEP 3 / 3")
                        .font(.system(size: 11, weight: .semibold))
                        .kerning(0.01)
                        .foregroundStyle(Color.fg3)
                }
            }
        }
        .onAppear { isFocused = true }
    }

    private var progressBar: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.border2)
                    .frame(height: 3)
                Capsule()
                    .fill(Color.brandPrimary)
                    .frame(width: proxy.size.width, height: 3)
            }
        }
        .frame(height: 3)
        .padding(.horizontal, AppSpacing.s4)
    }
}
