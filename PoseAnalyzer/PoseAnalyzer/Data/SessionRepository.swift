import Foundation
import SwiftData

/// SessionReport ↔ SwiftData CRUD
@MainActor
final class SessionRepository {

    private let context: ModelContext
    private let imageStore: ImageStore

    init(context: ModelContext, imageStore: ImageStore) {
        self.context = context
        self.imageStore = imageStore
    }

    /// 메모리 SessionReport를 SwiftData + 이미지 파일에 저장
    func save(_ report: SessionReport) throws {
        // 1) 이미지 파일 저장
        let frontPath = try imageStore.save(report.frontImage, for: report.id, view: .front)
        let sidePath = try imageStore.save(report.sideImage, for: report.id, view: .side)

        // 2) SessionRecord 생성
        let record = SessionRecord(
            id: report.id,
            measuredAt: report.measuredAt,
            frontImagePath: frontPath,
            sideImagePath: sidePath,
            heightCmAtMeasure: report.heightCmAtMeasure,
            asymmetryShoulderCm: report.asymmetry.shoulder.cm,
            asymmetryShoulderRatio: report.asymmetry.shoulder.ratio,
            asymmetryShoulderAngle: report.asymmetry.shoulder.angleDegrees,
            asymmetryShoulderDirection: report.asymmetry.shoulder.direction,
            asymmetryHipCm: report.asymmetry.hip.cm,
            asymmetryHipRatio: report.asymmetry.hip.ratio,
            asymmetryHipAngle: report.asymmetry.hip.angleDegrees,
            asymmetryHipDirection: report.asymmetry.hip.direction
        )

        // 3) PostureRecord 8개 추가
        for posture in report.postures {
            let pr = PostureRecord(
                type: posture.type,
                status: posture.status,
                primaryMetric: posture.primaryMetric,
                primaryMetricUnit: posture.primaryMetricUnit,
                confidence: posture.confidence,
                advice: posture.advice
            )
            pr.session = record
            record.postures.append(pr)
        }

        // 4) context에 삽입 + 저장
        context.insert(record)
        try context.save()
    }

    /// 모든 세션을 시간 역순으로 조회
    func fetchAll() throws -> [SessionRecord] {
        let descriptor = FetchDescriptor<SessionRecord>(
            sortBy: [SortDescriptor(\.measuredAt, order: .reverse)]
        )
        return try context.fetch(descriptor)
    }

    /// 특정 세션 조회
    func fetch(id: UUID) throws -> SessionRecord? {
        let descriptor = FetchDescriptor<SessionRecord>(
            predicate: #Predicate { $0.id == id }
        )
        return try context.fetch(descriptor).first
    }

    /// 가장 최근(직전) 세션 1건 조회 (없으면 nil)
    func fetchLatest(beforeID excludingID: UUID? = nil) throws -> SessionRecord? {
        let all = try fetchAll()
        if let excluding = excludingID {
            return all.first { $0.id != excluding }
        }
        return all.first
    }

    /// 세션 삭제 (이미지 파일도 함께)
    func delete(id: UUID) throws {
        guard let record = try fetch(id: id) else { return }
        try imageStore.delete(for: id)
        context.delete(record)
        try context.save()
    }
}
