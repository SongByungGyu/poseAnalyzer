import Foundation
import SwiftUI
import UIKit
import Observation

/// 측정 마법사 상태 관리: 정면 사진 → 측면 사진 → 키 입력 → 분석
@MainActor
@Observable
final class MeasurementViewModel {

    /// 마법사 진행 단계
    enum Step: Int {
        case front = 1     // 정면 사진
        case side = 2      // 측면 사진
        case height = 3    // 키 입력
        case analyzing = 4 // 분석 중
        case done = 5      // 결과 도착 (Plan 2c에서 처리)
    }

    private(set) var step: Step = .front

    /// 사용자가 선택한 사진
    var frontImage: UIImage?
    var sideImage: UIImage?

    /// 키 (cm) — 저장된 값이 있으면 자동 채움
    var heightCm: String = ""

    /// 분석 결과 (성공 시)
    private(set) var report: SessionReport?

    /// 에러 메시지 (분석 실패 시)
    var errorMessage: String?

    /// 분석 중 진행 단계 표시용 (관절 인식 → 자세 분석)
    private(set) var analyzingPhase: String = "관절 인식 중…"

    private let analyzeUseCase: AnalyzeSessionUseCase
    private let userProfileRepository: UserProfileRepository

    init(analyzeUseCase: AnalyzeSessionUseCase, userProfileRepository: UserProfileRepository) {
        self.analyzeUseCase = analyzeUseCase
        self.userProfileRepository = userProfileRepository
        // 저장된 키 있으면 자동 채움
        if let saved = try? userProfileRepository.getHeightCm() {
            heightCm = String(format: "%.0f", saved)
        }
    }

    // MARK: - Step 전환

    func setFrontImage(_ image: UIImage) {
        frontImage = image
        step = .side
    }

    func setSideImage(_ image: UIImage) {
        sideImage = image
        // 저장된 키 있으면 height step 건너뛰고 바로 analyzing
        if let _ = try? userProfileRepository.getHeightCm() {
            step = .analyzing
            startAnalysis()
        } else {
            step = .height
        }
    }

    func submitHeight() {
        // 키 입력은 옵션. 입력했으면 저장.
        if let value = parsedHeight {
            try? userProfileRepository.updateHeightCm(value)
        }
        step = .analyzing
        startAnalysis()
    }

    func skipHeight() {
        // 옵션 — 키 미입력 진행
        step = .analyzing
        startAnalysis()
    }

    func retryFromBeginning() {
        frontImage = nil
        sideImage = nil
        errorMessage = nil
        report = nil
        step = .front
    }

    // MARK: - 분석 실행

    func startAnalysis() {
        guard let front = frontImage, let side = sideImage else {
            errorMessage = "사진이 누락되었습니다."
            return
        }
        let heightForAnalysis: Double? = parsedHeight

        Task {
            analyzingPhase = "관절 인식 중…"
            do {
                let result = try await analyzeUseCase.analyze(
                    front: front, side: side, heightCm: heightForAnalysis
                )
                analyzingPhase = "자세 분석 중…"
                // 짧은 시각 단계 표시
                try? await Task.sleep(nanoseconds: 300_000_000)
                self.report = result
                self.step = .done
            } catch let error as PoseDetectionError {
                self.errorMessage = error.errorDescription ?? "분석 실패"
                // step은 .height 유지 (alert 닫고 키 입력 화면). retryFromBeginning은 alert "다시 측정" 액션에서.
                self.step = .height
            } catch {
                self.errorMessage = "예상치 못한 오류: \(error.localizedDescription)"
                self.step = .height
            }
        }
    }

    // MARK: - Helpers

    /// 키 입력값 파싱 (유효 범위 50~250cm)
    var parsedHeight: Double? {
        guard let v = Double(heightCm), (50.0...250.0).contains(v) else { return nil }
        return v
    }

    /// 키 입력값 유효성
    var isHeightValid: Bool { parsedHeight != nil }
}
