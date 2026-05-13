import SwiftUI
import Vision

/// PoseFrame 좌표를 사진 위에 점·선으로 오버레이
/// Vision은 좌하단 원점이라 Y를 뒤집어 SwiftUI 좌상단 원점으로 변환
struct PoseOverlayView: View {

    let image: UIImage
    let frame: PoseFrame
    var nodeColor: Color = .brandPrimary
    var lineColor: Color = .brandMint
    var lineWidth: CGFloat = 2
    var nodeRadius: CGFloat = 4
    var lowConfidenceOpacity: Double = 0.3

    /// 시각화할 골격 라인 (관절 짝)
    private let bones: [(VNHumanBodyPoseObservation.JointName, VNHumanBodyPoseObservation.JointName)] = [
        (.nose, .neck),
        (.neck, .leftShoulder), (.neck, .rightShoulder),
        (.leftShoulder, .leftElbow), (.leftElbow, .leftWrist),
        (.rightShoulder, .rightElbow), (.rightElbow, .rightWrist),
        (.leftShoulder, .leftHip), (.rightShoulder, .rightHip),
        (.leftHip, .rightHip),
        (.leftHip, .leftKnee), (.leftKnee, .leftAnkle),
        (.rightHip, .rightKnee), (.rightKnee, .rightAnkle),
    ]

    var body: some View {
        GeometryReader { proxy in
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .overlay(
                    Canvas { ctx, size in
                        // 1) 본 연결선
                        for (a, b) in bones {
                            guard let pa = frame.joints[a], let pb = frame.joints[b] else { continue }
                            let minConf = min(pa.confidence, pb.confidence)
                            let opacity = minConf < 0.3 ? lowConfidenceOpacity : 1.0
                            let p1 = swiftUIPoint(pa.location, in: size)
                            let p2 = swiftUIPoint(pb.location, in: size)
                            var path = Path()
                            path.move(to: p1)
                            path.addLine(to: p2)
                            ctx.stroke(
                                path,
                                with: .color(lineColor.opacity(opacity)),
                                style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                            )
                        }
                        // 2) 관절 노드
                        for (_, joint) in frame.joints {
                            let opacity = joint.confidence < 0.3 ? lowConfidenceOpacity : 1.0
                            let center = swiftUIPoint(joint.location, in: size)
                            let rect = CGRect(
                                x: center.x - nodeRadius,
                                y: center.y - nodeRadius,
                                width: nodeRadius * 2,
                                height: nodeRadius * 2
                            )
                            ctx.fill(Path(ellipseIn: rect), with: .color(nodeColor.opacity(opacity)))
                            ctx.stroke(
                                Path(ellipseIn: rect),
                                with: .color(Color.white.opacity(opacity)),
                                lineWidth: 1
                            )
                        }
                    }
                )
        }
    }

    /// Vision 정규화 좌표(좌하단) → SwiftUI 픽셀 좌표(좌상단)
    private func swiftUIPoint(_ p: CGPoint, in size: CGSize) -> CGPoint {
        CGPoint(x: p.x * size.width, y: (1 - p.y) * size.height)
    }
}

#Preview {
    Text("PoseOverlayView preview — 실제 측정 후 결과 화면에서 확인")
        .padding()
}
