import SwiftUI

/// 마법사의 사진 입력 단계 (정면 OR 측면 공통 컴포넌트)
struct WizardStepView: View {

    let view: SessionView   // .front 또는 .side
    let stepIndex: Int      // 1, 2
    let totalSteps: Int     // 3
    var onPicked: (UIImage) -> Void
    var onBack: () -> Void

    @State private var isInputSheetPresented = false

    var body: some View {
        VStack(spacing: 0) {
            // 진행 바
            progressBar

            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.s4) {
                    Text(subtitle)
                        .font(.appCallout)
                        .foregroundStyle(Color.fg2)
                        .padding(.top, AppSpacing.s4)

                    guideCard

                    AppButton {
                        isInputSheetPresented = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "camera.fill")
                            Text("\(view.koreanName) 사진 선택")
                        }
                    }
                    .padding(.top, AppSpacing.s2)
                }
                .padding(.horizontal, AppSpacing.s4)
                .padding(.bottom, AppSpacing.s10)
            }
        }
        .background(Color.bgCanvas)
        .navigationTitle("\(view.koreanName) 사진")
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
                    Text("\(view.koreanName) 사진")
                        .font(.appTitle)
                    Text("STEP \(stepIndex) / \(totalSteps)")
                        .font(.system(size: 11, weight: .semibold))
                        .kerning(0.01)
                        .foregroundStyle(Color.fg3)
                }
            }
        }
        .sheet(isPresented: $isInputSheetPresented) {
            PhotoInputSheet(isPresented: $isInputSheetPresented, view: view, step: stepIndex, onPicked: onPicked)
                .presentationDetents([.height(320)])
                .presentationDragIndicator(.hidden)
        }
    }

    // MARK: - Pieces

    private var subtitle: String {
        switch view {
        case .front: return "어깨와 골반이 보이도록 정면을 향해주세요"
        case .side: return "한쪽 옆모습 전체가 보이도록 서주세요"
        }
    }

    private var progressBar: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.border2)
                    .frame(height: 3)
                Capsule()
                    .fill(Color.brandPrimary)
                    .frame(width: proxy.size.width * CGFloat(stepIndex) / CGFloat(totalSteps), height: 3)
                    .animation(.easeOut(duration: 0.22), value: stepIndex)
            }
        }
        .frame(height: 3)
        .padding(.horizontal, AppSpacing.s4)
    }

    private var guideCard: some View {
        AppCard(padding: 0) {
            VStack(spacing: 0) {
                // 가이드 일러스트 (placeholder — 향후 SF Symbol + 외곽선)
                ZStack {
                    LinearGradient(
                        colors: [Color.gray.opacity(0.5), Color.gray.opacity(0.8)],
                        startPoint: .top, endPoint: .bottom
                    )
                    Image(systemName: view == .front ? "figure.stand" : "figure.walk")
                        .font(.system(size: 80, weight: .light))
                        .foregroundStyle(Color.white.opacity(0.85))

                    // 가이드 점선
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.white.opacity(0.55), style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                        .padding(20)
                }
                .frame(maxWidth: .infinity, minHeight: 280)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg - 4, style: .continuous))
                .overlay(alignment: .topLeading) {
                    Text(view == .front ? "정면 가이드" : "측면 가이드")
                        .font(.appMicro)
                        .foregroundStyle(Color.white)
                        .padding(.vertical, 4).padding(.horizontal, 10)
                        .background(Color.black.opacity(0.45), in: Capsule())
                        .padding(12)
                }
            }
        }
    }
}
