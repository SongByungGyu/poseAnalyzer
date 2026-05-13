import SwiftUI
import PhotosUI

/// SwiftUI native PhotosPicker 래퍼 — 1장만 선택, UIImage로 변환
struct PhotoLibraryPicker: View {

    @Binding var isPresented: Bool
    var onPicked: (UIImage) -> Void

    @State private var selection: PhotosPickerItem?
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?

    var body: some View {
        PhotosPicker(
            selection: $selection,
            matching: .images,
            photoLibrary: .shared()
        ) {
            EmptyView()
        }
        .onChange(of: selection) { _, newItem in
            guard let item = newItem else { return }
            Task {
                await load(item: item)
            }
        }
        .alert("사진 불러오기 실패", isPresented: .constant(errorMessage != nil), actions: {
            Button("확인") { errorMessage = nil }
        }, message: {
            if let msg = errorMessage {
                Text(msg)
            }
        })
    }

    private func load(item: PhotosPickerItem) async {
        isLoading = true
        defer {
            isLoading = false
            selection = nil
            isPresented = false
        }
        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                onPicked(image)
            } else {
                errorMessage = "사진 데이터를 읽을 수 없습니다."
            }
        } catch {
            errorMessage = "사진 불러오기 중 오류: \(error.localizedDescription)"
        }
    }
}
