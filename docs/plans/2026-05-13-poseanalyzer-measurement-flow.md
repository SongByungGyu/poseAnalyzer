# PoseAnalyzer Measurement Flow 구현 계획 (Plan 2b/2d)

> **For agentic workers:** REQUIRED SUB-SKILL: superpowers:subagent-driven-development. Steps use checkbox (`- [ ]`) syntax.

**Goal:** 사용자가 정면·측면 사진 2장 + 키를 입력해서 분석을 시작하기까지의 모든 인터랙션을 구현한다. HomeView, 카메라/사진 라이브러리 접근, 3단계 측정 마법사, Analyzing 화면까지. 분석 결과 화면은 Plan 2c에서 작성하므로 이 plan에서는 Placeholder 도착으로 마무리.

**Architecture:** MVVM. View는 SwiftUI, ViewModel은 `@Observable` 클래스. AppDependencies(Plan 1)의 `analyzeSessionUseCase`, `userProfileRepository`, `sessionRepository`를 주입받아 사용. 카메라는 `UIViewControllerRepresentable`로 `UIImagePickerController` 래핑. 사진 라이브러리는 SwiftUI native `PhotosPicker`.

**Tech Stack:** SwiftUI, AVFoundation(권한), PhotosUI(PhotosPicker), UIKit(UIImagePickerController). 외부 라이브러리 0개.

**선행 문서:**
- Plan 2a 완료 (tag: `plan-2a-ui-foundation-complete`) — 디자인 토큰 + 컴포넌트 6개
- Plan 1 완료 — Domain/Data/UseCase 모두 구현됨

**완료 후 상태:** 시뮬레이터에서 측정 탭 진입 → "측정 시작" CTA → 사진 라이브러리에서 정면 사진 선택 (시뮬레이터는 카메라 없음, 라이브러리만) → 측면 사진 선택 → 키 입력 → Analyzing 화면 → "결과 화면 (Plan 2c)" placeholder. 실제 SessionReport는 메모리에 생성되어 다음 화면으로 전달됨. Plan 1 단위테스트 60개 그대로 통과.

---

## 사전 정보

- 작업 디렉토리: `/Users/byunggyusong/1_개발폴더/마스터프로젝트/PoseAnalyzer`
- 시뮬레이터 UDID: `BF407CD0-C970-45EF-91FD-7FEB05483871`
- Xcode 16+ synchronized folders
- **시뮬레이터는 카메라 미지원** → 시뮬레이터에서는 PhotosPicker만 동작. 실기기에서 카메라 검증.
- SwiftUI 호출 패턴: custom Color/Font 토큰은 항상 `Color.xxx`, `Font.xxx` 명시 (shorthand `.xxx` 사용 금지)
- 한국어 코멘트 (RULES.md)

---

## Phase 1: 진입점과 ViewModel 골격

### Task 1: HomeViewModel + HomeView 기본 골격

**파일/경로:**
- 생성: `PoseAnalyzer/Presentation/Home/HomeView.swift`
- 생성: `PoseAnalyzer/Presentation/Home/HomeViewModel.swift`
- 수정: `PoseAnalyzer/Presentation/AppTabView.swift` (MeasurementTabPlaceholder → HomeView로 교체)

- [ ] **Step 1: HomeViewModel.swift 작성**

```swift
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
            // 조회 실패 시 nil 유지
            latestSession = nil
        }
    }
    
    /// "측정 시작" 액션
    func startMeasurement() {
        isWizardPresented = true
    }
}
```

- [ ] **Step 2: HomeView.swift 작성 (간단 골격)**

```swift
import SwiftUI

/// 홈 화면 — 측정 진입점 + 최근 측정 요약
/// (Plan 2b Task 11에서 8 자세 grid + 상세 최근 측정 추가)
struct HomeView: View {
    
    @Environment(\.dependencies) private var dependencies
    @State private var viewModel: HomeViewModel?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.s5) {
                hero
                if let vm = viewModel, vm.latestSession != nil {
                    recentSection(vm)
                }
            }
            .padding(.horizontal, AppSpacing.s4)
            .padding(.bottom, AppSpacing.s10)
        }
        .background(Color.bgCanvas)
        .navigationTitle("PoseAnalyzer")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if viewModel == nil {
                viewModel = HomeViewModel(sessionRepository: dependencies.sessionRepository)
            }
            viewModel?.refresh()
        }
        .sheet(isPresented: Binding(
            get: { viewModel?.isWizardPresented ?? false },
            set: { viewModel?.isWizardPresented = $0 }
        )) {
            // Plan 2b Task 6에서 MeasurementWizardView로 교체
            Text("측정 마법사 (Task 6 이후)")
                .padding()
                .presentationDetents([.large])
        }
    }
    
    // MARK: - Sections
    
    private var hero: some View {
        VStack(alignment: .leading, spacing: AppSpacing.s4) {
            VStack(alignment: .leading, spacing: AppSpacing.s1) {
                Text("오늘의 자세를\n측정해보세요")
                    .font(.appH1)
                    .foregroundStyle(Color.fg1)
                Text("정면·측면 사진 2장이면 충분합니다.")
                    .font(.appCallout)
                    .foregroundStyle(Color.fg2)
            }
            .padding(.top, AppSpacing.s2)
            
            ctaCard
        }
    }
    
    private var ctaCard: some View {
        Button {
            viewModel?.startMeasurement()
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("3 STEPS · 약 30초")
                        .font(.appMicro)
                        .kerning(0.04)
                        .textCase(.uppercase)
                        .foregroundStyle(Color.white.opacity(0.85))
                    Text("측정 시작")
                        .font(.appH2)
                        .foregroundStyle(Color.white)
                }
                Spacer()
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.18))
                        .frame(width: 52, height: 52)
                    Image(systemName: "camera.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(Color.white)
                }
            }
            .padding(.horizontal, AppSpacing.s5)
            .padding(.vertical, AppSpacing.s4)
            .background(
                LinearGradient(
                    colors: [Color.brandPrimary, Color.brandAccent],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: AppRadius.xl - 6, style: .continuous)
            )
            .appPopShadow()
        }
        .buttonStyle(.plain)
    }
    
    private func recentSection(_ vm: HomeViewModel) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.s2) {
            SectionHeader(title: "최근 측정") {
                NavigationLink(destination: Text("기록 화면 (Plan 2c)")) {
                    Text("전체 보기 ›")
                        .font(.appCaption)
                        .foregroundStyle(Color.brandPrimary)
                }
            }
            if let s = vm.latestSession {
                AppCard {
                    HStack(spacing: AppSpacing.s3) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(s.measuredAt, style: .date)
                                .font(.appCaption.bold())
                                .foregroundStyle(Color.fg1)
                            Text("자세 8가지 분석 완료")
                                .font(.appCaption)
                                .foregroundStyle(Color.fg2)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.fg3)
                    }
                }
            }
        }
    }
}

// MARK: - Environment

private struct DependenciesKey: EnvironmentKey {
    static let defaultValue: AppDependencies = AppDependencies()
}

extension EnvironmentValues {
    var dependencies: AppDependencies {
        get { self[DependenciesKey.self] }
        set { self[DependenciesKey.self] = newValue }
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
}
```

- [ ] **Step 3: AppTabView.swift 수정 (MeasurementTabPlaceholder → HomeView 교체)**

`AppTabView.swift` 안의 `MeasurementTabPlaceholder()` 호출을 `HomeView()` 로 변경하고, 옛 placeholder struct 삭제. 또한 `PoseAnalyzerApp.swift`에서 `AppTabView()`에 `.environment(\.dependencies, dependencies)` 주입 추가:

`PoseAnalyzerApp.swift` 수정:
```swift
WindowGroup {
    AppTabView()
        .environmentObject(dependencies)
        .environment(\.dependencies, dependencies)  // ← 추가
        .modelContainer(dependencies.modelContainer)
}
```

`AppTabView.swift` 수정:
- `MeasurementTabPlaceholder()` → `HomeView()` 로 변경
- `private struct MeasurementTabPlaceholder: View { ... }` 삭제

- [ ] **Step 4: 빌드 + commit**

```bash
cd "/Users/byunggyusong/1_개발폴더/마스터프로젝트/PoseAnalyzer/PoseAnalyzer"
xcodebuild build -project PoseAnalyzer.xcodeproj -scheme PoseAnalyzer \
  -destination 'platform=iOS Simulator,id=BF407CD0-C970-45EF-91FD-7FEB05483871' \
  2>&1 | tail -10
```

```bash
cd "/Users/byunggyusong/1_개발폴더/마스터프로젝트/PoseAnalyzer"
git add PoseAnalyzer/PoseAnalyzer/Presentation/Home/ \
        PoseAnalyzer/PoseAnalyzer/Presentation/AppTabView.swift \
        PoseAnalyzer/PoseAnalyzer/PoseAnalyzerApp.swift
git commit -m "feat(home): add HomeView + HomeViewModel 기본 골격 (CTA + 최근 측정)

Plan 2b Task 1: 홈 화면 진입점

- HomeViewModel(@Observable): latestSession, isWizardPresented, refresh
- HomeView: hero copy + 측정 시작 CTA(gradient) + 최근 측정 카드
- EnvironmentKey: dependencies (AppDependencies 주입)
- AppTabView의 measurement 탭 placeholder → HomeView로 교체
- 마법사 sheet는 Task 6에서 실제 화면 추가"
```

---

### Task 2: PhotosPicker 래퍼 (SwiftUI native)

**파일/경로:**
- 생성: `PoseAnalyzer/Presentation/Measurement/PhotoLibraryPicker.swift`

- [ ] **Step 1: PhotoLibraryPicker.swift 작성**

```swift
import SwiftUI
import PhotosUI

/// SwiftUI native PhotosPicker 래퍼 — 1장만 선택, UIImage로 변환
struct PhotoLibraryPicker: View {
    
    @Binding var isPresented: Bool
    var onPicked: (UIImage) -> Void
    
    @State private var selection: PhotosPickerItem?
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    
    var body: some View {
        PhotosPicker(
            selection: $selection,
            matching: .images,
            photoLibrary: .shared()
        ) {
            EmptyView()
        }
        .onChange(of: selection) { _, newItem in
            guard let item = newItem else { return }
            Task {
                await load(item: item)
            }
        }
        .alert("사진 불러오기 실패", isPresented: .constant(errorMessage != nil), actions: {
            Button("확인") { errorMessage = nil }
        }, message: {
            if let msg = errorMessage {
                Text(msg)
            }
        })
    }
    
    private func load(item: PhotosPickerItem) async {
        isLoading = true
        defer {
            isLoading = false
            selection = nil
            isPresented = false
        }
        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                onPicked(image)
            } else {
                errorMessage = "사진 데이터를 읽을 수 없습니다."
            }
        } catch {
            errorMessage = "사진 불러오기 중 오류: \(error.localizedDescription)"
        }
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
git add PoseAnalyzer/PoseAnalyzer/Presentation/Measurement/PhotoLibraryPicker.swift
git commit -m "feat(measurement): add PhotoLibraryPicker (SwiftUI PhotosPicker 래퍼)

Plan 2b Task 2: 사진 라이브러리 선택

- PhotosPicker(.images, single) → loadTransferable → UIImage
- 콜백 기반 (onPicked: (UIImage) -> Void)
- 로딩/에러 처리 + alert"
```

---

### Task 3: CameraImagePicker 래퍼 (UIImagePickerController)

**파일/경로:**
- 생성: `PoseAnalyzer/Presentation/Measurement/CameraImagePicker.swift`

- [ ] **Step 1: CameraImagePicker.swift 작성**

```swift
import SwiftUI
import UIKit

/// UIImagePickerController(.camera) SwiftUI 래퍼
/// 시뮬레이터에서는 사용 불가 → isAvailable로 확인 후 호출
struct CameraImagePicker: UIViewControllerRepresentable {
    
    var onPicked: (UIImage) -> Void
    var onCancel: () -> Void
    
    static var isAvailable: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onPicked: onPicked, onCancel: onCancel)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.cameraCaptureMode = .photo
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onPicked: (UIImage) -> Void
        let onCancel: () -> Void
        
        init(onPicked: @escaping (UIImage) -> Void, onCancel: @escaping () -> Void) {
            self.onPicked = onPicked
            self.onCancel = onCancel
        }
        
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                onPicked(image)
            } else {
                onCancel()
            }
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            onCancel()
        }
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
git add PoseAnalyzer/PoseAnalyzer/Presentation/Measurement/CameraImagePicker.swift
git commit -m "feat(measurement): add CameraImagePicker (UIImagePickerController 래퍼)

Plan 2b Task 3: 카메라 촬영

- UIImagePickerController(.camera) UIViewControllerRepresentable 래퍼
- onPicked/onCancel 콜백
- isAvailable static: 시뮬레이터 분기용"
```

---

## Phase 2: MeasurementViewModel & 사진 입력 시트

### Task 4: MeasurementViewModel (상태 관리)

**파일/경로:**
- 생성: `PoseAnalyzer/Presentation/Measurement/MeasurementViewModel.swift`

- [ ] **Step 1: MeasurementViewModel.swift 작성**

```swift
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
                self.step = .front
            } catch {
                self.errorMessage = "예상치 못한 오류: \(error.localizedDescription)"
                self.step = .front
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
git add PoseAnalyzer/PoseAnalyzer/Presentation/Measurement/MeasurementViewModel.swift
git commit -m "feat(measurement): add MeasurementViewModel (3단계 상태 관리 + 분석 실행)

Plan 2b Task 4: 측정 마법사 상태

- Step enum: front/side/height/analyzing/done
- setFrontImage → step=side, setSideImage → 저장된 키 있으면 analyzing, 없으면 height
- submitHeight: 키 저장 + analyzing 시작
- startAnalysis: AnalyzeSessionUseCase 호출, SessionReport 보관
- parsedHeight: 50~250cm 유효성"
```

---

### Task 5: PhotoInputSheet (라이브러리/카메라 선택 시트)

**파일/경로:**
- 생성: `PoseAnalyzer/Presentation/Measurement/PhotoInputSheet.swift`

- [ ] **Step 1: PhotoInputSheet.swift 작성**

```swift
import SwiftUI

/// 사진 입력 방식 선택 (카메라 / 라이브러리) 액션 시트
/// 시뮬레이터에서는 카메라 버튼 비활성화
struct PhotoInputSheet: View {
    
    @Binding var isPresented: Bool
    var onPicked: (UIImage) -> Void
    
    @State private var showLibrary = false
    @State private var showCamera = false
    
    var body: some View {
        VStack(spacing: AppSpacing.s3) {
            // 핸들
            Capsule()
                .fill(Color.border1)
                .frame(width: 40, height: 4)
                .padding(.top, AppSpacing.s3)
            
            Text("사진 선택")
                .font(.appH3)
                .foregroundStyle(Color.fg1)
                .padding(.top, AppSpacing.s2)
            
            VStack(spacing: AppSpacing.s2) {
                AppButton(
                    variant: .primary,
                    size: .large,
                    isDisabled: !CameraImagePicker.isAvailable,
                    action: { showCamera = true }
                ) {
                    HStack(spacing: 8) {
                        Image(systemName: "camera.fill")
                        Text(CameraImagePicker.isAvailable ? "카메라로 촬영" : "카메라 사용 불가 (시뮬레이터)")
                    }
                }
                
                AppButton(variant: .secondary, size: .large) {
                    showLibrary = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "photo.on.rectangle")
                        Text("라이브러리에서 선택")
                    }
                }
                
                AppButton("취소", variant: .ghost, size: .medium) {
                    isPresented = false
                }
            }
            .padding(.horizontal, AppSpacing.s4)
            .padding(.bottom, AppSpacing.s5)
        }
        .frame(maxWidth: .infinity)
        .background(Color.bgSurface)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous))
        // PhotosPicker는 자체 sheet 처리하므로 background에 둠
        .background(
            PhotoLibraryPicker(isPresented: $showLibrary) { image in
                isPresented = false
                onPicked(image)
            }
        )
        .fullScreenCover(isPresented: $showCamera) {
            CameraImagePicker(
                onPicked: { image in
                    showCamera = false
                    isPresented = false
                    onPicked(image)
                },
                onCancel: {
                    showCamera = false
                }
            )
            .ignoresSafeArea()
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
git add PoseAnalyzer/PoseAnalyzer/Presentation/Measurement/PhotoInputSheet.swift
git commit -m "feat(measurement): add PhotoInputSheet (카메라/라이브러리 선택)

Plan 2b Task 5: 사진 입력 방식 시트

- 카메라 / 라이브러리 액션
- CameraImagePicker.isAvailable 확인 후 카메라 버튼 비활성화 (시뮬레이터 대응)
- fullScreenCover로 카메라, PhotosPicker는 단독"
```

---

## Phase 3: 측정 마법사 화면 (Step 1-3)

### Task 6: WizardStepView (정면/측면 공통 사진 입력 단계)

**파일/경로:**
- 생성: `PoseAnalyzer/Presentation/Measurement/WizardStepView.swift`

- [ ] **Step 1: WizardStepView.swift 작성**

```swift
import SwiftUI

/// 마법사의 사진 입력 단계 (정면 OR 측면 공통 컴포넌트)
struct WizardStepView: View {
    
    let view: SessionView   // .front 또는 .side
    let stepIndex: Int      // 1, 2
    let totalSteps: Int     // 3
    var onPicked: (UIImage) -> Void
    var onBack: () -> Void
    
    @State private var isInputSheetPresented = false
    
    var body: some View {
        VStack(spacing: 0) {
            // 진행 바
            progressBar
            
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.s4) {
                    Text(subtitle)
                        .font(.appCallout)
                        .foregroundStyle(Color.fg2)
                        .padding(.top, AppSpacing.s4)
                    
                    guideCard
                    
                    AppButton {
                        isInputSheetPresented = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "camera.fill")
                            Text("\(view.koreanName) 사진 선택")
                        }
                    }
                    .padding(.top, AppSpacing.s2)
                }
                .padding(.horizontal, AppSpacing.s4)
                .padding(.bottom, AppSpacing.s10)
            }
        }
        .background(Color.bgCanvas)
        .navigationTitle("\(view.koreanName) 사진")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(Color.brandPrimary)
                }
            }
            ToolbarItem(placement: .principal) {
                VStack(spacing: 1) {
                    Text("\(view.koreanName) 사진")
                        .font(.appTitle)
                    Text("STEP \(stepIndex) / \(totalSteps)")
                        .font(.system(size: 11, weight: .semibold))
                        .kerning(0.01)
                        .foregroundStyle(Color.fg3)
                }
            }
        }
        .sheet(isPresented: $isInputSheetPresented) {
            PhotoInputSheet(isPresented: $isInputSheetPresented, onPicked: onPicked)
                .presentationDetents([.height(320)])
                .presentationDragIndicator(.hidden)
        }
    }
    
    // MARK: - Pieces
    
    private var subtitle: String {
        switch view {
        case .front: return "어깨와 골반이 보이도록 정면을 향해주세요"
        case .side: return "한쪽 옆모습 전체가 보이도록 서주세요"
        }
    }
    
    private var progressBar: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.border2)
                    .frame(height: 3)
                Capsule()
                    .fill(Color.brandPrimary)
                    .frame(width: proxy.size.width * CGFloat(stepIndex) / CGFloat(totalSteps), height: 3)
                    .animation(.easeOut(duration: 0.22), value: stepIndex)
            }
        }
        .frame(height: 3)
        .padding(.horizontal, AppSpacing.s4)
    }
    
    private var guideCard: some View {
        AppCard(padding: 0) {
            VStack(spacing: 0) {
                // 가이드 일러스트 (placeholder — 향후 SF Symbol + 외곽선)
                ZStack {
                    LinearGradient(
                        colors: [Color.gray.opacity(0.5), Color.gray.opacity(0.8)],
                        startPoint: .top, endPoint: .bottom
                    )
                    Image(systemName: view == .front ? "figure.stand" : "figure.walk")
                        .font(.system(size: 80, weight: .light))
                        .foregroundStyle(Color.white.opacity(0.85))
                    
                    // 가이드 점선
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.white.opacity(0.55), style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                        .padding(20)
                }
                .frame(maxWidth: .infinity, minHeight: 280)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg - 4, style: .continuous))
                .overlay(alignment: .topLeading) {
                    Text(view == .front ? "정면 가이드" : "측면 가이드")
                        .font(.appMicro)
                        .foregroundStyle(Color.white)
                        .padding(.vertical, 4).padding(.horizontal, 10)
                        .background(Color.black.opacity(0.45), in: Capsule())
                        .padding(12)
                }
            }
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
git add PoseAnalyzer/PoseAnalyzer/Presentation/Measurement/WizardStepView.swift
git commit -m "feat(measurement): add WizardStepView (정면/측면 공통 사진 입력 단계)

Plan 2b Task 6: 마법사 사진 입력 화면

- progress bar (STEP X / Y, brandPrimary fill)
- 자세별 안내 텍스트 (정면/측면)
- guide card (placeholder 실루엣 + 점선 외곽)
- 사진 선택 버튼 → PhotoInputSheet
- toolbar: 뒤로 + 부제목(STEP X/Y)"
```

---

### Task 7: WizardHeightStepView (키 입력 단계)

**파일/경로:**
- 생성: `PoseAnalyzer/Presentation/Measurement/WizardHeightStepView.swift`

- [ ] **Step 1: WizardHeightStepView.swift 작성**

```swift
import SwiftUI

/// 마법사 Step 3 — 키 입력
struct WizardHeightStepView: View {
    
    @Binding var heightCm: String
    var isValid: Bool
    var onBack: () -> Void
    var onSubmit: () -> Void
    var onSkip: () -> Void
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // 진행 바
            progressBar
            
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.s4) {
                    Text("키를 입력하면 cm 단위로 비대칭을 분석합니다")
                        .font(.appCallout)
                        .foregroundStyle(Color.fg2)
                        .padding(.top, AppSpacing.s4)
                    
                    AppCard {
                        VStack(alignment: .leading, spacing: AppSpacing.s2) {
                            Text("키 (cm)")
                                .font(.appCaption.bold())
                                .foregroundStyle(Color.fg2)
                            HStack {
                                TextField("170", text: $heightCm)
                                    .keyboardType(.numberPad)
                                    .font(.appMetric)
                                    .foregroundStyle(Color.fg1)
                                    .focused($isFocused)
                                Text("cm")
                                    .font(.appH2)
                                    .foregroundStyle(Color.fg3)
                            }
                            if !heightCm.isEmpty && !isValid {
                                Text("50~250cm 범위로 입력해주세요")
                                    .font(.appCaption)
                                    .foregroundStyle(Color.statusSuspect)
                            }
                        }
                    }
                    
                    Text("한 번 입력한 키는 다음 측정에 자동으로 적용됩니다.")
                        .font(.appCaption)
                        .foregroundStyle(Color.fg3)
                        .padding(.top, AppSpacing.s1)
                    
                    Spacer(minLength: AppSpacing.s7)
                    
                    AppButton("분석 시작", isDisabled: !isValid, action: onSubmit)
                    AppButton("건너뛰기 (키 없이 진행)", variant: .ghost, size: .medium, action: onSkip)
                }
                .padding(.horizontal, AppSpacing.s4)
                .padding(.bottom, AppSpacing.s10)
            }
        }
        .background(Color.bgCanvas)
        .navigationTitle("키 입력")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(Color.brandPrimary)
                }
            }
            ToolbarItem(placement: .principal) {
                VStack(spacing: 1) {
                    Text("키 입력")
                        .font(.appTitle)
                    Text("STEP 3 / 3")
                        .font(.system(size: 11, weight: .semibold))
                        .kerning(0.01)
                        .foregroundStyle(Color.fg3)
                }
            }
        }
        .onAppear { isFocused = true }
    }
    
    private var progressBar: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.border2)
                    .frame(height: 3)
                Capsule()
                    .fill(Color.brandPrimary)
                    .frame(width: proxy.size.width, height: 3)
            }
        }
        .frame(height: 3)
        .padding(.horizontal, AppSpacing.s4)
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
git add PoseAnalyzer/PoseAnalyzer/Presentation/Measurement/WizardHeightStepView.swift
git commit -m "feat(measurement): add WizardHeightStepView (Step 3 키 입력)

Plan 2b Task 7: 키 입력 화면

- TextField (numberPad) + cm 단위
- 50~250cm 유효성 검사 → 인라인 에러
- 분석 시작 / 건너뛰기 (키 없이 진행) 두 버튼
- 한 번 입력 시 다음 측정 자동 적용 안내"
```

---

### Task 8: AnalyzingView (분석 중 로딩)

**파일/경로:**
- 생성: `PoseAnalyzer/Presentation/Measurement/AnalyzingView.swift`

- [ ] **Step 1: AnalyzingView.swift 작성**

```swift
import SwiftUI

/// 분석 중 표시 화면 — "관절 인식 중…" → "자세 분석 중…"
struct AnalyzingView: View {
    
    let phase: String
    
    @State private var pulse = false
    
    var body: some View {
        VStack(spacing: AppSpacing.s5) {
            Spacer()
            
            ZStack {
                Circle()
                    .stroke(Color.brandPrimary.opacity(0.15), lineWidth: 6)
                    .frame(width: 120, height: 120)
                Circle()
                    .stroke(Color.brandPrimary, lineWidth: 6)
                    .frame(width: 120, height: 120)
                    .scaleEffect(pulse ? 1.0 : 0.85)
                    .opacity(pulse ? 0 : 1.0)
                    .animation(
                        .easeInOut(duration: 1.4)
                            .repeatForever(autoreverses: false),
                        value: pulse
                    )
                Image(systemName: "figure.stand")
                    .font(.system(size: 48, weight: .light))
                    .foregroundStyle(Color.brandPrimary)
            }
            .onAppear { pulse = true }
            
            VStack(spacing: AppSpacing.s2) {
                Text("분석 중…")
                    .font(.appH2)
                    .foregroundStyle(Color.fg1)
                Text(phase)
                    .font(.appCallout)
                    .foregroundStyle(Color.fg2)
                    .id(phase)
                    .transition(.opacity)
                    .animation(.easeOut(duration: 0.22), value: phase)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.bgCanvas)
        .toolbar(.hidden)
    }
}

#Preview {
    AnalyzingView(phase: "관절 인식 중…")
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
git add PoseAnalyzer/PoseAnalyzer/Presentation/Measurement/AnalyzingView.swift
git commit -m "feat(measurement): add AnalyzingView (분석 중 breathing pulse)

Plan 2b Task 8: 분석 중 화면

- 원형 pulse 애니메이션 (1.4s, repeatForever)
- '분석 중…' 타이틀 + 상태 phase 텍스트 transition
- toolbar 숨김 (전체 화면)"
```

---

### Task 9: MeasurementWizardView (3단계 통합)

**파일/경로:**
- 생성: `PoseAnalyzer/Presentation/Measurement/MeasurementWizardView.swift`

- [ ] **Step 1: MeasurementWizardView.swift 작성**

```swift
import SwiftUI

/// 측정 마법사 — Step 1(정면) → Step 2(측면) → Step 3(키) → Analyzing → Done
struct MeasurementWizardView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dependencies) private var dependencies
    
    /// 분석 완료 시 SessionReport 전달 (호출자에서 결과 화면으로 라우팅)
    var onCompleted: (SessionReport) -> Void
    
    @State private var viewModel: MeasurementViewModel?
    
    var body: some View {
        NavigationStack {
            Group {
                if let vm = viewModel {
                    content(vm)
                } else {
                    ProgressView().onAppear {
                        viewModel = MeasurementViewModel(
                            analyzeUseCase: dependencies.analyzeSessionUseCase,
                            userProfileRepository: dependencies.userProfileRepository
                        )
                    }
                }
            }
        }
        .interactiveDismissDisabled(viewModel?.step == .analyzing)
        .alert("분석 실패", isPresented: Binding(
            get: { viewModel?.errorMessage != nil },
            set: { if !$0 { viewModel?.errorMessage = nil } }
        )) {
            Button("다시 측정") { viewModel?.retryFromBeginning() }
            Button("닫기", role: .cancel) { dismiss() }
        } message: {
            if let msg = viewModel?.errorMessage { Text(msg) }
        }
    }
    
    @ViewBuilder
    private func content(_ vm: MeasurementViewModel) -> some View {
        switch vm.step {
        case .front:
            WizardStepView(
                view: .front,
                stepIndex: 1,
                totalSteps: 3,
                onPicked: { image in vm.setFrontImage(image) },
                onBack: { dismiss() }
            )
        case .side:
            WizardStepView(
                view: .side,
                stepIndex: 2,
                totalSteps: 3,
                onPicked: { image in vm.setSideImage(image) },
                onBack: { vm.step = .front }
            )
        case .height:
            WizardHeightStepView(
                heightCm: Binding(get: { vm.heightCm }, set: { vm.heightCm = $0 }),
                isValid: vm.isHeightValid,
                onBack: { vm.step = .side },
                onSubmit: { vm.submitHeight() },
                onSkip: { vm.skipHeight() }
            )
        case .analyzing:
            AnalyzingView(phase: vm.analyzingPhase)
        case .done:
            // Plan 2c 결과 화면으로 라우팅
            DoneRouter(report: vm.report) { report in
                onCompleted(report)
                dismiss()
            }
        }
    }
}

/// step==.done일 때 SessionReport를 부모에 전달 후 dismiss (Plan 2c에서 결과 화면으로 push)
private struct DoneRouter: View {
    let report: SessionReport?
    var onReady: (SessionReport) -> Void
    var body: some View {
        ZStack {
            Color.bgCanvas.ignoresSafeArea()
            ProgressView()
        }
        .onAppear {
            if let report {
                onReady(report)
            }
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
git add PoseAnalyzer/PoseAnalyzer/Presentation/Measurement/MeasurementWizardView.swift
git commit -m "feat(measurement): add MeasurementWizardView (3단계 통합 + analyzing)

Plan 2b Task 9: 마법사 통합 뷰

- NavigationStack 내 step switch (front/side/height/analyzing/done)
- interactiveDismissDisabled: analyzing 중 swipe-down 금지
- 에러 alert: '다시 측정' / '닫기'
- step=.done → DoneRouter로 SessionReport 부모에 전달"
```

---

## Phase 4: HomeView 연결 + 임시 결과 화면

### Task 10: HomeView에 MeasurementWizardView 연결 + 결과 placeholder

**파일/경로:**
- 수정: `PoseAnalyzer/Presentation/Home/HomeView.swift`
- 생성: `PoseAnalyzer/Presentation/Result/ResultPlaceholderView.swift`

- [ ] **Step 1: ResultPlaceholderView.swift 작성**

```swift
import SwiftUI

/// Plan 2c에서 실제 AnalysisResultView로 교체될 임시 결과 화면
struct ResultPlaceholderView: View {
    
    let report: SessionReport
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.s4) {
                AppCard {
                    VStack(alignment: .leading, spacing: AppSpacing.s2) {
                        Text("측정 완료")
                            .font(.appH2)
                            .foregroundStyle(Color.fg1)
                        Text("측정 시각: \(report.measuredAt.formatted(date: .abbreviated, time: .shortened))")
                            .font(.appCaption)
                            .foregroundStyle(Color.fg2)
                        Text("자세 결과: \(report.postures.count)개")
                            .font(.appCaption)
                            .foregroundStyle(Color.fg2)
                        Text("키: \(report.heightCmAtMeasure.map { "\(Int($0))cm" } ?? "미입력")")
                            .font(.appCaption)
                            .foregroundStyle(Color.fg2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                ForEach(report.postures.indices, id: \.self) { i in
                    let p = report.postures[i]
                    HStack {
                        Text(p.type.koreanName)
                            .font(.appBody)
                            .foregroundStyle(Color.fg1)
                        Spacer()
                        StatusBadge(status: p.status, tone: .soft, size: .small)
                        Text("\(String(format: "%.1f", p.primaryMetric))\(p.primaryMetricUnit.symbol)")
                            .font(.appCaption.monospacedDigit())
                            .foregroundStyle(Color.fg2)
                    }
                    .padding(.horizontal, AppSpacing.s4)
                    .padding(.vertical, AppSpacing.s2)
                    .background(Color.bgSurface, in: RoundedRectangle(cornerRadius: AppRadius.md))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.md)
                            .strokeBorder(Color.border1, lineWidth: 1)
                    )
                }
                
                Text("Plan 2c에서 사진 + 관절 오버레이 + 비대칭 + 직전 대비 변화 추가")
                    .font(.appCaption)
                    .foregroundStyle(Color.fg3)
                    .padding(.top, AppSpacing.s4)
            }
            .padding(.horizontal, AppSpacing.s4)
            .padding(.bottom, AppSpacing.s10)
        }
        .background(Color.bgCanvas)
        .navigationTitle("분석 결과")
        .navigationBarTitleDisplayMode(.inline)
    }
}
```

- [ ] **Step 2: HomeView.swift 수정**

`sheet(isPresented:)` 블록을 다음으로 교체:

```swift
.sheet(isPresented: Binding(
    get: { viewModel?.isWizardPresented ?? false },
    set: { viewModel?.isWizardPresented = $0 }
)) {
    MeasurementWizardView { report in
        // 분석 완료: 결과 화면으로 push
        latestReport = report
        showResult = true
    }
    .presentationDetents([.large])
}
.navigationDestination(isPresented: $showResult) {
    if let report = latestReport {
        ResultPlaceholderView(report: report)
    }
}
```

HomeView 안에 다음 상태 추가:
```swift
@State private var latestReport: SessionReport?
@State private var showResult: Bool = false
```

- [ ] **Step 3: 빌드 + 시뮬레이터 흐름 검증**

```bash
cd "/Users/byunggyusong/1_개발폴더/마스터프로젝트/PoseAnalyzer/PoseAnalyzer"
xcodebuild build -project PoseAnalyzer.xcodeproj -scheme PoseAnalyzer \
  -destination 'platform=iOS Simulator,id=BF407CD0-C970-45EF-91FD-7FEB05483871' \
  2>&1 | tail -10
```

- [ ] **Step 4: commit**

```bash
cd "/Users/byunggyusong/1_개발폴더/마스터프로젝트/PoseAnalyzer"
git add PoseAnalyzer/PoseAnalyzer/Presentation/Home/HomeView.swift \
        PoseAnalyzer/PoseAnalyzer/Presentation/Result/
git commit -m "feat(measurement): wire MeasurementWizardView into HomeView + ResultPlaceholderView

Plan 2b Task 10: 흐름 통합

- HomeView의 sheet에 MeasurementWizardView 연결
- 분석 완료 콜백 → ResultPlaceholderView로 navigationDestination push
- ResultPlaceholderView: 측정 메타 + 8 자세 결과 행 (간단)
- 실제 결과 화면은 Plan 2c에서 작성"
```

---

## Phase 5: 마무리

### Task 11: 시뮬레이터 흐름 검증 + Plan 1 회귀 + tag

- [ ] **Step 1: 전체 테스트 실행 (Plan 1 회귀)**

```bash
cd "/Users/byunggyusong/1_개발폴더/마스터프로젝트/PoseAnalyzer/PoseAnalyzer"
xcodebuild test -project PoseAnalyzer.xcodeproj -scheme PoseAnalyzer \
  -destination 'platform=iOS Simulator,id=BF407CD0-C970-45EF-91FD-7FEB05483871' \
  2>&1 | tail -15
```

Expected: 모든 단위테스트 통과 (66개 그대로).

- [ ] **Step 2: 시뮬레이터 시각 검증 (선택)**

시뮬레이터에서 앱 실행 → 측정 탭 → "측정 시작" → 사진 라이브러리에서 사진 2장 선택 → 키 입력 → Analyzing → ResultPlaceholderView 도달 확인.

(시뮬레이터에는 카메라 없으므로 라이브러리만 동작)

- [ ] **Step 3: Plan 2b tag**

```bash
cd "/Users/byunggyusong/1_개발폴더/마스터프로젝트/PoseAnalyzer"
git tag -a plan-2b-measurement-flow-complete -m "Plan 2b (Measurement Flow) 완료

홈 + 사진 입력(카메라/라이브러리) + 3단계 마법사 + 분석 중 + 결과 placeholder.
실제 SessionReport가 Vision으로 생성되어 결과 화면까지 전달됨.

다음: Plan 2c (Result + History)."
```

---

## ✅ Plan 2b 완료 정의

- [ ] HomeView + HomeViewModel (CTA + 최근 측정 카드)
- [ ] PhotoLibraryPicker (SwiftUI PhotosPicker 래퍼)
- [ ] CameraImagePicker (UIImagePickerController 래퍼, 시뮬레이터 안전)
- [ ] MeasurementViewModel (3 step 상태 + UseCase 호출)
- [ ] PhotoInputSheet (카메라/라이브러리 선택)
- [ ] WizardStepView (정면/측면 공통 사진 입력)
- [ ] WizardHeightStepView (Step 3 키 입력 + 50-250 검증)
- [ ] AnalyzingView (breathing pulse)
- [ ] MeasurementWizardView (3 step 통합 + alert)
- [ ] ResultPlaceholderView (Plan 2c용 임시)
- [ ] HomeView ↔ Wizard ↔ Result 라우팅 연결
- [ ] 시뮬레이터에서 전체 흐름 도달 (라이브러리 모드)
- [ ] Plan 1 단위테스트 66/66 회귀 없음
- [ ] `plan-2b-measurement-flow-complete` tag

---

## ⏭ 다음 (Plan 2c)

Plan 2c (Result + History) 작성:
- AnalysisResultView (사진 + 관절 오버레이 + 8 카드 + 비대칭 + 직전 비교)
- PoseOverlayView (Canvas 기반)
- HistoryListView (시간 역순 카드 리스트)
- TrendView (Swift Charts)
- SettingsView (키 변경)
- ResultPlaceholderView 제거
