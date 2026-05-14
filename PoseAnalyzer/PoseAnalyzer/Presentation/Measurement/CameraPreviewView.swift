import SwiftUI
import AVFoundation

/// AVCaptureSession의 라이브 프리뷰를 SwiftUI에 표시
struct CameraPreviewView: UIViewRepresentable {

    let session: AVCaptureSession

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        if let connection = view.videoPreviewLayer.connection,
           connection.isVideoRotationAngleSupported(90) {
            connection.videoRotationAngle = 90  // 세로 모드
        }
        return view
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {
        // 별도 업데이트 필요 없음
    }

    /// AVCaptureVideoPreviewLayer를 layer로 가진 UIView
    final class PreviewView: UIView {
        override class var layerClass: AnyClass {
            AVCaptureVideoPreviewLayer.self
        }
        var videoPreviewLayer: AVCaptureVideoPreviewLayer {
            layer as! AVCaptureVideoPreviewLayer
        }
    }
}
