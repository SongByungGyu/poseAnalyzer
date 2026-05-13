import SwiftUI

/// Plan 2에서 실제 탭 화면으로 교체될 임시 루트
struct RootPlaceholderView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "figure.stand")
                .font(.system(size: 80))
                .foregroundStyle(.tint)
            Text("PoseAnalyzer")
                .font(.largeTitle.bold())
            Text("Foundation 완료. UI는 Plan 2에서 작성합니다.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .padding()
    }
}

#Preview {
    RootPlaceholderView()
}
