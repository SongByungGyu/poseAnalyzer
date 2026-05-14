import SwiftUI

/// 디자인 시스템 토스트 — 짧은 안내(성공/실패) 메시지
/// 사용: View에 .overlay(alignment: .top) { AppToast(...) } 또는 ZStack
struct AppToast: View {

    enum Style {
        case success, info, error

        var color: Color {
            switch self {
            case .success: return .statusNormal
            case .info: return .brandPrimary
            case .error: return .statusSuspect
            }
        }
        var backgroundColor: Color {
            switch self {
            case .success: return .statusNormalBG
            case .info: return .brandPrimarySoft
            case .error: return .statusSuspectBG
            }
        }
        var iconName: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .info: return "info.circle.fill"
            case .error: return "exclamationmark.circle.fill"
            }
        }
    }

    let text: String
    var style: Style = .success

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: style.iconName)
                .font(.system(size: 16, weight: .semibold))
            Text(text)
                .font(.appCallout.bold())
        }
        .foregroundStyle(style.color)
        .padding(.horizontal, AppSpacing.s4)
        .padding(.vertical, AppSpacing.s2)
        .background(style.backgroundColor, in: Capsule())
        .overlay(Capsule().strokeBorder(style.color.opacity(0.3), lineWidth: 1))
        .appCardShadow()
    }
}

#Preview {
    VStack(spacing: 16) {
        AppToast(text: "저장되었습니다", style: .success)
        AppToast(text: "사진을 불러왔습니다", style: .info)
        AppToast(text: "저장에 실패했습니다", style: .error)
    }
    .padding()
    .background(Color.bgCanvas)
}
