import AVFoundation
import UIKit
import Observation

/// AVCaptureSession 관리 — 시작/중지, 사진 캡처
/// 기본: 후면 카메라, 세로 모드, 자동 포커스
@MainActor
@Observable
final class CameraSessionManager: NSObject {

    private(set) var isReady: Bool = false
    private(set) var errorMessage: String?

    let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private let sessionQueue = DispatchQueue(label: "com.pose.poseanalyzer.camera.session")

    private var captureContinuation: CheckedContinuation<UIImage, Error>?

    /// 세션 구성 (한 번만 호출)
    func configure() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            self.session.beginConfiguration()
            self.session.sessionPreset = .photo

            // 후면 카메라 입력
            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                  let input = try? AVCaptureDeviceInput(device: device),
                  self.session.canAddInput(input) else {
                Task { @MainActor in
                    self.errorMessage = "후면 카메라를 사용할 수 없습니다."
                }
                self.session.commitConfiguration()
                return
            }
            self.session.addInput(input)

            // 사진 출력
            if self.session.canAddOutput(self.photoOutput) {
                self.session.addOutput(self.photoOutput)
                self.photoOutput.maxPhotoQualityPrioritization = .quality
            }

            self.session.commitConfiguration()

            Task { @MainActor in
                self.isReady = true
            }
        }
    }

    /// 세션 시작
    func start() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            if !self.session.isRunning {
                self.session.startRunning()
            }
        }
    }

    /// 세션 중지
    func stop() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }

    /// 사진 캡처. async/await로 UIImage 반환
    func capturePhoto() async throws -> UIImage {
        try await withCheckedThrowingContinuation { continuation in
            self.captureContinuation = continuation
            let settings = AVCapturePhotoSettings()
            settings.flashMode = .auto
            photoOutput.capturePhoto(with: settings, delegate: self)
        }
    }
}

// MARK: - AVCapturePhotoCaptureDelegate

extension CameraSessionManager: AVCapturePhotoCaptureDelegate {
    nonisolated func photoOutput(_ output: AVCapturePhotoOutput,
                                 didFinishProcessingPhoto photo: AVCapturePhoto,
                                 error: Error?) {
        Task { @MainActor in
            defer { self.captureContinuation = nil }
            if let error = error {
                self.captureContinuation?.resume(throwing: error)
                return
            }
            guard let data = photo.fileDataRepresentation(),
                  let image = UIImage(data: data) else {
                self.captureContinuation?.resume(throwing: NSError(
                    domain: "CameraSessionManager", code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "사진 데이터를 추출할 수 없습니다."]
                ))
                return
            }
            self.captureContinuation?.resume(returning: image)
        }
    }
}
