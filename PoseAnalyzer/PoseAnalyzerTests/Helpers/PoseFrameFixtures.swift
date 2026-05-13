import CoreGraphics
import Vision
@testable import PoseAnalyzer

/// 테스트에서 PoseFrame을 쉽게 생성하기 위한 fixture 헬퍼
extension PoseFrame {

    /// 빈 PoseFrame
    static func empty(view: SessionView = .side, imageSize: CGSize = CGSize(width: 1000, height: 1000)) -> PoseFrame {
        return PoseFrame(joints: [:], view: view, imageSize: imageSize)
    }

    /// 임의 관절 좌표로 PoseFrame 생성
    static func make(
        view: SessionView = .side,
        imageSize: CGSize = CGSize(width: 1000, height: 1000),
        confidence: Float = 0.9,
        _ pairs: [(VNHumanBodyPoseObservation.JointName, CGPoint)]
    ) -> PoseFrame {
        var dict: [VNHumanBodyPoseObservation.JointName: PoseFrame.Joint] = [:]
        for (name, point) in pairs {
            dict[name] = PoseFrame.Joint(name: name, location: point, confidence: confidence)
        }
        return PoseFrame(joints: dict, view: view, imageSize: imageSize)
    }

    /// 거북목 측면 테스트용: 귀-어깨-엉덩이 각도를 지정해서 좌표 자동 생성
    /// vertex는 (0.5, 0.5), p1과 p2의 거리는 0.2씩
    static func sideViewWithAngle(
        _ angleDegrees: Double,
        atJoints jointTriple: (VNHumanBodyPoseObservation.JointName,
                              VNHumanBodyPoseObservation.JointName,
                              VNHumanBodyPoseObservation.JointName),
        confidence: Float = 0.9
    ) -> PoseFrame {
        // vertex를 중심으로 p1은 위쪽, p2는 아래쪽
        let vertex = CGPoint(x: 0.5, y: 0.5)
        let radius = 0.2
        // p1: vertex 위쪽 수직
        let p1 = CGPoint(x: 0.5, y: 0.5 + radius)
        // p2: vertex 기준 angleDegrees만큼 내려간 위치
        // angleDegrees = 180이면 p2는 vertex 아래 수직
        let theta = (180 - angleDegrees) * .pi / 180  // p1에서 시계방향으로 angleDegrees 만큼
        let p2 = CGPoint(
            x: vertex.x + radius * sin(theta),
            y: vertex.y - radius * cos(theta)
        )
        return make(view: .side, confidence: confidence, [
            (jointTriple.0, p1),
            (jointTriple.1, vertex),
            (jointTriple.2, p2),
        ])
    }
}
