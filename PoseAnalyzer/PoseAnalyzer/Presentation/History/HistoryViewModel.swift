import Foundation
import Observation

@MainActor
@Observable
final class HistoryViewModel {

    private(set) var sessions: [SessionRecord] = []
    var errorMessage: String?

    private let sessionRepository: SessionRepository

    init(sessionRepository: SessionRepository) {
        self.sessionRepository = sessionRepository
    }

    func refresh() {
        do {
            sessions = try sessionRepository.fetchAll()
        } catch {
            sessions = []
            errorMessage = "기록 조회 실패: \(error.localizedDescription)"
        }
    }

    func delete(id: UUID) {
        do {
            try sessionRepository.delete(id: id)
            refresh()
        } catch {
            errorMessage = "삭제 실패: \(error.localizedDescription)"
        }
    }
}
