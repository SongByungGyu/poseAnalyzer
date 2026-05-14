import SwiftUI

/// 설정 화면 — 키 변경 + (향후) 임계값 튜닝 등
struct SettingsView: View {

    @Environment(\.dependencies) private var dependencies
    @Environment(\.dismiss) private var dismiss
    @State private var heightCm: String = ""
    @State private var saveSuccess: Bool = false

    var body: some View {
        Form {
            Section("프로필") {
                HStack {
                    Text("키 (cm)")
                        .font(.appBody)
                        .foregroundStyle(Color.fg1)
                    Spacer()
                    TextField("미입력", text: $heightCm)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.numberPad)
                        .font(.appBody.monospacedDigit())
                }
            }
            Section {
                Button("저장") { save() }
                    .disabled(!isValid)
            }
            Section {
                Text("키는 사진 속 신장 픽셀과 비교하여 어깨/골반 비대칭을 cm 단위로 환산하는 데 사용됩니다. 입력하지 않으면 어깨너비 비율로 표시됩니다.")
                    .font(.appCaption)
                    .foregroundStyle(Color.fg3)
            }
        }
        .navigationTitle("설정")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let saved = try? dependencies.userProfileRepository.getHeightCm() {
                heightCm = String(format: "%.0f", saved)
            }
        }
        .alert("저장 완료", isPresented: $saveSuccess) {
            Button("확인", role: .cancel) { dismiss() }
        }
    }

    private var isValid: Bool {
        if heightCm.isEmpty { return true }
        guard let v = Double(heightCm) else { return false }
        return (50.0...250.0).contains(v)
    }

    private func save() {
        let value: Double? = heightCm.isEmpty ? nil : Double(heightCm)
        try? dependencies.userProfileRepository.updateHeightCm(value)
        saveSuccess = true
    }
}
