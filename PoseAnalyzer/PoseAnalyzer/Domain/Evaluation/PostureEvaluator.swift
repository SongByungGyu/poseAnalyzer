import Foundation

/// 단일 자세를 평가하는 책임
protocol PostureEvaluator {
    /// 어떤 자세를 판정하는지
    var type: PostureType { get }
    /// 어느 시점(정면/측면) 사진에 적용해야 하는지
    var requiredView: SessionView { get }
    /// 평가 실행
    func evaluate(_ frame: PoseFrame) -> PostureResult
}
