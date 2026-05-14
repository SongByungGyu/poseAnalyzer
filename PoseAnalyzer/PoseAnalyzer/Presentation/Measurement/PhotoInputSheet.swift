import SwiftUI
import PhotosUI

/// 사진 입력 방식 선택 (카메라 / 라이브러리) 액션 시트
/// 시뮬레이터에서는 카메라 버튼 비활성화
struct PhotoInputSheet: View {

    @Binding var isPresented: Bool
    let view: SessionView    // 카메라 가이드 (정면/측면) 결정용
    /// 마법사 단계 번호 (1=정면, 2=측면). 카메라 STEP 배지 표시용. 옵션.
    var step: Int? = nil
    var onPicked: (UIImage) -> Void

    @State private var showLibrary = false
    @State private var showCamera = false
    @State private var pickerSelection: PhotosPickerItem?
    @State private var errorMessage: String?
    @State private var showCameraPermissionAlert = false

    var body: some View {
        VStack(spacing: AppSpacing.s3) {
            // 핸들
            Capsule()
                .fill(Color.border1)
                .frame(width: 40, height: 4)
                .padding(.top, AppSpacing.s3)

            Text("사진 선택")
                .font(.appH3)
                .foregroundStyle(Color.fg1)
                .padding(.top, AppSpacing.s2)

            VStack(spacing: AppSpacing.s2) {
                AppButton(
                    variant: .primary,
                    size: .large,
                    isDisabled: !CustomCameraView.isAvailable,
                    action: { handleCameraButton() }
                ) {
                    HStack(spacing: 8) {
                        Image(systemName: "camera.fill")
                        Text(CustomCameraView.isAvailable ? "카메라로 촬영" : "카메라 사용 불가 (시뮬레이터)")
                    }
                }

                AppButton(variant: .secondary, size: .large) {
                    showLibrary = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "photo.on.rectangle")
                        Text("라이브러리에서 선택")
                    }
                }

                AppButton("취소", variant: .ghost, size: .medium) {
                    isPresented = false
                }
            }
            .padding(.horizontal, AppSpacing.s4)
            .padding(.bottom, AppSpacing.s5)
        }
        .frame(maxWidth: .infinity)
        .background(Color.bgSurface)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous))
        // PhotosPicker는 iOS 16+ SwiftUI native modifier로 트리거
        .photosPicker(
            isPresented: $showLibrary,
            selection: $pickerSelection,
            matching: .images,
            photoLibrary: .shared()
        )
        .onChange(of: pickerSelection) { _, newItem in
            guard let item = newItem else { return }
            Task { await loadSelected(item: item) }
        }
        .fullScreenCover(isPresented: $showCamera) {
            CustomCameraView(
                view: view,
                step: step,
                onPicked: { image in
                    showCamera = false
                    isPresented = false
                    onPicked(image)
                },
                onCancel: {
                    showCamera = false
                }
            )
            .ignoresSafeArea()
        }
        .alert("사진 불러오기 실패", isPresented: .constant(errorMessage != nil)) {
            Button("확인") { errorMessage = nil }
        } message: {
            if let msg = errorMessage { Text(msg) }
        }
        .alert("카메라 권한이 필요합니다", isPresented: $showCameraPermissionAlert) {
            Button("설정 열기") {
                AppPermissions.openAppSettings()
            }
            Button("취소", role: .cancel) {}
        } message: {
            Text("자세 사진 촬영을 위해 카메라 접근이 필요합니다.\n설정 → PoseAnalyzer → 카메라에서 허용해주세요.")
        }
    }

    /// 카메라 버튼 액션 — 권한 상태에 따라 분기
    private func handleCameraButton() {
        Task {
            switch AppPermissions.cameraStatus {
            case .authorized:
                showCamera = true
            case .notDetermined:
                let granted = await AppPermissions.requestCamera()
                if granted {
                    showCamera = true
                } else {
                    showCameraPermissionAlert = true
                }
            case .denied:
                showCameraPermissionAlert = true
            }
        }
    }

    private func loadSelected(item: PhotosPickerItem) async {
        defer { pickerSelection = nil }
        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                isPresented = false
                onPicked(image)
            } else {
                errorMessage = "사진 데이터를 읽을 수 없습니다."
            }
        } catch {
            errorMessage = "사진 불러오기 중 오류: \(error.localizedDescription)"
        }
    }
}
