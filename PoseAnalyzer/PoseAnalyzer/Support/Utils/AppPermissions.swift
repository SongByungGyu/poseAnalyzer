import AVFoundation
import UIKit

/// 카메라/사진 권한 상태 조회 + 요청 + 설정 앱 열기
enum AppPermissions {

    enum Status {
        case authorized       // 허용됨
        case denied           // 거부됨 (사용자가 명시적으로 거부 또는 시스템 제한)
        case notDetermined    // 아직 묻지 않음
    }

    // MARK: - Camera

    static var cameraStatus: Status {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: return .authorized
        case .denied, .restricted: return .denied
        case .notDetermined: return .notDetermined
        @unknown default: return .denied
        }
    }

    /// 카메라 권한 요청. 결과: true=허용, false=거부
    @discardableResult
    static func requestCamera() async -> Bool {
        await AVCaptureDevice.requestAccess(for: .video)
    }

    // MARK: - Open Settings

    /// 앱 설정 화면 열기 (사용자가 권한 변경하러 가도록)
    @MainActor
    static func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
