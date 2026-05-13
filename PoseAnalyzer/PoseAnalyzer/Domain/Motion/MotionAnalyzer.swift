import Foundation

/// 2차 영상 분석 인터페이스 (MVP에서는 구현 X)
/// 향후 SquatAnalyzer, RunningAnalyzer 등이 이 프로토콜을 구현
protocol MotionAnalyzer {
    var name: String { get }

    /// 시간순 PoseFrame 스트림을 받아 MotionResult 스트림 반환
    func analyze(_ stream: AsyncStream<PoseFrame>) -> AsyncStream<MotionResult>
}
