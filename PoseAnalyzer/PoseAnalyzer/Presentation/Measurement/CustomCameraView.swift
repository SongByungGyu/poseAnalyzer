import SwiftUI

/// AVCaptureSession 기반 커스텀 카메라 화면
/// - 라이브 프리뷰 + 자세 가이드 오버레이 + 셔터 버튼
/// - 정면(.front) / 측면(.side)에 따라 가이드 모양 다름
struct CustomCameraView: View {

    let view: SessionView
    /// 마법사 현재 단계 (1=정면, 2=측면). PoseGuideOverlay의 STEP 배지에 표시.
    var step: Int? = nil
    var onPicked: (UIImage) -> Void
    var onCancel: () -> Void

    /// 시뮬레이터에서는 카메라 사용 불가
    static var isAvailable: Bool {
        #if targetEnvironment(simulator)
        return false
        #else
        return true
        #endif
    }

    @State private var manager = CameraSessionManager()
    @State private var isCapturing = false
    @State private var errorMessage: String?

    var body: some View {
        // 외부 GeometryReader가 safeAreaInsets을 명시적으로 들고 있고,
        // 내부 ZStack은 .ignoresSafeArea로 풀스크린 차지. UI는 safe area 안.
        GeometryReader { geo in
            ZStack {
                // 배경 (시뮬레이터 또는 권한 거부 등 fallback)
                Color.black

                // 1) 카메라 프리뷰
                if manager.isReady {
                    CameraPreviewView(session: manager.session)

                    // 2) 자세 가이드 오버레이 (STEP 배지 포함)
                    PoseGuideOverlay(view: view, step: step)
                } else if let msg = manager.errorMessage {
                    VStack(spacing: AppSpacing.s3) {
                        Image(systemName: "camera.metering.unknown")
                            .font(.system(size: 44, weight: .light))
                            .foregroundStyle(Color.white.opacity(0.8))
                        Text(msg)
                            .font(.appCallout)
                            .foregroundStyle(Color.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, AppSpacing.s5)
                    }
                } else {
                    ProgressView()
                        .tint(.white)
                }

                // 3) 상단 닫기 버튼 — safeAreaInsets.top 명시 적용
                VStack {
                    HStack {
                        Spacer()
                        Button(action: onCancel) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 32))
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(Color.white, Color.black.opacity(0.45))
                        }
                        .accessibilityLabel("닫기")
                        .padding(.trailing, AppSpacing.s4)
                    }
                    .padding(.top, geo.safeAreaInsets.top + AppSpacing.s2)
                    Spacer()
                }

                // 4) 하단 셔터 버튼 — safeAreaInsets.bottom 명시 적용
                VStack {
                    Spacer()
                    Button(action: capture) {
                        ZStack {
                            Circle()
                                .stroke(Color.white, lineWidth: 4)
                                .frame(width: 76, height: 76)
                            Circle()
                                .fill(Color.white)
                                .frame(width: 62, height: 62)
                            if isCapturing {
                                ProgressView()
                                    .tint(Color.brandInk)
                            }
                        }
                    }
                    .disabled(isCapturing || !manager.isReady)
                    .accessibilityLabel("촬영")
                    .padding(.bottom, geo.safeAreaInsets.bottom + AppSpacing.s5)
                }
            }
            .ignoresSafeArea()
        }
        .alert("촬영 실패", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("확인", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "")
        }
        .task {
            manager.configure()
            // configure 후 isReady 트리거를 기다린다.
            for _ in 0..<20 where !manager.isReady {
                try? await Task.sleep(nanoseconds: 100_000_000)
            }
            manager.start()
        }
        .onDisappear {
            manager.stop()
        }
    }

    private func capture() {
        guard !isCapturing else { return }
        isCapturing = true
        Task {
            do {
                let image = try await manager.capturePhoto()
                isCapturing = false
                onPicked(image)
            } catch {
                isCapturing = false
                errorMessage = "촬영 중 오류: \(error.localizedDescription)"
            }
        }
    }
}
