import SwiftUI

/// 사진 입력 방식 선택 (카메라 / 라이브러리) 액션 시트
/// 시뮬레이터에서는 카메라 버튼 비활성화
struct PhotoInputSheet: View {

    @Binding var isPresented: Bool
    var onPicked: (UIImage) -> Void

    @State private var showLibrary = false
    @State private var showCamera = false

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
                    isDisabled: !CameraImagePicker.isAvailable,
                    action: { showCamera = true }
                ) {
                    HStack(spacing: 8) {
                        Image(systemName: "camera.fill")
                        Text(CameraImagePicker.isAvailable ? "카메라로 촬영" : "카메라 사용 불가 (시뮬레이터)")
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
        // PhotosPicker는 자체 sheet 처리하므로 background에 둠
        .background(
            PhotoLibraryPicker(isPresented: $showLibrary) { image in
                isPresented = false
                onPicked(image)
            }
        )
        .fullScreenCover(isPresented: $showCamera) {
            CameraImagePicker(
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
    }
}
