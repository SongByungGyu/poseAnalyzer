import SwiftUI
import Charts

/// 추이 그래프 — 자세별 시간축 (Swift Charts)
struct TrendView: View {

    @Environment(\.dependencies) private var dependencies
    @State private var selectedType: PostureType = .forwardHead
    @State private var range: Range = .last30Days
    @State private var sessions: [SessionRecord] = []

    enum Range: String, CaseIterable, Identifiable {
        case last7Days, last30Days, all
        var id: String { rawValue }
        var label: String {
            switch self {
            case .last7Days: return "7일"
            case .last30Days: return "30일"
            case .all: return "전체"
            }
        }
        var days: Int? {
            switch self {
            case .last7Days: return 7
            case .last30Days: return 30
            case .all: return nil
            }
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.s4) {
                typePicker
                rangePicker
                chart
                if dataPoints.count <= 1 {
                    AppCard {
                        Text("비교를 위해 측정을 더 진행해주세요")
                            .font(.appCaption)
                            .foregroundStyle(Color.fg3)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
            .padding(.horizontal, AppSpacing.s4)
            .padding(.bottom, AppSpacing.s10)
        }
        .background(Color.bgCanvas)
        .navigationTitle("추이")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            do {
                sessions = try dependencies.sessionRepository.fetchAll()
            } catch {
                sessions = []
            }
        }
    }

    private var typePicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.s2) {
                ForEach(PostureType.allCases, id: \.self) { t in
                    let selected = (t == selectedType)
                    Button(t.koreanName) { selectedType = t }
                        .font(.appCaption.bold())
                        .foregroundStyle(selected ? Color.white : Color.fg2)
                        .padding(.horizontal, AppSpacing.s3)
                        .padding(.vertical, AppSpacing.s2)
                        .background(
                            selected ? Color.brandPrimary : Color.bgSurface,
                            in: Capsule()
                        )
                        .overlay(Capsule().strokeBorder(Color.border1, lineWidth: selected ? 0 : 1))
                }
            }
            .padding(.horizontal, 1)
        }
    }

    private var rangePicker: some View {
        Picker("기간", selection: $range) {
            ForEach(Range.allCases) { r in
                Text(r.label).tag(r)
            }
        }
        .pickerStyle(.segmented)
    }

    private var dataPoints: [TrendPoint] {
        let cutoff: Date? = range.days.flatMap { Calendar.current.date(byAdding: .day, value: -$0, to: .now) }
        return sessions
            .filter { cutoff == nil || $0.measuredAt >= cutoff! }
            .compactMap { session -> TrendPoint? in
                guard let rec = session.postures.first(where: { $0.type == selectedType }),
                      rec.status != .unmeasurable else { return nil }
                return TrendPoint(date: session.measuredAt, value: rec.primaryMetric, status: rec.status)
            }
            .sorted { $0.date < $1.date }
    }

    @ViewBuilder
    private var chart: some View {
        if dataPoints.isEmpty {
            AppCard {
                AppEmptyState(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "표시할 데이터가 없습니다",
                    message: "선택한 기간에 \(selectedType.koreanName) 측정 결과가 없습니다."
                )
            }
        } else {
            Chart(dataPoints) { p in
                LineMark(
                    x: .value("날짜", p.date),
                    y: .value("값", p.value)
                )
                .foregroundStyle(Color.brandPrimary)
                .interpolationMethod(.monotone)

                PointMark(
                    x: .value("날짜", p.date),
                    y: .value("값", p.value)
                )
                .foregroundStyle(p.status.color)
                .symbolSize(80)
            }
            .frame(height: 240)
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 4)) { value in
                    AxisGridLine().foregroundStyle(Color.border2)
                    AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                        .foregroundStyle(Color.fg3)
                }
            }
            .chartYAxis {
                AxisMarks { _ in
                    AxisGridLine().foregroundStyle(Color.border2)
                    AxisValueLabel()
                        .foregroundStyle(Color.fg3)
                }
            }
            .padding(.vertical, AppSpacing.s2)
        }
    }
}

private struct TrendPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
    let status: PostureStatus
}
