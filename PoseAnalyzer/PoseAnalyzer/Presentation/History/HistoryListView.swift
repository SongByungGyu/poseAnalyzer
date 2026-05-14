import SwiftUI

/// 기록 탭 — 시간 역순 세션 카드 리스트
struct HistoryListView: View {

    @Environment(\.dependencies) private var dependencies
    @State private var viewModel: HistoryViewModel?
    @State private var sessionForDeletion: SessionRecord?

    var body: some View {
        Group {
            if let vm = viewModel {
                content(vm)
            } else {
                ProgressView()
            }
        }
        .background(Color.bgCanvas)
        .navigationTitle("기록")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(destination: TrendView()) {
                    HStack(spacing: 4) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                        Text("추이")
                    }
                    .font(.appCaption.bold())
                    .foregroundStyle(Color.brandPrimary)
                }
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = HistoryViewModel(sessionRepository: dependencies.sessionRepository)
            }
            viewModel?.refresh()
        }
        .alert("삭제 확인", isPresented: Binding(
            get: { sessionForDeletion != nil },
            set: { if !$0 { sessionForDeletion = nil } }
        )) {
            Button("삭제", role: .destructive) {
                if let s = sessionForDeletion {
                    viewModel?.delete(id: s.id)
                }
                sessionForDeletion = nil
            }
            Button("취소", role: .cancel) { sessionForDeletion = nil }
        } message: {
            Text("이 측정 기록을 삭제하시겠습니까? 사진도 함께 삭제됩니다.")
        }
    }

    @ViewBuilder
    private func content(_ vm: HistoryViewModel) -> some View {
        if vm.sessions.isEmpty {
            AppEmptyState(
                icon: "chart.bar.fill",
                title: "아직 기록이 없습니다",
                message: "측정을 시작하면 여기에 표시됩니다."
            )
        } else {
            List {
                ForEach(vm.sessions, id: \.id) { session in
                    NavigationLink(destination: AnalysisResultDetailView(session: session)) {
                        HistoryRowView(session: session)
                    }
                    .listRowBackground(Color.bgCanvas)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 4, leading: AppSpacing.s4, bottom: 4, trailing: AppSpacing.s4))
                    .swipeActions {
                        Button(role: .destructive) {
                            sessionForDeletion = session
                        } label: {
                            Label("삭제", systemImage: "trash")
                        }
                    }
                }
            }
            .listStyle(.plain)
        }
    }
}

/// 기록 카드 한 줄
private struct HistoryRowView: View {
    let session: SessionRecord

    var body: some View {
        AppCard(style: .nested, padding: AppSpacing.s3) {
            HStack(spacing: AppSpacing.s3) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(session.measuredAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.appCaption.bold())
                        .foregroundStyle(Color.fg1)

                    HStack(spacing: 4) {
                        ForEach(session.postures.sorted { $0.typeRaw < $1.typeRaw }, id: \.id) { p in
                            Circle()
                                .fill(p.status.color)
                                .frame(width: 8, height: 8)
                        }
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.fg3)
            }
        }
    }
}

/// 기록 탭에서 진입하는 상세 — SessionRecord → SessionReport 변환 후 AnalysisResultView 호출
struct AnalysisResultDetailView: View {

    let session: SessionRecord
    @Environment(\.dependencies) private var dependencies

    var body: some View {
        if let report = makeReport() {
            AnalysisResultView(report: report, isReadOnly: true)
        } else {
            AppEmptyState(
                icon: "exclamationmark.triangle",
                title: "기록을 불러올 수 없습니다",
                message: "사진 파일이 누락되었거나 데이터가 손상되었습니다."
            )
            .background(Color.bgCanvas)
        }
    }

    private func makeReport() -> SessionReport? {
        guard let frontImage = dependencies.imageStore.load(path: session.frontImagePath),
              let sideImage = dependencies.imageStore.load(path: session.sideImagePath) else {
            return nil
        }
        let postures = session.postures.map { rec in
            PostureResult(
                type: rec.type,
                status: rec.status,
                primaryMetric: rec.primaryMetric,
                primaryMetricUnit: rec.primaryMetricUnit,
                thresholds: Thresholds(normalRange: 0...0, cautionRange: nil, direction: .higherIsNormal),
                usedJointNames: [],
                confidence: rec.confidence,
                advice: rec.advice
            )
        }
        let asymmetry = AsymmetryResult(
            shoulder: .init(
                cm: session.asymmetryShoulderCm,
                ratio: session.asymmetryShoulderRatio,
                angleDegrees: session.asymmetryShoulderAngle,
                direction: session.asymmetryShoulderDirection
            ),
            hip: .init(
                cm: session.asymmetryHipCm,
                ratio: session.asymmetryHipRatio,
                angleDegrees: session.asymmetryHipAngle,
                direction: session.asymmetryHipDirection
            )
        )
        return SessionReport(
            id: session.id,
            measuredAt: session.measuredAt,
            frontImage: frontImage,
            sideImage: sideImage,
            frontFrame: PoseFrame.empty(view: .front, imageSize: frontImage.size),
            sideFrame: PoseFrame.empty(view: .side, imageSize: sideImage.size),
            postures: postures,
            asymmetry: asymmetry,
            heightCmAtMeasure: session.heightCmAtMeasure
        )
    }
}

/// PoseFrame.empty()는 테스트 fixture에 있지만 main 타겟에서도 사용 — extension을 main에 추가
extension PoseFrame {
    static func empty(view: SessionView, imageSize: CGSize) -> PoseFrame {
        PoseFrame(joints: [:], view: view, imageSize: imageSize)
    }
}
