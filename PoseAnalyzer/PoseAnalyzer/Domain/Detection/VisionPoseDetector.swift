import UIKit
import Vision

/// Apple Vision Framework 기반 PoseDetector 구현
final class VisionPoseDetector: PoseDetector {

    func detect(image: UIImage, view: SessionView) async throws -> PoseFrame {
        guard let cgImage = image.cgImage else {
            throw PoseDetectionError.invalidImage
        }
        let orientation = CGImagePropertyOrientation(image.imageOrientation)

        return try await withCheckedThrowingContinuation { continuation in
            let request = VNDetectHumanBodyPoseRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: PoseDetectionError.visionFailed(message: error.localizedDescription))
                    return
                }

                guard let observations = request.results as? [VNHumanBodyPoseObservation],
                      !observations.isEmpty else {
                    continuation.resume(throwing: PoseDetectionError.noPersonDetected)
                    return
                }

                // 여러 명이면 bounding box 가장 큰 1명 선택 (스펙)
                // VNHumanBodyPoseObservation은 boundingBox 속성이 없어
                // 인식된 관절들의 좌표로 bounding box 면적을 계산
                let chosen: VNHumanBodyPoseObservation
                if observations.count == 1 {
                    chosen = observations[0]
                } else {
                    chosen = observations.max(by: { lhs, rhs in
                        Self.boundingBoxArea(of: lhs) < Self.boundingBoxArea(of: rhs)
                    })!
                }

                do {
                    let frame = try Self.makeFrame(
                        from: chosen, view: view, imageSize: image.size
                    )
                    continuation.resume(returning: frame)
                } catch {
                    continuation.resume(throwing: PoseDetectionError.visionFailed(message: "관절 추출 실패: \(error.localizedDescription)"))
                }
            }

            let handler = VNImageRequestHandler(cgImage: cgImage, orientation: orientation, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: PoseDetectionError.visionFailed(message: error.localizedDescription))
            }
        }
    }

    private static func makeFrame(
        from observation: VNHumanBodyPoseObservation,
        view: SessionView,
        imageSize: CGSize
    ) throws -> PoseFrame {
        let recognized = try observation.recognizedPoints(.all)
        var joints: [VNHumanBodyPoseObservation.JointName: PoseFrame.Joint] = [:]

        for (name, point) in recognized {
            // Vision은 정규화 좌표 (0~1, 좌하단 원점) 반환
            joints[name] = PoseFrame.Joint(
                name: name,
                location: point.location,
                confidence: point.confidence
            )
        }

        return PoseFrame(joints: joints, view: view, imageSize: imageSize)
    }

    /// 인식된 관절들로부터 bounding box 면적을 계산 (정규화 좌표 기준)
    private static func boundingBoxArea(of observation: VNHumanBodyPoseObservation) -> CGFloat {
        guard let recognized = try? observation.recognizedPoints(.all) else {
            return 0
        }
        let points = recognized.values.filter { $0.confidence > 0 }
        guard !points.isEmpty else { return 0 }

        let xs = points.map { $0.location.x }
        let ys = points.map { $0.location.y }
        let width = (xs.max() ?? 0) - (xs.min() ?? 0)
        let height = (ys.max() ?? 0) - (ys.min() ?? 0)
        return width * height
    }
}

// MARK: - CGImagePropertyOrientation Helper

private extension CGImagePropertyOrientation {
    init(_ uiOrientation: UIImage.Orientation) {
        switch uiOrientation {
        case .up: self = .up
        case .upMirrored: self = .upMirrored
        case .down: self = .down
        case .downMirrored: self = .downMirrored
        case .left: self = .left
        case .leftMirrored: self = .leftMirrored
        case .right: self = .right
        case .rightMirrored: self = .rightMirrored
        @unknown default: self = .up
        }
    }
}
