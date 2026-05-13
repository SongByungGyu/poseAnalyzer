# PoseAnalyzer — 디자인 문서

- 작성일: 2026-05-13
- 작성자: 사용자(servicedevclaude@gmail.com) × Claude
- 상태: 1차 MVP 디자인 확정, 구현 계획(plan) 작성 대기

---

## 1. 프로젝트 개요

### 목적
카메라 또는 사진 라이브러리에서 받은 **정면·측면 사진 2장**을 Apple Vision으로 분석하여 사용자의 자세 문제(거북목, 라운드숄더 등 8가지)를 자동 판정하고, 시간에 따른 변화 추이를 추적하는 iOS 앱.

### 스코프
- **1차 (MVP, 이 문서의 범위)**: 정지 사진 기반 8가지 자세 판정 + 히스토리 + 추이 그래프
- **2차 (이후)**: 영상 기반 동적 자세 분석 (스쿼트, 러닝 등 운동 자세 교정)

### 위치 및 메타정보
| 항목 | 값 |
|------|------|
| 프로젝트 위치 | `마스터프로젝트/PoseAnalyzer/` (마스터프로젝트 신규 하위 프로젝트) |
| 앱 이름 | PoseAnalyzer |
| Bundle ID | `com.pose.poseanalyzer` |
| 최소 지원 OS | iOS 17.0 |
| 언어 / UI | Swift 5.9+ / SwiftUI |
| 외부 라이브러리 | **없음** (모두 Apple 표준 프레임워크) |
| 핵심 의존성 | Vision, PhotosUI, AVFoundation, SwiftData, Charts |

### 마스터프로젝트 규칙(RULES.md) 준수
- 모든 응답·문서·코멘트 한국어
- 기획 → 검토 → 승인 → 개발 흐름
- 작업 완료 후 기록 여부 사용자에게 확인 후 `docs/changelog/`에 저장

---

## 2. 화면 흐름

### 탭 구조
```
┌──────────────────────────────────────────┐
│  PoseAnalyzer        [⚙️ 설정 진입점]     │
├──────────────────────────────────────────┤
│         [화면 컨텐츠 영역]                │
├──────────────────────────────────────────┤
│   📷 측정          📊 기록                │
└──────────────────────────────────────────┘
```

### 화면 목록
1. **HomeView** — 측정 시작 진입점, 최근 결과 요약, 우측 상단 ⚙️ 설정 진입
2. **MeasurementWizardView** — 3단계 마법사 (정면 → 측면 → 키 입력)
3. **CameraView** — 카메라 라이브 프리뷰 + 가이드 오버레이 + 셔터. 촬영 직후 **확인 화면**(다시 찍기 / 사용하기) 표시 후 마법사 다음 Step으로 진행
4. **AnalyzingView** — 로딩 인디케이터 ("관절 인식 중 → 자세 분석 중")
5. **AnalysisResultView** — 두 사진 + 관절 오버레이 + 8개 자세 판정 카드 + 비대칭 + 이전 측정 대비 변화
6. **HistoryListView** — 시간 역순 기록 리스트, "추이" 진입 버튼
7. **TrendView** — Swift Charts 기반 자세별 시간축 그래프 (7일/30일/전체)
8. **SettingsView** — 키 변경 등 (향후 임계값 튜닝)
9. **PermissionView** — 카메라/사진 권한 거부 시 안내

### 측정 마법사 상세 흐름
```
HomeView → "측정 시작"
   ↓
Step 1 / 3  정면 사진 (카메라 또는 라이브러리)
Step 2 / 3  측면 사진 (카메라 또는 라이브러리)
Step 3 / 3  키 입력 (cm)
   - 저장된 키 있으면 → 이 단계 건너뛰고 바로 분석
   - 변경하려면 결과 화면 또는 설정에서
   ↓
AnalyzingView → AnalysisResultView
   ├─ "저장하기" → SwiftData + 이미지 파일 저장 → 기록 탭으로
   └─ "다시 측정" → HomeView 복귀
```

### 기록 탭 흐름
```
HistoryListView
   ├─ 시간 역순 카드 리스트 (썸네일 2장, 8개 판정 요약, 직전 대비 변화)
   ├─ 카드 탭 → AnalysisResultView (읽기 전용)
   └─ "📊 추이" → TrendView
        ├─ 자세 종류 토글 (8개 중 선택)
        └─ 기간 필터 (7일 / 30일 / 전체)
```

### 분석 결과 화면 구성 (스크롤)
1. 상단: 정면·측면 사진 나란히 (관절 점/선 오버레이 포함)
2. 종합 판정 카드 8개 — 각 자세별 🟢 정상 / 🟡 주의 / 🟠 의심 / ⚪ 측정 불가 + 핵심 수치 + 게이지
3. 좌우 비대칭 영역 — 어깨/골반 좌우 높이차 (cm 또는 어깨너비 비율)
4. 이전 측정 대비 변화 — **가장 최근 직전 1건과 비교**하여 자세별 핵심 수치 증감 표시 (직전 기록 없으면 이 영역 표시 안 함)

---

## 3. 아키텍처 (B+ : MVVM + 프로토콜 기반 분석 도메인)

### 채택 이유
- 1차 MVP는 빠르게, 2차 영상 분석 확장에도 자연스럽게 대응
- 분석 도메인을 프로토콜로 추상화해두면 자세 종류 추가, Vision 교체, 영상 분석 추가가 모두 모듈 1개 추가/교체로 끝남
- 코드 누적 시 SPM 모듈 분리(C 아키텍처)로 자연스럽게 진화 가능

### 폴더 구조
```
PoseAnalyzer/
├── App/
│   ├── PoseAnalyzerApp.swift         (앱 진입점, SwiftData 컨테이너)
│   └── AppDependencies.swift         (DI 컨테이너)
│
├── Domain/                            ← 핵심 도메인 (UI 무관)
│   ├── Models/
│   │   ├── PoseFrame.swift           (관절 좌표 1장 분량)
│   │   ├── PoseSession.swift         (정면+측면 한 세트)
│   │   ├── PostureResult.swift       (개별 자세 판정 결과)
│   │   ├── AsymmetryResult.swift     (좌우 비대칭 결과)
│   │   └── SessionReport.swift       (한 측정의 모든 결과 묶음)
│   ├── Detection/
│   │   ├── PoseDetector.swift        (protocol)
│   │   └── VisionPoseDetector.swift  (Apple Vision 구현)
│   ├── Evaluation/
│   │   ├── PostureEvaluator.swift    (protocol)
│   │   ├── ForwardHeadEvaluator.swift
│   │   ├── RoundShoulderEvaluator.swift
│   │   ├── KyphosisEvaluator.swift
│   │   ├── AnteriorPelvicTiltEvaluator.swift
│   │   ├── KneeHyperextensionEvaluator.swift
│   │   ├── ScoliosisEvaluator.swift
│   │   ├── HeadTiltEvaluator.swift
│   │   └── KneeAlignmentEvaluator.swift
│   ├── Asymmetry/
│   │   ├── AsymmetryAnalyzer.swift   (protocol)
│   │   └── DefaultAsymmetryAnalyzer.swift
│   ├── Motion/                        ← 2차 영상용 (인터페이스만)
│   │   └── MotionAnalyzer.swift      (protocol, 구현 X)
│   └── UseCase/
│       └── AnalyzeSessionUseCase.swift
│
├── Data/
│   ├── SwiftData/
│   │   ├── UserProfile.swift         (@Model)
│   │   ├── SessionRecord.swift       (@Model)
│   │   └── PostureRecord.swift       (@Model)
│   ├── ImageStore.swift              (사진 파일 저장/로드)
│   └── SessionRepository.swift       (CRUD)
│
├── Presentation/
│   ├── Home/
│   │   ├── HomeView.swift
│   │   └── HomeViewModel.swift
│   ├── Measurement/
│   │   ├── MeasurementWizardView.swift
│   │   ├── MeasurementViewModel.swift
│   │   ├── CameraView.swift
│   │   └── PhotoPickerView.swift
│   ├── Result/
│   │   ├── AnalysisResultView.swift
│   │   ├── AnalysisResultViewModel.swift
│   │   ├── PoseOverlayView.swift     (관절 점/선 캔버스)
│   │   └── PostureCardView.swift
│   ├── History/
│   │   ├── HistoryListView.swift
│   │   ├── HistoryViewModel.swift
│   │   └── TrendView.swift
│   ├── Settings/
│   │   └── SettingsView.swift
│   └── Common/
│       ├── PermissionView.swift
│       └── Components/
│
├── Resources/
│   ├── Assets.xcassets
│   ├── Localizable.strings
│   └── Info.plist
│
└── Support/
    ├── Extensions/
    └── Utils/
        └── GeometryMath.swift        (각도 계산 유틸)
```

### 핵심 프로토콜 시그니처 (의사코드)

```swift
// Vision 호출
protocol PoseDetector {
    func detect(image: UIImage, view: SessionView) async throws -> PoseFrame
}

// 자세 판정 (정면용/측면용 구분)
protocol PostureEvaluator {
    var type: PostureType { get }
    var requiredView: SessionView { get }   // .front / .side
    func evaluate(_ frame: PoseFrame) -> PostureResult
}

// 비대칭 분석
protocol AsymmetryAnalyzer {
    func analyze(_ frontFrame: PoseFrame, heightCm: Double?) -> AsymmetryResult
}

// 영상 분석 (2차 - 인터페이스만, MVP는 구현 X)
protocol MotionAnalyzer {
    var name: String { get }
    func analyze(_ stream: AsyncStream<PoseFrame>) -> AsyncStream<MotionResult>
}

// UseCase: View가 호출하는 단일 진입점
final class AnalyzeSessionUseCase {
    init(detector: PoseDetector,
         evaluators: [PostureEvaluator],
         asymmetryAnalyzer: AsymmetryAnalyzer)

    func analyze(front: UIImage, side: UIImage, heightCm: Double?) async throws -> SessionReport
}
```

### 의존성 흐름 (단방향)
```
Presentation → UseCase → Domain Protocols ← Vision 구현체
                                          ← SwiftData 구현체
```
View는 항상 UseCase만 호출. UseCase는 프로토콜에만 의존. 구현체는 `AppDependencies`에서 주입.

### 확장 시나리오
| 변경 시나리오 | 수정 위치 |
|------|------|
| 새 자세 추가 | `Evaluation/` 에 클래스 1개 추가 + DI 등록 |
| Vision → ML Kit 교체 | `PoseDetector` 구현체 교체, 나머지 무영향 |
| 2차 영상 분석 (스쿼트) | `Motion/` 에 구현체 추가, 새 화면 추가 |
| 판정 임계값 튜닝 | 해당 Evaluator 안의 상수만 |
| 저장 방식 변경 | `SessionRepository` 구현만 |

---

## 4. 자세 판정 알고리즘 (8개)

모든 임계값은 임상 가이드라인 기준 초기값이며, 각 Evaluator 안의 상수로 분리하여 추후 튜닝 가능.

### 사용 관절 (`VNHumanBodyPoseObservation.JointName`)
- 머리: `.leftEye`, `.rightEye`, `.leftEar`, `.rightEar`, `.nose`
- 상체: `.neck`, `.leftShoulder`, `.rightShoulder`
- 하체: `.leftHip`, `.rightHip`, `.leftKnee`, `.rightKnee`, `.leftAnkle`, `.rightAnkle`

### 측면 사진 판정 (5개)

| # | 자세 | 사용 관절 | 측정 | 정상 | 주의 🟡 | 의심 🟠 |
|---|------|----------|------|------|---------|---------|
| 1 | **거북목** (Forward Head Posture) | 귀-어깨-엉덩이 | 세 점 각도 | ≥ 170° | 160-170° | < 160° |
| 2 | **라운드숄더** (Round Shoulder) | 어깨-귀 수평거리 / 어깨 폭 비율 | 정규화 거리비 | < 0.15 | 0.15-0.25 | > 0.25 |
| 3 | **흉추 후만증** (Kyphosis) | 목-어깨-엉덩이 | 세 점 각도 | ≥ 175° | 165-175° | < 165° |
| 4 | **골반 전방경사** (Anterior Pelvic Tilt) | 어깨-엉덩이-무릎 | 세 점 각도 | 175-185° | 170-175° or 185-190° | <170° or >190° |
| 5 | **무릎 과신전** (Knee Hyperextension) | 엉덩이-무릎-발목 | 세 점 각도 | 175-185° | 185-190° | > 190° |

### 정면 사진 판정 (3개)

| # | 자세 | 사용 관절 | 측정 | 정상 | 주의 🟡 | 의심 🟠 |
|---|------|----------|------|------|---------|---------|
| 6 | **척추측만** (Scoliosis) | 양 어깨·양 엉덩이 | 어깨선 + 엉덩이선 기울기 | 둘 다 <2° | 2-5° | > 5° |
| 7 | **머리 좌우 기울기** (Head Tilt) | 양 귀 (또는 양 눈) | 귀선 기울기 | < 2° | 2-5° | > 5° |
| 8 | **무릎 X자/O자** (Genu Valgum/Varum) | 엉덩이-무릎-발목 (좌·우 각각) | 양다리 각도 | 175-180° | 170-175° or 180-185° | < 170° (X) or > 185° (O) |

### 비대칭 분석 (정면 사진에서 추가 계산)
- **어깨 좌우 높이차**: 양 어깨 Y 좌표 차이 → cm 환산 또는 어깨너비 비율
- **골반 좌우 높이차**: 동일 방식
- 표시 예: "우측 어깨가 1.8cm 높음" / "어깨너비의 4% 차이"

### 키·cm 환산 (옵션 C: 혼합)
- 사용자 키 입력 있으면 → 사진 속 머리-발목 픽셀 거리 기반 비율 환산 → cm 단위 표시
- 키 입력 없으면 → "어깨너비의 X%" fallback
- 한 번 입력하면 `UserProfile`에 저장, 다음 측정 시 자동 채움. 변경은 결과 화면 또는 설정에서.

### 신뢰도(Confidence) 처리
- 모든 관절은 `confidence` 0-1
- **0.3 미만이면 신뢰 안 함**
- 판정 필요 관절 중 하나라도 신뢰 안 되면 → 그 자세는 "측정 불가" (의심으로 오판하지 않음)
- 좌/우 페어가 있는 경우 신뢰도 높은 쪽 자동 선택

### 측면 좌/우 자동 감지
사용자가 어느 쪽 측면(왼쪽/오른쪽)을 찍었는지 모름:
- **양쪽 모두 계산해서 평균 confidence가 높은 쪽 자동 채택** (왼쪽 귀-어깨-엉덩이 vs 오른쪽 귀-어깨-엉덩이)
- 코의 X 위치는 보조 힌트로만 사용

### 판정 결과 모델 (`PostureResult`)
```swift
struct PostureResult {
    let type: PostureType
    let status: PostureStatus           // .normal / .caution / .suspect / .unmeasurable
    let primaryMetric: Double           // 핵심 수치 (각도 또는 비율)
    let primaryMetricUnit: String       // "도", "cm", "비율"
    let thresholds: Thresholds          // 정상/주의/의심 경계
    let usedJoints: [JointName]
    let confidence: Double              // 사용 관절 평균 신뢰도
    let advice: String?                 // 간단한 권장 멘트
}
```

---

## 5. 데이터 모델 (SwiftData)

### 모델 정의
```swift
import SwiftData

// 1) 사용자 프로필 (단일 레코드)
@Model
final class UserProfile {
    var heightCm: Double?
    var updatedAt: Date

    init(heightCm: Double? = nil) {
        self.heightCm = heightCm
        self.updatedAt = .now
    }
}

// 2) 측정 세션 (정면+측면 1세트)
@Model
final class SessionRecord {
    var id: UUID
    var measuredAt: Date
    var frontImagePath: String
    var sideImagePath: String
    var heightCmAtMeasure: Double?    // 측정 시점 UserProfile.heightCm 값을 복사 (이력 추적용, 이후 프로필 키 변경되어도 과거 기록은 유지)

    @Relationship(deleteRule: .cascade, inverse: \PostureRecord.session)
    var postures: [PostureRecord]

    // 비대칭 결과
    var asymmetryShoulderCm: Double?
    var asymmetryShoulderRatio: Double
    var asymmetryShoulderDirection: AsymmetryDirection
    var asymmetryHipCm: Double?
    var asymmetryHipRatio: Double
    var asymmetryHipDirection: AsymmetryDirection
}

// 3) 개별 자세 판정 결과
@Model
final class PostureRecord {
    var id: UUID
    var typeRaw: String              // PostureType.rawValue
    var statusRaw: String            // PostureStatus.rawValue
    var primaryMetric: Double
    var primaryMetricUnit: String
    var confidence: Double
    var advice: String?

    var session: SessionRecord?
}

enum AsymmetryDirection: String, Codable {
    case leftHigher, rightHigher, balanced
}

enum PostureType: String, Codable, CaseIterable {
    case forwardHead
    case roundShoulder
    case kyphosis
    case anteriorPelvicTilt
    case kneeHyperextension
    case scoliosis
    case headTilt
    case kneeAlignment
}

enum PostureStatus: String, Codable {
    case normal, caution, suspect, unmeasurable
}
```

### 이미지 저장 정책
- **SwiftData에 이미지 자체 저장 X** (DB 비대화 방지)
- 앱 `Documents/sessions/<sessionID>/front.jpg`, `side.jpg`
- DB에는 상대 경로만
- `SessionRecord` 삭제 시 `ImageStore`가 같은 폴더 cascade 삭제

### `ImageStore` 인터페이스
```swift
final class ImageStore {
    func save(_ image: UIImage, for sessionID: UUID, view: SessionView) throws -> String
    func load(path: String) -> UIImage?
    func delete(for sessionID: UUID) throws
}
```

### 추이 그래프 쿼리 예
```swift
@Query(filter: #Predicate<PostureRecord> {
    $0.typeRaw == "forwardHead" &&
    $0.session?.measuredAt > someDate
}, sort: \.session?.measuredAt)
var records: [PostureRecord]
```

### 데이터 흐름
```
[측정 마법사] 사진 2장 + 키
       ↓
[AnalyzeSessionUseCase]
   PoseDetector × 2 → PoseFrame × 2
   Evaluator × 8 적용 → PostureResult × 8
   AsymmetryAnalyzer → AsymmetryResult
   → SessionReport (메모리 객체)
       ↓
[AnalysisResultView] 화면 표시 + "저장"
       ↓
[SessionRepository.save(report)]
   ImageStore → 파일 저장
   SwiftData → SessionRecord + PostureRecord × 8
```

### 마이그레이션
- 1차 MVP는 스키마 변경 없음 가정
- 2차 영상 분석: `MotionRecord` 별도 모델로 추가
- 향후 변경 대비 → `VersionedSchema` 사용 가능

---

## 6. 에러 처리 및 엣지케이스

### 권한 관련
| 상황 | 대응 |
|------|------|
| 카메라 권한 거부 | 안내 시트 → "설정 열기" 버튼 |
| 사진 라이브러리 권한 거부 | 동일 패턴, iOS 17 제한 모드도 지원 |
| Info.plist | `NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription` 한국어로 명시 |

### 사진 입력
| 상황 | 대응 |
|------|------|
| 사진 선택 취소 | 시트만 닫음, 마법사 상태 유지 |
| 카메라 불가 (시뮬레이터) | 카메라 버튼 비활성화 + 안내 문구 |
| 사진 너무 큼 | 분석용 2048px, 저장용 1024px로 다운샘플링 |
| EXIF 회전 메타데이터 | `VNImageRequestHandler(orientation:)`에 정확히 전달 |

### Vision 분석
| 상황 | 대응 |
|------|------|
| 사람 인식 안 됨 | "사람을 인식할 수 없습니다" 에러 + 다시 측정 |
| 사람 2명 이상 | bounding box 가장 큰 1명 선택 + "여러 명 감지" 토스트 |
| 전신 일부 잘림 | 필수 관절 confidence < 0.3 → 해당 자세 "측정 불가", 나머지는 분석 |
| 측면 사진이 아닐 가능성 | 측면 자세 5개 핵심 관절 신뢰도 낮음 → "측면 사진이 아닐 수 있습니다" 경고 |
| Vision 에러 | try-catch → 에러 화면 + 다시 시도 |
| 분석 3초 초과 | 로딩 인디케이터 강조 |

### 비대칭 분석
| 상황 | 대응 |
|------|------|
| 정면인데 살짝 옆 | 양 어깨/엉덩이 X 좌표 차이 비율로 자동 감지 → 경고 |
| 키 미입력 | cm 생략, "어깨너비의 X%" fallback |
| 키 비현실적 값 | 50~250cm 범위 validation |

### 저장
| 상황 | 대응 |
|------|------|
| 저장 실패 (디스크 가득) | 토스트 + 재시도, 메모리 결과 유지 |
| SwiftData write 실패 | 에러 로그 + 알림, 사진 파일 정리 |
| 백그라운드 진입 | 수 초 작업이라 iOS 처리 보장 |

### 히스토리/추이
| 상황 | 대응 |
|------|------|
| 기록 0개 | empty state + "측정 시작" 버튼 |
| 추이 데이터 1개 | 그래프 대신 "측정을 더 진행해주세요" |
| 사진 파일 누락 | 썸네일 placeholder, 결과 데이터 유지 |
| 기록 삭제 | 확인 alert + cascade 삭제 |

### 메모리 & 성능
| 항목 | 대응 |
|------|------|
| 큰 사진 메모리 | 다운샘플링 (분석 2048px / 저장 1024px) |
| 분석 백그라운드 | `Task.detached`, View는 `@MainActor` |
| 동시 다중 호출 | ViewModel `isAnalyzing` 플래그 lock |
| 히스토리 리스트 | `@Query` 페이징 + 썸네일 lazy load |

### 접근성
| 항목 | 대응 |
|------|------|
| VoiceOver | 인터랙티브 요소에 한국어 label/hint |
| 다크 모드 | 시스템 기본 (Asset Catalog appearance) |
| Dynamic Type | SwiftUI 기본 텍스트 자동 대응 |
| 색맹 | 색만 의존하지 않고 아이콘+텍스트 병기 |

### 로깅
- `os.Logger` 사용 (subsystem: `com.pose.poseanalyzer`)
- 카테고리: `vision`, `analysis`, `persistence`, `ui`
- 분석 실패/측정 불가 케이스 로그
- 개인정보(좌표·사진) 로그 X

---

## 7. 테스트 전략

### 레이어 구성
```
UI Tests          (PoseAnalyzerUITests)   ← 최소, 핵심 흐름 3-5개
ViewModel Tests                            ← Mock UseCase 주입
Domain Tests      (PoseAnalyzerTests)      ← 핵심, 가장 많이 작성
Repository Tests                           ← in-memory SwiftData
```

### Evaluator 단위 테스트 (가장 중요)
8개 자세 각각에 대해 정상/경계/심각/측정불가 4개 케이스 기본:
```swift
func test_정상_자세_각도_175도_normal_반환() { ... }
func test_경계_각도_165도_caution_반환() { ... }
func test_심각_각도_150도_suspect_반환() { ... }
func test_관절_신뢰도_낮음_unmeasurable_반환() { ... }
```
Vision 의존 X. `PoseFrame` fixture 직접 주입.

### `PoseFrame` Fixture 패턴
```swift
extension PoseFrame {
    static func mock(ear: CGPoint, shoulder: CGPoint, hip: CGPoint, confidence: Double) -> PoseFrame
    static func mockSideView(forwardHeadAngle: Double) -> PoseFrame  // 각도 지정 헬퍼
}
```

### GeometryMath 테스트
순수 함수 — 가장 단단하게 테스트:
- 직선 세 점 → 180°
- 직각 세 점 → 90°
- 벡터 기울기 계산

### AsymmetryAnalyzer 테스트
- 어깨 같은 높이 → balanced
- 우측 어깨 5px 높음 → rightHigher + 정확한 비율
- 키 입력 시 cm 환산 정확도

### Repository 테스트
SwiftData `ModelConfiguration(isStoredInMemoryOnly: true)`로 격리.
- 저장 → 조회 round-trip
- cascade 삭제 검증
- `ImageStore`는 임시 디렉토리 사용

### ViewModel 테스트
Mock `AnalyzeSessionUseCase` 주입.
- 정상 응답 → `.result(report)` 상태
- 에러 응답 → `.error(message)` 상태
- 분석 중 `isAnalyzing = true`

### Vision 통합 테스트 (smoke 수준)
실제 Vision 호출 1-2개:
- 번들 mock 사진 (정상 정면/측면 각 1장)
- `VisionPoseDetector.detect(image:)` → 관절 confidence 임계값 이상 반환
- 과도하게 많이 만들지 않음 (CI 느려지고 깨지기 쉬움)

### UI 테스트 (최소)
- "측정 시작 → 사진 선택 → 키 입력 → 결과 도달"
- "기록 진입 → 항목 탭 → 상세"
- "기록 삭제 → 리스트에서 사라짐"

### Fixture 디렉토리
```
PoseAnalyzerTests/
└── Fixtures/
    ├── poses/        (mock PoseFrame JSON)
    └── images/       (Vision 통합용 실제 사진)
```

### CI / 자동화
- MVP: Xcode 로컬 ⌘U
- 향후 GitHub Actions 고려 (외부 의존성 0개라 쉬움)

### 커버리지 목표 (가이드)
| 레이어 | 목표 |
|------|------|
| Domain (Evaluator, Asymmetry, GeometryMath) | 80%+ |
| ViewModel | 60%+ |
| Repository | 70%+ |
| Presentation/UI | 핵심 흐름 커버 |

### TDD 권장 범위
- **핵심 로직(Evaluator, GeometryMath)**: TDD — 임계값/각도 명확
- UI/ViewModel: 구현 후 테스트 추가 OK

---

## 8. 1차 MVP 완료 정의

다음이 모두 작동하면 MVP 완료:

1. 카메라 또는 사진 라이브러리에서 정면·측면 사진 2장 입력
2. 키 입력 (선택, 한 번 입력하면 유지)
3. Vision으로 관절 인식 → 8개 자세 자동 판정 + 비대칭 분석
4. 결과 화면에 사진 + 관절 오버레이 + 8개 판정 카드 + 좌우 비대칭 + 직전 대비 변화 표시
5. 저장 → SwiftData + 이미지 파일
6. 기록 탭에서 시간 역순 리스트, 항목 탭 시 결과 상세
7. 추이 그래프 (자세별 시간축, Swift Charts)
8. 권한 거부·사람 미인식·측정 불가 등 주요 에러 처리
9. Evaluator 단위 테스트 + Repository 테스트 통과

---

## 9. 향후(2차 이후) 확장 계획

- **영상 기반 동적 자세 분석**: 스쿼트 깊이/속도, 러닝 보폭/케이던스 등
- 새 모듈 `Motion/` 활용, `MotionAnalyzer` 프로토콜 구현체 추가
- 실시간 카메라 프레임 처리 파이프라인 (`AVCaptureSession` + Vision Sequence)
- 임계값 사용자 튜닝 UI (설정 화면 확장)
- 알림 (정기 측정 리마인더)
- iCloud 동기화 (선택)
- 코드 누적 시점에 SPM 모듈 분리 (C 아키텍처로 이행)

---

## 10. 결정 요약 (사용자 승인 사항)

| 항목 | 결정 |
|------|------|
| 프로젝트 형태 | 신규 iOS 프로젝트 (마스터프로젝트 하위 `PoseAnalyzer/`) |
| Bundle ID | `com.pose.poseanalyzer` |
| 최소 OS | iOS 17.0 |
| 외부 라이브러리 | 없음 (Apple 표준만) |
| 사진 입력 | 카메라 + 라이브러리 둘 다 |
| 사진 장수 | 2장 (정면 + 측면) |
| 자세 종류 | 8개 (거북목, 라운드숄더, 흉추후만, 골반전방경사, 무릎과신전, 척추측만, 머리좌우기울기, 무릎X자/O자) |
| 자동 종합 판정 | 사용자가 자세 선택하지 않고 AI가 일괄 분석 |
| 결과 표시 | 관절 오버레이 + 판정 + 각도 수치 + 좌우 비대칭 + 직전 대비 변화 |
| 판정 단계 | 정상 / 주의 / 의심 / 측정 불가 (4단계) |
| 키 입력 | Step 3로 추가, 한 번 입력하면 유지, 결과·설정에서 변경 |
| 키 환산 | 옵션 C 혼합 (입력 시 cm, 미입력 시 어깨너비 비율) |
| 키 validation | 50~250cm |
| 히스토리 | 사진 + 결과 + 추이 그래프 (Swift Charts) |
| 아키텍처 | B+ (MVVM + 프로토콜 기반 분석 도메인) |
| 영상 분석 | 1차 인터페이스만, 2차 구현 |
| TDD 적용 | 핵심 로직(Evaluator, GeometryMath)에 권장 |
