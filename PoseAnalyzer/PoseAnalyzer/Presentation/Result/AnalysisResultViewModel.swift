import Foundation
import Observation

/// 분석 결과 화면 ViewModel
/// - 직전 측정 대비 변화 계산
/// - 저장 액션
@MainActor
@Observable
final class AnalysisResultViewModel {

    let report: SessionReport

    /// 직전 1건 (저장 전: 메모리 모드에서 가장 최근 저장된 세션)
    private(set) var previousSession: SessionRecord?

    /// 저장 완료 여부
    private(set) var isSaved: Bool = false

    /// 저장 진행 중
    private(set) var isSaving: Bool = false

    /// 에러 메시지
    var errorMessage: String?

    private let sessionRepository: SessionRepository

    init(report: SessionReport, sessionRepository: SessionRepository) {
        self.report = report
        self.sessionRepository = sessionRepository
        loadPreviousSession()
    }

    private func loadPreviousSession() {
        do {
            previousSession = try sessionRepository.fetchLatest(beforeID: report.id)
        } catch {
            previousSession = nil
        }
    }

    /// 저장 액션
    func save() {
        guard !isSaving, !isSaved else { return }
        isSaving = true
        do {
            try sessionRepository.save(report)
            isSaved = true
        } catch {
            errorMessage = "저장에 실패했습니다: \(error.localizedDescription)"
        }
        isSaving = false
    }

    /// 직전 측정 대비 변화 (정상→정상 또는 측정 가능한 경우만)
    /// 양수면 수치 증가, 음수면 감소. nil이면 비교 불가.
    func delta(for type: PostureType) -> Double? {
        guard let prev = previousSession else { return nil }
        let prevResult = prev.postures.first { $0.type == type }
        guard let prevResult, prevResult.status != .unmeasurable else { return nil }
        guard let current = report.postures.first(where: { $0.type == type }),
              current.status != .unmeasurable else { return nil }
        return current.primaryMetric - prevResult.primaryMetric
    }
}
