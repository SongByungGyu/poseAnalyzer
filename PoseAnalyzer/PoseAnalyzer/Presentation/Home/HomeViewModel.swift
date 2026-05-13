import Foundation
import SwiftUI
import Observation

@MainActor
@Observable
final class HomeViewModel {

    /// 가장 최근 측정 세션 (없으면 nil)
    private(set) var latestSession: SessionRecord?

    /// 마법사 시트 표시 여부
    var isWizardPresented: Bool = false

    private let sessionRepository: SessionRepository

    init(sessionRepository: SessionRepository) {
        self.sessionRepository = sessionRepository
    }

    /// 화면 진입 시 / 측정 후 새로고침
    func refresh() {
        do {
            latestSession = try sessionRepository.fetchLatest()
        } catch {
            latestSession = nil
        }
    }

    /// "측정 시작" 액션
    func startMeasurement() {
        isWizardPresented = true
    }
}
