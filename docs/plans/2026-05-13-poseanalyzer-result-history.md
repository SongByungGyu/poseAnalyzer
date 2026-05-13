# PoseAnalyzer Result & History 구현 계획 (Plan 2c/2d)

> **For agentic workers:** REQUIRED SUB-SKILL: superpowers:subagent-driven-development. Steps use checkbox (`- [ ]`) syntax.

**Goal:** 분석 결과 화면(관절 오버레이 + 8 자세 카드 + 비대칭 + 직전 비교) + 기록 리스트 + 추이 그래프(Swift Charts) + 설정 화면(키 변경). Plan 2b의 ResultPlaceholderView를 실제 AnalysisResultView로 교체. 측정한 세션이 저장되고, 기록 탭에서 시간 역순으로 열람 가능.

**Architecture:** MVVM 유지. 관절 오버레이는 SwiftUI Canvas 기반 (Vision 좌표 → SwiftUI 좌표 변환 포함, Vision은 좌하단 원점이므로 Y 뒤집기). 추이 그래프는 iOS 17+ Swift Charts. 설정은 Form 기반 단순.

**Tech Stack:** SwiftUI, Charts(iOS 17+), SwiftData @Query. 외부 라이브러리 0개.

**선행 문서:**
- Plan 2a 완료 (tag: `plan-2a-ui-foundation-complete`)
- Plan 2b 완료 (tag: `plan-2b-measurement-flow-complete`)

**완료 후 상태:**
- 측정 → AnalysisResultView (관절 오버레이 + 카드 + 비대칭 + 직전 비교) → 저장 → 기록 탭에 표시
- 기록 탭 → 시간 역순 카드 리스트 → 항목 탭 → 결과 상세 (읽기 전용)
- 기록 탭 상단 "추이" → TrendView (Swift Charts, 자세별 시간축)
- 홈 ⚙️ 또는 결과 화면에서 키 변경 가능
- Plan 1 단위테스트 66/66 그대로 통과

---

## 사전 정보

- 작업 디렉토리: `/Users/byunggyusong/1_개발폴더/마스터프로젝트/PoseAnalyzer`
- 시뮬레이터 UDID: `BF407CD0-C970-45EF-91FD-7FEB05483871`
- Xcode 16+ synchronized folders
- Vision 좌표계: **좌하단 (0,0)**, SwiftUI 좌표계: **좌상단 (0,0)** — Y 뒤집기 필수
- 한국어 코멘트, custom Color/Font는 항상 `Color.xxx`/`Font.xxx` 명시

---

## Phase 1: 관절 오버레이

### Task 1: PoseOverlayView (Canvas 기반 관절 시각화)

**파일/경로:**
- 생성: `PoseAnalyzer/Presentation/Result/PoseOverlayView.swift`

- [ ] **Step 1: PoseOverlayView.swift 작성**

```swift
import SwiftUI
import Vision

/// PoseFrame 좌표를 사진 위에 점·선으로 오버레이
/// Vision은 좌하단 원점이라 Y를 뒤집어 SwiftUI 좌상단 원점으로 변환
struct PoseOverlayView: View {
    
    let image: UIImage
    let frame: PoseFrame
    var nodeColor: Color = .brandPrimary
    var lineColor: Color = .brandMint
    var lineWidth: CGFloat = 2
    var nodeRadius: CGFloat = 4
    var lowConfidenceOpacity: Double = 0.3
    
    /// 시각화할 골격 라인 (관절 짝)
    private let bones: [(VNHumanBodyPoseObservation.JointName, VNHumanBodyPoseObservation.JointName)] = [
        (.nose, .neck),
        (.neck, .leftShoulder), (.neck, .rightShoulder),
        (.leftShoulder, .leftElbow), (.leftElbow, .leftWrist),
        (.rightShoulder, .rightElbow), (.rightElbow, .rightWrist),
        (.leftShoulder, .leftHip), (.rightShoulder, .rightHip),
        (.leftHip, .rightHip),
        (.leftHip, .leftKnee), (.leftKnee, .leftAnkle),
        (.rightHip, .rightKnee), (.rightKnee, .rightAnkle),
    ]
    
    var body: some View {
        GeometryReader { proxy in
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .overlay(
                    Canvas { ctx, size in
                        // 1) 본 연결선
                        for (a, b) in bones {
                            guard let pa = frame.joints[a], let pb = frame.joints[b] else { continue }
                            let minConf = min(pa.confidence, pb.confidence)
                            let opacity = minConf < 0.3 ? lowConfidenceOpacity : 1.0
                            let p1 = swiftUIPoint(pa.location, in: size)
                            let p2 = swiftUIPoint(pb.location, in: size)
                            var path = Path()
                            path.move(to: p1)
                            path.addLine(to: p2)
                            ctx.stroke(
                                path,
                                with: .color(lineColor.opacity(opacity)),
                                style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                            )
                        }
                        // 2) 관절 노드
                        for (_, joint) in frame.joints {
                            let opacity = joint.confidence < 0.3 ? lowConfidenceOpacity : 1.0
                            let center = swiftUIPoint(joint.location, in: size)
                            let rect = CGRect(
                                x: center.x - nodeRadius,
                                y: center.y - nodeRadius,
                                width: nodeRadius * 2,
                                height: nodeRadius * 2
                            )
                            ctx.fill(Path(ellipseIn: rect), with: .color(nodeColor.opacity(opacity)))
                            ctx.stroke(
                                Path(ellipseIn: rect),
                                with: .color(Color.white.opacity(opacity)),
                                lineWidth: 1
                            )
                        }
                    }
                )
        }
    }
    
    /// Vision 정규화 좌표(좌하단) → SwiftUI 픽셀 좌표(좌상단)
    private func swiftUIPoint(_ p: CGPoint, in size: CGSize) -> CGPoint {
        CGPoint(x: p.x * size.width, y: (1 - p.y) * size.height)
    }
}

#Preview {
    // Preview는 실제 사진/PoseFrame이 필요해 sample 생략
    Text("PoseOverlayView preview — 실제 측정 후 결과 화면에서 확인")
        .padding()
}
```

- [ ] **Step 2: 빌드 + commit**

```bash
cd "/Users/byunggyusong/1_개발폴더/마스터프로젝트/PoseAnalyzer/PoseAnalyzer"
xcodebuild build -project PoseAnalyzer.xcodeproj -scheme PoseAnalyzer \
  -destination 'platform=iOS Simulator,id=BF407CD0-C970-45EF-91FD-7FEB05483871' \
  2>&1 | tail -10
```

```bash
cd "/Users/byunggyusong/1_개발폴더/마스터프로젝트/PoseAnalyzer"
git add PoseAnalyzer/PoseAnalyzer/Presentation/Result/PoseOverlayView.swift
git commit -m "feat(result): add PoseOverlayView (Canvas 기반 관절 오버레이)

Plan 2c Task 1: 사진 위 관절 시각화

- Canvas로 본 라인 + 관절 노드 그림
- Vision 좌하단 → SwiftUI 좌상단 Y 뒤집기
- confidence < 0.3 은 30% opacity (디자인 시스템 규칙)
- 14개 본 (코-목, 어깨/팔꿈치/손목, 엉덩이/무릎/발목)"
```

---

### Task 2: PostureResultCard (개별 자세 결과 카드)

**파일/경로:**
- 생성: `PoseAnalyzer/Presentation/Result/PostureResultCard.swift`

- [ ] **Step 1: PostureResultCard.swift 작성**

```swift
import SwiftUI

/// 개별 자세 결과 카드 — 좌측 status indicator strip + 자세명 + 배지 + 핵심 수치 + 게이지
struct PostureResultCard: View {
    
    let result: PostureResult
    
    var body: some View {
        ZStack(alignment: .leading) {
            // 좌측 status indicator strip
            Rectangle()
                .fill(result.status.color)
                .frame(width: 4)
                .frame(maxHeight: .infinity)
                .padding(.vertical, AppSpacing.s3)
            
            VStack(alignment: .leading, spacing: AppSpacing.s2) {
                header
                metric
                if result.status != .unmeasurable {
                    gauge
                }
                if let advice = result.advice {
                    Text(advice)
                        .font(.appCaption)
                        .foregroundStyle(Color.fg2)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.leading, AppSpacing.s4)
            .padding(.trailing, AppSpacing.s4)
            .padding(.vertical, AppSpacing.s3)
        }
        .background(Color.bgSurface, in: RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.lg, style: .continuous)
                .strokeBorder(Color.border1, lineWidth: 1)
        )
        .appCardShadow()
    }
    
    // MARK: - Pieces
    
    private var header: some View {
        HStack {
            Text(result.type.koreanName)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(Color.fg1)
            Spacer()
            StatusBadge(status: result.status, tone: .soft, size: .small)
        }
    }
    
    private var metric: some View {
        HStack(alignment: .firstTextBaseline, spacing: 3) {
            if result.status == .unmeasurable {
                Text("—")
                    .font(.system(size: 26, weight: .bold).monospacedDigit())
                    .foregroundStyle(Color.fg3)
            } else {
                Text(formattedMetric)
                    .font(.system(size: 26, weight: .bold).monospacedDigit())
                    .foregroundStyle(Color.fg1)
                Text(result.primaryMetricUnit.symbol)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.fg3)
            }
        }
    }
    
    private var formattedMetric: String {
        let v = result.primaryMetric
        let isAngle = result.primaryMetricUnit == .degree
        return isAngle
            ? String(format: "%.0f", v)
            : String(format: "%.2f", v)
    }
    
    private var gauge: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                // 배경 (정상/주의/의심 세 영역 그라데이션)
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.statusNormal,
                                Color.statusCaution,
                                Color.statusSuspect,
                            ],
                            startPoint: .leading, endPoint: .trailing
                        ).opacity(0.22)
                    )
                
                // 마커
                let markerX = markerPosition(width: proxy.size.width)
                Rectangle()
                    .fill(Color.brandInk)
                    .frame(width: 3, height: 10)
                    .offset(x: markerX - 1.5, y: -3)
            }
        }
        .frame(height: 4)
        .clipShape(Capsule())
    }
    
    /// 마커 위치 (정상=18%, 주의=52%, 의심=84%, 측정불가=50%) — 디자인 시스템 기준
    private func markerPosition(width: CGFloat) -> CGFloat {
        switch result.status {
        case .normal: return width * 0.18
        case .caution: return width * 0.52
        case .suspect: return width * 0.84
        case .unmeasurable: return width * 0.50
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        PostureResultCard(result: .init(
            type: .forwardHead, status: .normal,
            primaryMetric: 172, primaryMetricUnit: .degree,
            thresholds: Thresholds(normalRange: 170...360, cautionRange: 160...170, direction: .higherIsNormal),
            usedJointNames: [], confidence: 0.9,
            advice: nil
        ))
        PostureResultCard(result: .init(
            type: .roundShoulder, status: .caution,
            primaryMetric: 0.21, primaryMetricUnit: .ratio,
            thresholds: Thresholds(normalRange: 0...0.15, cautionRange: 0.15...0.25, direction: .lowerIsNormal),
            usedJointNames: [], confidence: 0.85,
            advice: "어깨를 뒤로 펴는 스트레칭을 정기적으로 해주세요."
        ))
        PostureResultCard(result: .unmeasurable(type: .scoliosis, reason: "양 어깨 관절 신뢰도 부족"))
    }
    .padding()
    .background(Color.bgCanvas)
}
```

- [ ] **Step 2: 빌드 + commit**

```bash
cd "/Users/byunggyusong/1_개발폴더/마스터프로젝트/PoseAnalyzer/PoseAnalyzer"
xcodebuild build -project PoseAnalyzer.xcodeproj -scheme PoseAnalyzer \
  -destination 'platform=iOS Simulator,id=BF407CD0-C970-45EF-91FD-7FEB05483871' \
  2>&1 | tail -10
```

```bash
cd "/Users/byunggyusong/1_개발폴더/마스터프로젝트/PoseAnalyzer"
git add PoseAnalyzer/PoseAnalyzer/Presentation/Result/PostureResultCard.swift
git commit -m "feat(result): add PostureResultCard (자세별 결과 카드)

Plan 2c Task 2: 8개 자세 카드 컴포넌트

- 좌측 4px status indicator strip (디자인 시스템 규칙)
- 자세명 + StatusBadge + 핵심 수치 + 게이지(정상/주의/의심 그라데이션)
- advice 멘트 옵션 표시
- unmeasurable은 '—'로 표시"
```

---

## Phase 2: AnalysisResultViewModel + AnalysisResultView

### Task 3: AnalysisResultViewModel (직전 비교 + 저장)

**파일/경로:**
- 생성: `PoseAnalyzer/Presentation/Result/AnalysisResultViewModel.swift`

- [ ] **Step 1: AnalysisResultViewModel.swift 작성**

```swift
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
            // 저장 전 시점: 가장 최근 세션 (이번 측정은 아직 저장 X)
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
```

- [ ] **Step 2: 빌드 + commit**

```bash
cd "/Users/byunggyusong/1_개발폴더/마스터프로젝트/PoseAnalyzer/PoseAnalyzer"
xcodebuild build -project PoseAnalyzer.xcodeproj -scheme PoseAnalyzer \
  -destination 'platform=iOS Simulator,id=BF407CD0-C970-45EF-91FD-7FEB05483871' \
  2>&1 | tail -5
```

```bash
cd "/Users/byunggyusong/1_개발폴더/마스터프로젝트/PoseAnalyzer"
git add PoseAnalyzer/PoseAnalyzer/Presentation/Result/AnalysisResultViewModel.swift
git commit -m "feat(result): add AnalysisResultViewModel (직전 비교 + 저장)

Plan 2c Task 3: 결과 화면 상태 관리

- previousSession 로드 (fetchLatest beforeID)
- save: SessionReport → SwiftData
- delta(for:): 직전 측정 대비 수치 변화 (둘 다 측정 가능시)
- isSaving / isSaved / errorMessage 상태"
```

---

### Task 4: AnalysisResultView (사진 + 8 카드 + 비대칭 + 직전 비교)

**파일/경로:**
- 생성: `PoseAnalyzer/Presentation/Result/AnalysisResultView.swift`

- [ ] **Step 1: AnalysisResultView.swift 작성**

```swift
import SwiftUI

/// 분석 결과 화면 — 사진 + 관절 오버레이 + 8 자세 카드 + 비대칭 + 직전 비교
struct AnalysisResultView: View {
    
    let report: SessionReport
    var isReadOnly: Bool = false  // 기록 탭에서 진입 시 true
    
    @Environment(\.dependencies) private var dependencies
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: AnalysisResultViewModel?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.s5) {
                photosSection
                if let vm = viewModel {
                    posturesSection(vm)
                    asymmetrySection
                    if !isReadOnly { previousComparisonSection(vm) }
                }
            }
            .padding(.horizontal, AppSpacing.s4)
            .padding(.bottom, AppSpacing.s10)
        }
        .background(Color.bgCanvas)
        .navigationTitle("분석 결과")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !isReadOnly, let vm = viewModel, !vm.isSaved {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { vm.save() }) {
                        if vm.isSaving {
                            ProgressView()
                        } else {
                            Text("저장")
                                .font(.appCaption.bold())
                                .foregroundStyle(Color.brandPrimary)
                        }
                    }
                    .disabled(vm.isSaving)
                }
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = AnalysisResultViewModel(
                    report: report,
                    sessionRepository: dependencies.sessionRepository
                )
            }
        }
        .alert("저장 실패", isPresented: Binding(
            get: { viewModel?.errorMessage != nil },
            set: { if !$0 { viewModel?.errorMessage = nil } }
        )) {
            Button("확인", role: .cancel) {}
        } message: {
            Text(viewModel?.errorMessage ?? "")
        }
    }
    
    // MARK: - Sections
    
    private var photosSection: some View {
        HStack(spacing: AppSpacing.s2) {
            photoCard(image: report.frontImage, frame: report.frontFrame, label: "정면")
            photoCard(image: report.sideImage, frame: report.sideFrame, label: "측면")
        }
        .padding(.top, AppSpacing.s2)
    }
    
    private func photoCard(image: UIImage, frame: PoseFrame, label: String) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.s1) {
            Text(label)
                .font(.appMicro)
                .foregroundStyle(Color.fg3)
                .textCase(.uppercase)
            PoseOverlayView(image: image, frame: frame)
                .aspectRatio(3/4, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.md, style: .continuous)
                        .strokeBorder(Color.border1, lineWidth: 1)
                )
        }
    }
    
    private func posturesSection(_ vm: AnalysisResultViewModel) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.s2) {
            SectionHeader("자세 판정 (8가지)")
            VStack(spacing: AppSpacing.s2) {
                ForEach(report.postures.indices, id: \.self) { i in
                    PostureResultCard(result: report.postures[i])
                }
            }
        }
    }
    
    private var asymmetrySection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.s2) {
            SectionHeader("좌우 비대칭")
            AppCard {
                VStack(alignment: .leading, spacing: AppSpacing.s2) {
                    asymmetryRow(label: "어깨", diff: report.asymmetry.shoulder)
                    Divider()
                    asymmetryRow(label: "골반", diff: report.asymmetry.hip)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    private func asymmetryRow(label: String, diff: AsymmetryResult.Difference) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label)
                .font(.appBody)
                .foregroundStyle(Color.fg2)
                .frame(width: 40, alignment: .leading)
            Text(diff.direction.koreanName)
                .font(.appBody.bold())
                .foregroundStyle(diff.direction == .balanced ? Color.statusNormal : Color.statusCaution)
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                if let cm = diff.cm {
                    Text("\(String(format: "%.1f", cm))cm 차이")
                        .font(.appCaption.monospacedDigit())
                        .foregroundStyle(Color.fg1)
                }
                Text("기울기 \(String(format: "%.1f", diff.angleDegrees))°")
                    .font(.appMicro.monospacedDigit())
                    .foregroundStyle(Color.fg3)
            }
        }
    }
    
    @ViewBuilder
    private func previousComparisonSection(_ vm: AnalysisResultViewModel) -> some View {
        if vm.previousSession != nil {
            VStack(alignment: .leading, spacing: AppSpacing.s2) {
                SectionHeader("직전 측정 대비")
                AppCard {
                    VStack(alignment: .leading, spacing: AppSpacing.s2) {
                        ForEach(report.postures.indices, id: \.self) { i in
                            let type = report.postures[i].type
                            if let d = vm.delta(for: type) {
                                comparisonRow(type: type, delta: d, unit: report.postures[i].primaryMetricUnit)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
    
    private func comparisonRow(type: PostureType, delta: Double, unit: PostureResult.MetricUnit) -> some View {
        let isImproved = abs(delta) < 0.5
        let symbol = delta > 0.05 ? "arrow.up.right" : delta < -0.05 ? "arrow.down.right" : "arrow.right"
        let color = isImproved ? Color.fg3 : (delta > 0 ? Color.statusCaution : Color.statusNormal)
        return HStack {
            Text(type.koreanName)
                .font(.appCallout)
                .foregroundStyle(Color.fg1)
            Spacer()
            Image(systemName: symbol)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(color)
            Text("\(delta > 0 ? "+" : "")\(String(format: "%.1f", delta))\(unit.symbol)")
                .font(.appCaption.bold().monospacedDigit())
                .foregroundStyle(color)
        }
    }
}
```

- [ ] **Step 2: 빌드 + commit**

```bash
cd "/Users/byunggyusong/1_개발폴더/마스터프로젝트/PoseAnalyzer/PoseAnalyzer"
xcodebuild build -project PoseAnalyzer.xcodeproj -scheme PoseAnalyzer \
  -destination 'platform=iOS Simulator,id=BF407CD0-C970-45EF-91FD-7FEB05483871' \
  2>&1 | tail -10
```

```bash
cd "/Users/byunggyusong/1_개발폴더/마스터프로젝트/PoseAnalyzer"
git add PoseAnalyzer/PoseAnalyzer/Presentation/Result/AnalysisResultView.swift
git commit -m "feat(result): add AnalysisResultView (사진+오버레이+8카드+비대칭+직전비교)

Plan 2c Task 4: 분석 결과 화면

- 정면/측면 사진 나란히 + 관절 오버레이
- 8개 자세 카드 (PostureResultCard)
- 좌우 비대칭 (어깨/골반) + cm/각도 표시
- 직전 측정 대비 변화 (delta with arrow indicator)
- 저장 버튼 (toolbar) - 읽기 전용 모드에서는 숨김"
```

---

### Task 5: Plan 2b의 ResultPlaceholderView → AnalysisResultView 교체

**파일/경로:**
- 수정: `PoseAnalyzer/Presentation/Home/HomeView.swift`
- 삭제: `PoseAnalyzer/Presentation/Result/ResultPlaceholderView.swift`

- [ ] **Step 1: HomeView.swift 수정**

`navigationDestination` 안의 `ResultPlaceholderView(report: report)` → `AnalysisResultView(report: report)` 로 변경.

- [ ] **Step 2: ResultPlaceholderView.swift 삭제**

```bash
rm "/Users/byunggyusong/1_개발폴더/마스터프로젝트/PoseAnalyzer/PoseAnalyzer/PoseAnalyzer/Presentation/Result/ResultPlaceholderView.swift"
```

- [ ] **Step 3: 빌드 + commit**

```bash
cd "/Users/byunggyusong/1_개발폴더/마스터프로젝트/PoseAnalyzer/PoseAnalyzer"
xcodebuild build -project PoseAnalyzer.xcodeproj -scheme PoseAnalyzer \
  -destination 'platform=iOS Simulator,id=BF407CD0-C970-45EF-91FD-7FEB05483871' \
  2>&1 | tail -5
```

```bash
cd "/Users/byunggyusong/1_개발폴더/마스터프로젝트/PoseAnalyzer"
git add PoseAnalyzer/PoseAnalyzer/Presentation/Home/HomeView.swift
git add -u PoseAnalyzer/PoseAnalyzer/Presentation/Result/ResultPlaceholderView.swift 2>/dev/null || true
git commit -m "feat(result): replace ResultPlaceholderView with AnalysisResultView in HomeView

Plan 2c Task 5: HomeView 라우팅 교체

- navigationDestination → AnalysisResultView
- ResultPlaceholderView 제거"
```

---

## Phase 3: 기록 + 추이

### Task 6: HistoryViewModel + HistoryListView

**파일/경로:**
- 생성: `PoseAnalyzer/Presentation/History/HistoryViewModel.swift`
- 생성: `PoseAnalyzer/Presentation/History/HistoryListView.swift`

- [ ] **Step 1: HistoryViewModel.swift 작성**

```swift
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
```

- [ ] **Step 2: HistoryListView.swift 작성**

```swift
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
/// (Plan 1에서는 테스트 헬퍼에만 있었음)
extension PoseFrame {
    static func empty(view: SessionView, imageSize: CGSize) -> PoseFrame {
        PoseFrame(joints: [:], view: view, imageSize: imageSize)
    }
}
```

- [ ] **Step 3: 빌드 + commit**

```bash
cd "/Users/byunggyusong/1_개발폴더/마스터프로젝트/PoseAnalyzer/PoseAnalyzer"
xcodebuild build -project PoseAnalyzer.xcodeproj -scheme PoseAnalyzer \
  -destination 'platform=iOS Simulator,id=BF407CD0-C970-45EF-91FD-7FEB05483871' \
  2>&1 | tail -15
```

```bash
cd "/Users/byunggyusong/1_개발폴더/마스터프로젝트/PoseAnalyzer"
git add PoseAnalyzer/PoseAnalyzer/Presentation/History/
git commit -m "feat(history): add HistoryListView + HistoryViewModel + AnalysisResultDetailView

Plan 2c Task 6: 기록 탭

- 시간 역순 세션 카드 리스트 (SwiftData @Query 대신 ViewModel refresh)
- 카드 = 측정 시각 + 8 자세 dot (status color)
- 스와이프 삭제 + alert 확인
- 상단 우측 '추이' 버튼 → TrendView (Task 8)
- 항목 탭 → AnalysisResultDetailView (SessionRecord → SessionReport 변환, isReadOnly)
- 사진 파일 누락 시 empty state"
```

---

### Task 7: AppTabView의 HistoryTabPlaceholder → HistoryListView 교체

**파일/경로:**
- 수정: `PoseAnalyzer/Presentation/AppTabView.swift`

- [ ] **Step 1: AppTabView.swift 수정**

`HistoryTabPlaceholder()` 호출을 `NavigationStack { HistoryListView() }` 로 변경. `HistoryTabPlaceholder` struct는 삭제.

- [ ] **Step 2: 빌드 + commit**

```bash
cd "/Users/byunggyusong/1_개발폴더/마스터프로젝트/PoseAnalyzer/PoseAnalyzer"
xcodebuild build -project PoseAnalyzer.xcodeproj -scheme PoseAnalyzer \
  -destination 'platform=iOS Simulator,id=BF407CD0-C970-45EF-91FD-7FEB05483871' \
  2>&1 | tail -5
```

```bash
cd "/Users/byunggyusong/1_개발폴더/마스터프로젝트/PoseAnalyzer"
git add PoseAnalyzer/PoseAnalyzer/Presentation/AppTabView.swift
git commit -m "feat(history): replace HistoryTabPlaceholder with HistoryListView

Plan 2c Task 7: 기록 탭 라우팅"
```

---

### Task 8: TrendView (Swift Charts)

**파일/경로:**
- 생성: `PoseAnalyzer/Presentation/History/TrendView.swift`

- [ ] **Step 1: TrendView.swift 작성**

```swift
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
```

- [ ] **Step 2: 빌드 + commit**

```bash
cd "/Users/byunggyusong/1_개발폴더/마스터프로젝트/PoseAnalyzer/PoseAnalyzer"
xcodebuild build -project PoseAnalyzer.xcodeproj -scheme PoseAnalyzer \
  -destination 'platform=iOS Simulator,id=BF407CD0-C970-45EF-91FD-7FEB05483871' \
  2>&1 | tail -10
```

```bash
cd "/Users/byunggyusong/1_개발폴더/마스터프로젝트/PoseAnalyzer"
git add PoseAnalyzer/PoseAnalyzer/Presentation/History/TrendView.swift
git commit -m "feat(history): add TrendView (Swift Charts 추이 그래프)

Plan 2c Task 8: 자세별 시간축 추이

- 자세 종류 horizontal picker (8개)
- 기간 segmented picker (7일/30일/전체)
- LineMark + PointMark (status color)
- 데이터 0개: empty state, 1개: '측정을 더 진행해주세요' 안내"
```

---

## Phase 4: 설정 화면

### Task 9: SettingsView (키 변경)

**파일/경로:**
- 생성: `PoseAnalyzer/Presentation/Settings/SettingsView.swift`

- [ ] **Step 1: SettingsView.swift 작성**

```swift
import SwiftUI

/// 설정 화면 — 키 변경 + (향후) 임계값 튜닝 등
struct SettingsView: View {
    
    @Environment(\.dependencies) private var dependencies
    @Environment(\.dismiss) private var dismiss
    @State private var heightCm: String = ""
    @State private var saveSuccess: Bool = false
    
    var body: some View {
        Form {
            Section("프로필") {
                HStack {
                    Text("키 (cm)")
                        .font(.appBody)
                        .foregroundStyle(Color.fg1)
                    Spacer()
                    TextField("미입력", text: $heightCm)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.numberPad)
                        .font(.appBody.monospacedDigit())
                }
            }
            Section {
                Button("저장") { save() }
                    .disabled(!isValid)
            }
            Section {
                Text("키는 사진 속 신장 픽셀과 비교하여 어깨/골반 비대칭을 cm 단위로 환산하는 데 사용됩니다. 입력하지 않으면 어깨너비 비율로 표시됩니다.")
                    .font(.appCaption)
                    .foregroundStyle(Color.fg3)
            }
        }
        .navigationTitle("설정")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let saved = try? dependencies.userProfileRepository.getHeightCm() {
                heightCm = String(format: "%.0f", saved)
            }
        }
        .alert("저장 완료", isPresented: $saveSuccess) {
            Button("확인", role: .cancel) { dismiss() }
        }
    }
    
    private var isValid: Bool {
        if heightCm.isEmpty { return true }  // 빈 값(미입력)도 valid (저장 시 nil)
        guard let v = Double(heightCm) else { return false }
        return (50.0...250.0).contains(v)
    }
    
    private func save() {
        let value: Double? = heightCm.isEmpty ? nil : Double(heightCm)
        try? dependencies.userProfileRepository.updateHeightCm(value)
        saveSuccess = true
    }
}
```

- [ ] **Step 2: HomeView에 ⚙️ 진입점 추가 — toolbar 수정**

HomeView의 `.toolbar` 또는 `navigationBar` 영역에 다음 추가:
```swift
.toolbar {
    ToolbarItem(placement: .topBarTrailing) {
        NavigationLink(destination: SettingsView()) {
            Image(systemName: "gearshape")
                .foregroundStyle(Color.brandPrimary)
        }
    }
}
```

(HomeView가 NavigationStack 안에 있도록 AppTabView도 확인 필요 — Plan 2b Task 1에서 이미 NavigationStack 안에 있음)

- [ ] **Step 3: 빌드 + commit**

```bash
cd "/Users/byunggyusong/1_개발폴더/마스터프로젝트/PoseAnalyzer/PoseAnalyzer"
xcodebuild build -project PoseAnalyzer.xcodeproj -scheme PoseAnalyzer \
  -destination 'platform=iOS Simulator,id=BF407CD0-C970-45EF-91FD-7FEB05483871' \
  2>&1 | tail -10
```

```bash
cd "/Users/byunggyusong/1_개발폴더/마스터프로젝트/PoseAnalyzer"
git add PoseAnalyzer/PoseAnalyzer/Presentation/Settings/SettingsView.swift \
        PoseAnalyzer/PoseAnalyzer/Presentation/Home/HomeView.swift
git commit -m "feat(settings): add SettingsView (키 변경) + HomeView 진입점

Plan 2c Task 9: 설정 화면

- Form: 키 (cm) TextField + 저장 버튼
- 50~250cm 유효성 (빈 값도 허용 = 미입력 저장)
- HomeView toolbar 우측 ⚙️ → SettingsView push"
```

---

### Task 10: AppTabView를 NavigationStack 으로 wrap (HomeView 안전)

**파일/경로:**
- 수정: `PoseAnalyzer/Presentation/AppTabView.swift`

- [ ] **Step 1: HomeView를 NavigationStack 안에 래핑**

현재 측정 탭이 `HomeView()` 단독으로 들어가있음. 다음과 같이 변경:
```swift
NavigationStack {
    HomeView()
}
```

(기록 탭도 마찬가지로 NavigationStack 확인)

- [ ] **Step 2: 빌드 + commit**

```bash
cd "/Users/byunggyusong/1_개발폴더/마스터프로젝트/PoseAnalyzer/PoseAnalyzer"
xcodebuild build -project PoseAnalyzer.xcodeproj -scheme PoseAnalyzer \
  -destination 'platform=iOS Simulator,id=BF407CD0-C970-45EF-91FD-7FEB05483871' \
  2>&1 | tail -5
```

```bash
cd "/Users/byunggyusong/1_개발폴더/마스터프로젝트/PoseAnalyzer"
git add PoseAnalyzer/PoseAnalyzer/Presentation/AppTabView.swift
git commit -m "feat(home): wrap HomeView in NavigationStack (toolbar/navigation 정상 작동)

Plan 2c Task 10: 탭별 NavigationStack 보장"
```

---

## Phase 5: 마무리

### Task 11: 시뮬레이터 전체 흐름 + Plan 1 회귀 + tag

- [ ] **Step 1: 전체 테스트 실행 (Plan 1 회귀)**

```bash
cd "/Users/byunggyusong/1_개발폴더/마스터프로젝트/PoseAnalyzer/PoseAnalyzer"
xcodebuild test -project PoseAnalyzer.xcodeproj -scheme PoseAnalyzer \
  -destination 'platform=iOS Simulator,id=BF407CD0-C970-45EF-91FD-7FEB05483871' \
  2>&1 | tail -20
```

Expected: 66개 모두 통과.

- [ ] **Step 2: Plan 2c tag**

```bash
cd "/Users/byunggyusong/1_개발폴더/마스터프로젝트/PoseAnalyzer"
git tag -a plan-2c-result-history-complete -m "Plan 2c (Result + History) 완료

분석 결과 화면(사진+오버레이+8카드+비대칭+직전비교) + 기록 + 추이 + 설정 구현.
실제 측정 → 저장 → 기록 표시 → 추이 그래프 전체 흐름 동작.

Plan 1 단위테스트 회귀 0. 다음: Plan 2d (Integration & 마무리)."
git log --oneline | head -15
```

---

## ✅ Plan 2c 완료 정의

- [ ] PoseOverlayView (Canvas 기반 관절 시각화)
- [ ] PostureResultCard (좌측 status strip)
- [ ] AnalysisResultViewModel + AnalysisResultView (사진+8카드+비대칭+직전비교)
- [ ] ResultPlaceholderView 제거, HomeView가 AnalysisResultView 사용
- [ ] HistoryViewModel + HistoryListView (시간 역순 + 스와이프 삭제)
- [ ] AppTabView의 History placeholder → HistoryListView 교체
- [ ] TrendView (Swift Charts, 자세별 + 기간 필터)
- [ ] SettingsView (키 변경) + HomeView ⚙️ 진입점
- [ ] AppTabView의 측정/기록 탭 모두 NavigationStack
- [ ] 빌드 SUCCEEDED, Plan 1 단위테스트 66/66 통과
- [ ] `plan-2c-result-history-complete` tag

---

## ⏭ 다음 (Plan 2d)

- 다크모드 verify (전체 화면)
- UI 테스트 3개 정도 (선택, 핵심 흐름만)
- Vision smoke test (사용자 사진 fixture 후)
- 최종 정리 + 1차 MVP 완료 tag
