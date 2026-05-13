# PoseAnalyzer Foundation 구현 계획 (Plan 1/2)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Apple Vision 기반 자세 분석 앱의 비즈니스 로직 토대 구축 — Xcode 프로젝트 셋업, 도메인 모델, 8개 자세 판정 Evaluator, 비대칭 분석, UseCase, SwiftData 저장소까지 모두 단위테스트로 검증되는 상태.

**Architecture:** MVVM + 프로토콜 기반 분석 도메인 (B+ 아키텍처). `PoseDetector`, `PostureEvaluator`, `AsymmetryAnalyzer`, `MotionAnalyzer` 프로토콜로 각 책임을 분리해서 향후 영상 분석 확장과 알고리즘 교체에 대비.

**Tech Stack:** Swift 5.9+, SwiftUI, iOS 17.0+, Vision Framework, SwiftData, Swift Charts, AVFoundation, PhotosUI — 외부 라이브러리 0개

**선행 문서:** `docs/specs/2026-05-13-pose-analyzer-design.md`

**완료 후 상태:** 앱이 컴파일되고 모든 단위테스트가 통과. UI는 아직 빈 상태 (Plan 2에서 작성). 도메인 로직과 데이터 저장소가 완전히 검증된 상태.

---

## 사전 준비

- 작업 디렉토리: `/Users/byunggyusong/1_개발폴더/마스터프로젝트/PoseAnalyzer/`
- 마스터프로젝트는 git 저장소가 아니므로 PoseAnalyzer 폴더에서 git init 수행 (Task 1)
- 한국어 주석 사용 (RULES.md 준수)

---

## Phase 1: 프로젝트 셋업

### Task 1: Xcode 프로젝트 생성 및 git 초기화

**파일/경로:**
- 생성: `/Users/byunggyusong/1_개발폴더/마스터프로젝트/PoseAnalyzer/PoseAnalyzer.xcodeproj`
- 생성: `/Users/byunggyusong/1_개발폴더/마스터프로젝트/PoseAnalyzer/.gitignore`

- [ ] **Step 1: Xcode에서 새 프로젝트 생성**

Xcode 열기 → File → New → Project → iOS → App → Next. 다음 값으로 채움:

| 필드 | 값 |
|------|------|
| Product Name | `PoseAnalyzer` |
| Team | (개발자 본인 Apple ID) |
| Organization Identifier | `com.pose` |
| Bundle Identifier (자동) | `com.pose.PoseAnalyzer` (대문자 P는 다음 step에서 변경) |
| Interface | SwiftUI |
| Language | Swift |
| Storage | **SwiftData** |
| Include Tests | ✅ 체크 |

저장 위치: `/Users/byunggyusong/1_개발폴더/마스터프로젝트/PoseAnalyzer/`
"Create Git repository on my Mac" 체크.

- [ ] **Step 2: Bundle Identifier 소문자로 변경**

프로젝트 네비게이터 → PoseAnalyzer (Project) → TARGETS: PoseAnalyzer → Signing & Capabilities → Bundle Identifier를 `com.pose.poseanalyzer` 로 변경.

- [ ] **Step 3: Deployment Target 확인**

TARGETS: PoseAnalyzer → General → Minimum Deployments → iOS 17.0 으로 설정.

- [ ] **Step 4: .gitignore 작성**

`PoseAnalyzer/.gitignore` 파일 내용:

```gitignore
# Xcode
build/
DerivedData/
*.xcuserstate
xcuserdata/
*.xcscmblueprint
*.xccheckout
*.moved-aside
*.hmap
*.ipa
*.dSYM.zip
*.dSYM

# macOS
.DS_Store

# Swift Package Manager
.swiftpm/
Packages/
Package.pins
Package.resolved

# CocoaPods (사용 안 함)
Pods/

# fastlane (사용 안 함)
fastlane/report.xml
fastlane/screenshots
```

- [ ] **Step 5: 빌드 확인**

Xcode 단축키 `⌘B` (Product → Build). 기본 템플릿이 컴파일 성공해야 함.

- [ ] **Step 6: 시뮬레이터에서 실행 확인**

`⌘R` (Product → Run). iPhone 15 등 임의의 시뮬레이터에서 빈 화면 또는 기본 SwiftData 템플릿 화면이 뜨면 OK.

- [ ] **Step 7: 첫 commit**

Xcode Source Control → Commit (또는 터미널):

```bash
cd "/Users/byunggyusong/1_개발폴더/마스터프로젝트/PoseAnalyzer"
git add .
git commit -m "chore: initial Xcode project setup"
```

---

### Task 2: 폴더 구조 생성 및 Info.plist 권한 키 추가

**파일/경로:**
- 생성: Xcode 그룹 폴더 (Domain/, Data/, Presentation/, Support/, Resources/)
- 수정: `PoseAnalyzer/Info.plist` (또는 프로젝트 설정의 Info 탭)

- [ ] **Step 1: Xcode에서 그룹 폴더 생성 (디스크에도 반영)**

PoseAnalyzer 그룹 우클릭 → New Group with Folder → 다음 그룹들을 차례로 생성:
- `App`
- `Domain`
  - 하위에 `Models`, `Detection`, `Evaluation`, `Asymmetry`, `Motion`, `UseCase`
- `Data`
  - 하위에 `SwiftData`
- `Presentation`
  - 하위에 `Home`, `Measurement`, `Result`, `History`, `Settings`, `Common`
- `Resources`
- `Support`
  - 하위에 `Extensions`, `Utils`

**중요:** "Group" 만이 아니라 "Group with Folder" (실제 디스크 폴더 생성). Xcode 16+에서는 기본이 그룹+폴더.

- [ ] **Step 2: 기본 생성된 파일들 이동**

`PoseAnalyzerApp.swift`, `ContentView.swift`, `Item.swift` (SwiftData 템플릿) → 임시 그대로 두고 Task 3 이후 제거/수정.

- [ ] **Step 3: Info.plist 권한 키 추가**

TARGETS: PoseAnalyzer → Info → Custom iOS Target Properties 에 다음 키 추가:

| Key | Type | Value |
|------|------|-------|
| `NSCameraUsageDescription` | String | `자세 사진을 촬영하기 위해 카메라를 사용합니다.` |
| `NSPhotoLibraryUsageDescription` | String | `자세 분석을 위해 사진을 불러옵니다.` |
| `NSPhotoLibraryAddUsageDescription` | String | `측정한 사진을 저장하기 위해 사용합니다.` |

- [ ] **Step 4: 빌드 확인**

`⌘B`. 빌드 성공.

- [ ] **Step 5: commit**

```bash
git add .
git commit -m "chore: add folder structure and permission keys"
```

---

## Phase 2: 기본 도메인 모델

### Task 3: SessionView, PostureType, PostureStatus enum 정의

**파일/경로:**
- 생성: `PoseAnalyzer/Domain/Models/SessionView.swift`
- 생성: `PoseAnalyzer/Domain/Models/PostureType.swift`
- 생성: `PoseAnalyzer/Domain/Models/PostureStatus.swift`

- [ ] **Step 1: SessionView.swift 작성**

```swift
import Foundation

/// 사진의 촬영 시점 시점 (정면 / 측면)
enum SessionView: String, Codable, CaseIterable {
    case front  // 정면
    case side   // 측면
    
    var koreanName: String {
        switch self {
        case .front: return "정면"
        case .side: return "측면"
        }
    }
}
```

- [ ] **Step 2: PostureType.swift 작성**

```swift
import Foundation

/// 판정 가능한 자세 종류 (MVP 8개)
enum PostureType: String, Codable, CaseIterable {
    case forwardHead         // 거북목
    case roundShoulder       // 라운드숄더
    case kyphosis            // 흉추 후만증
    case anteriorPelvicTilt  // 골반 전방경사
    case kneeHyperextension  // 무릎 과신전
    case scoliosis           // 척추측만
    case headTilt            // 머리 좌우 기울기
    case kneeAlignment       // 무릎 X자/O자
    
    var koreanName: String {
        switch self {
        case .forwardHead: return "거북목"
        case .roundShoulder: return "라운드숄더"
        case .kyphosis: return "흉추 후만증"
        case .anteriorPelvicTilt: return "골반 전방경사"
        case .kneeHyperextension: return "무릎 과신전"
        case .scoliosis: return "척추측만"
        case .headTilt: return "머리 좌우 기울기"
        case .kneeAlignment: return "무릎 X/O자"
        }
    }
    
    var requiredView: SessionView {
        switch self {
        case .forwardHead, .roundShoulder, .kyphosis,
             .anteriorPelvicTilt, .kneeHyperextension:
            return .side
        case .scoliosis, .headTilt, .kneeAlignment:
            return .front
        }
    }
}
```

- [ ] **Step 3: PostureStatus.swift 작성**

```swift
import Foundation

/// 판정 결과 상태 (4단계)
enum PostureStatus: String, Codable {
    case normal         // 정상 🟢
    case caution        // 주의 🟡
    case suspect        // 의심 🟠
    case unmeasurable   // 측정 불가 ⚪
    
    var koreanName: String {
        switch self {
        case .normal: return "정상"
        case .caution: return "주의"
        case .suspect: return "의심"
        case .unmeasurable: return "측정 불가"
        }
    }
}
```

- [ ] **Step 4: 빌드 확인 후 commit**

```bash
git add Domain/Models/
git commit -m "feat(domain): add SessionView, PostureType, PostureStatus enums"
```

---

### Task 4: PoseFrame 모델 (관절 좌표 컬렉션)

**파일/경로:**
- 생성: `PoseAnalyzer/Domain/Models/PoseFrame.swift`

- [ ] **Step 1: PoseFrame.swift 작성**

```swift
import CoreGraphics
import Vision

/// 한 장의 사진에서 추출된 관절 좌표 묶음
struct PoseFrame: Equatable {
    /// 관절 1개 정보
    struct Joint: Equatable {
        let name: VNHumanBodyPoseObservation.JointName
        let location: CGPoint    // 정규화 좌표 (0~1, Vision은 좌하단 원점)
        let confidence: Float
    }
    
    /// 관절명 → Joint
    let joints: [VNHumanBodyPoseObservation.JointName: Joint]
    
    /// 어느 시점(정면/측면)의 사진인지
    let view: SessionView
    
    /// 사진 크기 (오버레이 좌표 변환용)
    let imageSize: CGSize
    
    /// 특정 관절의 신뢰도가 임계값 이상인지 확인
    func isReliable(_ name: VNHumanBodyPoseObservation.JointName, threshold: Float = 0.3) -> Bool {
        guard let joint = joints[name] else { return false }
        return joint.confidence >= threshold
    }
    
    /// 여러 관절이 모두 신뢰 가능한지
    func areReliable(_ names: [VNHumanBodyPoseObservation.JointName], threshold: Float = 0.3) -> Bool {
        return names.allSatisfy { isReliable($0, threshold: threshold) }
    }
    
    /// 관절 좌표 반환 (신뢰도 무관)
    func point(_ name: VNHumanBodyPoseObservation.JointName) -> CGPoint? {
        joints[name]?.location
    }
    
    /// 평균 신뢰도 계산
    func averageConfidence(_ names: [VNHumanBodyPoseObservation.JointName]) -> Double {
        let validJoints = names.compactMap { joints[$0] }
        guard !validJoints.isEmpty else { return 0 }
        let sum = validJoints.map { Double($0.confidence) }.reduce(0, +)
        return sum / Double(validJoints.count)
    }
}
```

- [ ] **Step 2: 빌드 확인 후 commit**

```bash
git add Domain/Models/PoseFrame.swift
git commit -m "feat(domain): add PoseFrame model with joint reliability checks"
```

---

### Task 5: Thresholds, PostureResult, AsymmetryResult, SessionReport 정의

**파일/경로:**
- 생성: `PoseAnalyzer/Domain/Models/Thresholds.swift`
- 생성: `PoseAnalyzer/Domain/Models/PostureResult.swift`
- 생성: `PoseAnalyzer/Domain/Models/AsymmetryResult.swift`
- 생성: `PoseAnalyzer/Domain/Models/SessionReport.swift`

- [ ] **Step 1: Thresholds.swift 작성**

```swift
import Foundation

/// 자세 판정 임계값
/// - 단일 값 기준 (각도, 비율 등)
/// - 범위 기준 (예: 무릎 과신전은 175-185 정상, 185-190 주의, >190 의심)
struct Thresholds: Equatable {
    /// 정상 범위 (이 안에 들면 normal)
    let normalRange: ClosedRange<Double>
    /// 주의 범위 (정상 바깥, 의심보다 약한 범위)
    let cautionRange: ClosedRange<Double>?
    /// 평가 방향 (값이 클수록 좋은지, 작을수록 좋은지, 또는 정상범위에서 멀수록 나쁜지)
    let direction: Direction
    
    enum Direction: Equatable {
        case higherIsNormal     // 값이 클수록 정상 (예: 거북목 각도, 175°↑)
        case lowerIsNormal      // 값이 작을수록 정상 (예: 어깨 기울기, <2°)
        case centeredOnRange    // 정상 범위 안이면 정상, 바깥은 멀수록 나쁨 (예: 무릎 과신전)
    }
    
    /// 측정값을 평가하여 PostureStatus 반환
    func evaluate(_ value: Double) -> PostureStatus {
        if normalRange.contains(value) {
            return .normal
        }
        if let caution = cautionRange, caution.contains(value) {
            return .caution
        }
        return .suspect
    }
}
```

- [ ] **Step 2: PostureResult.swift 작성**

```swift
import Foundation
import Vision

/// 단일 자세 판정 결과
struct PostureResult: Equatable {
    let type: PostureType
    let status: PostureStatus
    let primaryMetric: Double              // 핵심 수치 (각도 또는 비율)
    let primaryMetricUnit: MetricUnit
    let thresholds: Thresholds
    let usedJointNames: [String]           // 디버그·이력용 (raw name)
    let confidence: Double                 // 사용 관절 평균 신뢰도 (0~1)
    let advice: String?                    // 간단한 권장 멘트
    
    enum MetricUnit: String, Codable {
        case degree     // 도
        case ratio      // 비율 (0~1)
        case centimeter // cm
        
        var symbol: String {
            switch self {
            case .degree: return "°"
            case .ratio: return ""
            case .centimeter: return "cm"
            }
        }
    }
    
    /// 측정 불가 결과 생성 헬퍼
    static func unmeasurable(type: PostureType, reason: String) -> PostureResult {
        PostureResult(
            type: type,
            status: .unmeasurable,
            primaryMetric: 0,
            primaryMetricUnit: .degree,
            thresholds: Thresholds(normalRange: 0...0, cautionRange: nil, direction: .higherIsNormal),
            usedJointNames: [],
            confidence: 0,
            advice: reason
        )
    }
}
```

- [ ] **Step 3: AsymmetryResult.swift 작성**

```swift
import Foundation

/// 정면 사진 기반 좌우 비대칭 분석 결과
struct AsymmetryResult: Equatable {
    let shoulder: Difference
    let hip: Difference
    
    struct Difference: Equatable {
        let cm: Double?              // 키 입력 있을 때 cm
        let ratio: Double            // 어깨너비 대비 비율 (항상 계산)
        let angleDegrees: Double     // 기울기 (도)
        let direction: Direction
    }
    
    enum Direction: String, Codable {
        case leftHigher
        case rightHigher
        case balanced
        
        var koreanName: String {
            switch self {
            case .leftHigher: return "왼쪽이 높음"
            case .rightHigher: return "오른쪽이 높음"
            case .balanced: return "균형"
            }
        }
    }
}
```

- [ ] **Step 4: SessionReport.swift 작성**

```swift
import Foundation
import UIKit

/// 한 세션의 모든 분석 결과를 묶은 메모리 객체 (저장 전 단계)
struct SessionReport: Equatable {
    let id: UUID
    let measuredAt: Date
    let frontImage: UIImage
    let sideImage: UIImage
    let frontFrame: PoseFrame
    let sideFrame: PoseFrame
    let postures: [PostureResult]    // 8개 (자세 종류별)
    let asymmetry: AsymmetryResult
    let heightCmAtMeasure: Double?
    
    /// 특정 자세 결과 조회
    func posture(of type: PostureType) -> PostureResult? {
        postures.first { $0.type == type }
    }
    
    static func == (lhs: SessionReport, rhs: SessionReport) -> Bool {
        lhs.id == rhs.id &&
        lhs.measuredAt == rhs.measuredAt &&
        lhs.postures == rhs.postures &&
        lhs.asymmetry == rhs.asymmetry &&
        lhs.heightCmAtMeasure == rhs.heightCmAtMeasure
        // UIImage, PoseFrame은 비교 생략 (id로 충분)
    }
}
```

- [ ] **Step 5: 빌드 확인 후 commit**

```bash
git add Domain/Models/
git commit -m "feat(domain): add Thresholds, PostureResult, AsymmetryResult, SessionReport"
```

---

## Phase 3: 기하 유틸 (TDD)

### Task 6: GeometryMath 유틸 — 각도/거리/기울기 계산

**파일/경로:**
- 생성: `PoseAnalyzer/Support/Utils/GeometryMath.swift`
- 생성: `PoseAnalyzerTests/GeometryMathTests.swift`

- [ ] **Step 1: 실패하는 테스트 먼저 작성 (TDD)**

`PoseAnalyzerTests/GeometryMathTests.swift`:

```swift
import XCTest
@testable import PoseAnalyzer

final class GeometryMathTests: XCTestCase {
    
    // MARK: - angleBetween (세 점이 이루는 각도)
    
    func test_세점이_직선이면_각도는_180도() {
        let p1 = CGPoint(x: 0, y: 0)
        let v = CGPoint(x: 1, y: 0)
        let p2 = CGPoint(x: 2, y: 0)
        let angle = GeometryMath.angleBetween(p1: p1, vertex: v, p2: p2)
        XCTAssertEqual(angle, 180, accuracy: 0.01)
    }
    
    func test_세점이_직각이면_각도는_90도() {
        let p1 = CGPoint(x: 0, y: 1)
        let v = CGPoint(x: 0, y: 0)
        let p2 = CGPoint(x: 1, y: 0)
        let angle = GeometryMath.angleBetween(p1: p1, vertex: v, p2: p2)
        XCTAssertEqual(angle, 90, accuracy: 0.01)
    }
    
    func test_세점이_겹치면_NaN_또는_0_반환() {
        let p1 = CGPoint(x: 0, y: 0)
        let v = CGPoint(x: 0, y: 0)
        let p2 = CGPoint(x: 1, y: 0)
        let angle = GeometryMath.angleBetween(p1: p1, vertex: v, p2: p2)
        // 분모 0이라 NaN/Inf 가능 — 함수는 0 반환하도록 설계
        XCTAssertTrue(angle.isFinite, "유한 값이어야 함")
    }
    
    // MARK: - distance (두 점 사이 거리)
    
    func test_같은_점_사이_거리는_0() {
        let d = GeometryMath.distance(CGPoint(x: 5, y: 5), CGPoint(x: 5, y: 5))
        XCTAssertEqual(d, 0, accuracy: 0.01)
    }
    
    func test_345_피타고라스_거리는_5() {
        let d = GeometryMath.distance(CGPoint(x: 0, y: 0), CGPoint(x: 3, y: 4))
        XCTAssertEqual(d, 5, accuracy: 0.01)
    }
    
    // MARK: - lineAngle (수평 대비 두 점이 만드는 직선의 기울기 각도)
    
    func test_수평_직선_기울기는_0도() {
        let angle = GeometryMath.lineAngleFromHorizontal(
            CGPoint(x: 0, y: 5), CGPoint(x: 10, y: 5)
        )
        XCTAssertEqual(angle, 0, accuracy: 0.01)
    }
    
    func test_수직_직선_기울기는_90도() {
        let angle = GeometryMath.lineAngleFromHorizontal(
            CGPoint(x: 5, y: 0), CGPoint(x: 5, y: 10)
        )
        XCTAssertEqual(abs(angle), 90, accuracy: 0.01)
    }
    
    func test_우측이_높은_45도_기울기() {
        // Vision 좌표계: 좌하단 원점, Y 위로 갈수록 증가
        let angle = GeometryMath.lineAngleFromHorizontal(
            CGPoint(x: 0, y: 0), CGPoint(x: 10, y: 10)
        )
        XCTAssertEqual(angle, 45, accuracy: 0.01)
    }
    
    // MARK: - horizontalGapRatio (어깨-귀 같은 수평 거리 비율 계산)
    
    func test_수평_거리_비율() {
        // 어깨와 귀가 수평으로 5만큼, 어깨 폭이 20이면 비율 0.25
        let ratio = GeometryMath.horizontalGapRatio(
            from: CGPoint(x: 5, y: 0),  // 귀
            to: CGPoint(x: 0, y: 0),    // 어깨
            referenceWidth: 20
        )
        XCTAssertEqual(ratio, 0.25, accuracy: 0.01)
    }
}
```

- [ ] **Step 2: 테스트 실행하여 실패 확인**

Xcode `⌘U` 또는 터미널에서:
```bash
xcodebuild test -project PoseAnalyzer.xcodeproj -scheme PoseAnalyzer -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:PoseAnalyzerTests/GeometryMathTests 2>&1 | tail -30
```
예상 결과: `GeometryMath` 타입 없음 컴파일 에러 → FAIL.

- [ ] **Step 3: GeometryMath.swift 구현**

```swift
import CoreGraphics
import Foundation

/// 관절 좌표 기반 기하 계산 유틸 (순수 함수 모음)
enum GeometryMath {
    
    /// 세 점이 이루는 각도 (vertex를 중심으로 한 ∠p1·vertex·p2). 단위: 도
    /// 분모가 0인 경우 0 반환 (NaN 방지).
    static func angleBetween(p1: CGPoint, vertex: CGPoint, p2: CGPoint) -> Double {
        let v1 = CGVector(dx: p1.x - vertex.x, dy: p1.y - vertex.y)
        let v2 = CGVector(dx: p2.x - vertex.x, dy: p2.y - vertex.y)
        let dot = Double(v1.dx * v2.dx + v1.dy * v2.dy)
        let mag1 = sqrt(Double(v1.dx * v1.dx + v1.dy * v1.dy))
        let mag2 = sqrt(Double(v2.dx * v2.dx + v2.dy * v2.dy))
        guard mag1 > 0, mag2 > 0 else { return 0 }
        var cosTheta = dot / (mag1 * mag2)
        cosTheta = max(-1, min(1, cosTheta))  // acos 범위 보호
        return acos(cosTheta) * 180 / .pi
    }
    
    /// 두 점 사이 유클리드 거리
    static func distance(_ a: CGPoint, _ b: CGPoint) -> Double {
        let dx = Double(a.x - b.x)
        let dy = Double(a.y - b.y)
        return sqrt(dx * dx + dy * dy)
    }
    
    /// 수평선 대비 두 점을 잇는 직선의 기울기 각도 (도). 양수 = 두번째 점이 위.
    /// 결과 범위: -90 ~ 90
    static func lineAngleFromHorizontal(_ a: CGPoint, _ b: CGPoint) -> Double {
        let dx = Double(b.x - a.x)
        let dy = Double(b.y - a.y)
        return atan2(dy, dx) * 180 / .pi
    }
    
    /// 두 점의 수평(X축) 거리 / 기준 폭 비율 (절댓값)
    static func horizontalGapRatio(from a: CGPoint, to b: CGPoint, referenceWidth: Double) -> Double {
        guard referenceWidth > 0 else { return 0 }
        return abs(Double(a.x - b.x)) / referenceWidth
    }
    
    /// 두 점 잇는 직선의 수평 대비 기울기 (절댓값, 도). 항상 0~90.
    static func absLineAngleFromHorizontal(_ a: CGPoint, _ b: CGPoint) -> Double {
        return abs(lineAngleFromHorizontal(a, b))
    }
}
```

- [ ] **Step 4: 테스트 재실행하여 통과 확인**

`⌘U`. 모든 테스트 통과해야 함.

- [ ] **Step 5: commit**

```bash
git add Support/Utils/GeometryMath.swift PoseAnalyzerTests/GeometryMathTests.swift
git commit -m "feat(utils): add GeometryMath with angle/distance/slope helpers (TDD)"
```

---

## Phase 4: Pose 검출

### Task 7: PoseDetector 프로토콜 정의

**파일/경로:**
- 생성: `PoseAnalyzer/Domain/Detection/PoseDetector.swift`

- [ ] **Step 1: PoseDetector.swift 작성**

```swift
import UIKit

/// 사진 또는 영상 프레임에서 사람 관절을 검출하는 책임
protocol PoseDetector {
    /// 단일 사진에서 PoseFrame 추출
    /// - Parameters:
    ///   - image: 분석할 사진
    ///   - view: 정면/측면 (PoseFrame에 메타로 들어감)
    /// - Throws: `PoseDetectionError`
    func detect(image: UIImage, view: SessionView) async throws -> PoseFrame
}

/// PoseDetector가 던질 수 있는 에러
enum PoseDetectionError: LocalizedError, Equatable {
    case noPersonDetected
    case multiplePersonsDetected(count: Int)
    case visionFailed(message: String)
    case invalidImage
    
    var errorDescription: String? {
        switch self {
        case .noPersonDetected:
            return "사람을 인식할 수 없습니다."
        case .multiplePersonsDetected(let n):
            return "여러 명(\(n)명)이 감지되었습니다. 한 명만 보이는 사진을 사용해주세요."
        case .visionFailed(let msg):
            return "분석 중 오류가 발생했습니다: \(msg)"
        case .invalidImage:
            return "사진 형식이 올바르지 않습니다."
        }
    }
}
```

- [ ] **Step 2: 빌드 확인 후 commit**

```bash
git add Domain/Detection/PoseDetector.swift
git commit -m "feat(detection): define PoseDetector protocol and error types"
```

---

### Task 8: VisionPoseDetector 구현 (Apple Vision)

**파일/경로:**
- 생성: `PoseAnalyzer/Domain/Detection/VisionPoseDetector.swift`

- [ ] **Step 1: VisionPoseDetector.swift 작성**

```swift
import UIKit
import Vision

/// Apple Vision Framework 기반 PoseDetector 구현
final class VisionPoseDetector: PoseDetector {
    
    func detect(image: UIImage, view: SessionView) async throws -> PoseFrame {
        guard let cgImage = image.cgImage else {
            throw PoseDetectionError.invalidImage
        }
        let orientation = CGImagePropertyOrientation(image.imageOrientation)
        
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNDetectHumanBodyPoseRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: PoseDetectionError.visionFailed(message: error.localizedDescription))
                    return
                }
                
                guard let observations = request.results as? [VNHumanBodyPoseObservation],
                      !observations.isEmpty else {
                    continuation.resume(throwing: PoseDetectionError.noPersonDetected)
                    return
                }
                
                // 여러 명이면 bounding box 가장 큰 1명 선택 (스펙)
                let chosen: VNHumanBodyPoseObservation
                if observations.count == 1 {
                    chosen = observations[0]
                } else {
                    chosen = observations.max(by: { lhs, rhs in
                        let lhsArea = lhs.boundingBox.width * lhs.boundingBox.height
                        let rhsArea = rhs.boundingBox.width * rhs.boundingBox.height
                        return lhsArea < rhsArea
                    })!
                }
                
                do {
                    let frame = try Self.makeFrame(
                        from: chosen, view: view, imageSize: image.size
                    )
                    continuation.resume(returning: frame)
                } catch {
                    continuation.resume(throwing: PoseDetectionError.visionFailed(message: "관절 추출 실패: \(error.localizedDescription)"))
                }
            }
            
            let handler = VNImageRequestHandler(cgImage: cgImage, orientation: orientation, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: PoseDetectionError.visionFailed(message: error.localizedDescription))
            }
        }
    }
    
    private static func makeFrame(
        from observation: VNHumanBodyPoseObservation,
        view: SessionView,
        imageSize: CGSize
    ) throws -> PoseFrame {
        let recognized = try observation.recognizedPoints(.all)
        var joints: [VNHumanBodyPoseObservation.JointName: PoseFrame.Joint] = [:]
        
        for (name, point) in recognized {
            // Vision은 정규화 좌표 (0~1, 좌하단 원점) 반환
            joints[name] = PoseFrame.Joint(
                name: name,
                location: point.location,
                confidence: point.confidence
            )
        }
        
        return PoseFrame(joints: joints, view: view, imageSize: imageSize)
    }
}

// MARK: - CGImagePropertyOrientation Helper

private extension CGImagePropertyOrientation {
    init(_ uiOrientation: UIImage.Orientation) {
        switch uiOrientation {
        case .up: self = .up
        case .upMirrored: self = .upMirrored
        case .down: self = .down
        case .downMirrored: self = .downMirrored
        case .left: self = .left
        case .leftMirrored: self = .leftMirrored
        case .right: self = .right
        case .rightMirrored: self = .rightMirrored
        @unknown default: self = .up
        }
    }
}
```

- [ ] **Step 2: 빌드 확인 후 commit**

```bash
git add Domain/Detection/VisionPoseDetector.swift
git commit -m "feat(detection): implement VisionPoseDetector using VNDetectHumanBodyPoseRequest"
```

---

## Phase 5: PostureEvaluator 프로토콜 & PoseFrame Fixture

### Task 9: PostureEvaluator 프로토콜 + 테스트 헬퍼

**파일/경로:**
- 생성: `PoseAnalyzer/Domain/Evaluation/PostureEvaluator.swift`
- 생성: `PoseAnalyzerTests/Helpers/PoseFrameFixtures.swift`

- [ ] **Step 1: PostureEvaluator.swift 작성**

```swift
import Foundation

/// 단일 자세를 평가하는 책임
protocol PostureEvaluator {
    /// 어떤 자세를 판정하는지
    var type: PostureType { get }
    /// 어느 시점(정면/측면) 사진에 적용해야 하는지
    var requiredView: SessionView { get }
    /// 평가 실행
    func evaluate(_ frame: PoseFrame) -> PostureResult
}
```

- [ ] **Step 2: PoseFrameFixtures.swift 작성 (테스트 헬퍼)**

```swift
import CoreGraphics
import Vision
@testable import PoseAnalyzer

/// 테스트에서 PoseFrame을 쉽게 생성하기 위한 fixture 헬퍼
extension PoseFrame {
    
    /// 빈 PoseFrame
    static func empty(view: SessionView = .side, imageSize: CGSize = CGSize(width: 1000, height: 1000)) -> PoseFrame {
        return PoseFrame(joints: [:], view: view, imageSize: imageSize)
    }
    
    /// 임의 관절 좌표로 PoseFrame 생성
    static func make(
        view: SessionView = .side,
        imageSize: CGSize = CGSize(width: 1000, height: 1000),
        confidence: Float = 0.9,
        _ pairs: [(VNHumanBodyPoseObservation.JointName, CGPoint)]
    ) -> PoseFrame {
        var dict: [VNHumanBodyPoseObservation.JointName: PoseFrame.Joint] = [:]
        for (name, point) in pairs {
            dict[name] = PoseFrame.Joint(name: name, location: point, confidence: confidence)
        }
        return PoseFrame(joints: dict, view: view, imageSize: imageSize)
    }
    
    /// 거북목 측면 테스트용: 귀-어깨-엉덩이 각도를 지정해서 좌표 자동 생성
    /// vertex는 (0.5, 0.5), p1과 p2의 거리는 0.2씩
    static func sideViewWithAngle(
        _ angleDegrees: Double,
        atJoints jointTriple: (VNHumanBodyPoseObservation.JointName,
                              VNHumanBodyPoseObservation.JointName,
                              VNHumanBodyPoseObservation.JointName),
        confidence: Float = 0.9
    ) -> PoseFrame {
        // vertex를 중심으로 p1은 위쪽, p2는 아래쪽
        let vertex = CGPoint(x: 0.5, y: 0.5)
        let radius = 0.2
        // p1: vertex 위쪽 수직
        let p1 = CGPoint(x: 0.5, y: 0.5 + radius)
        // p2: vertex 기준 angleDegrees만큼 내려간 위치
        // angleDegrees = 180이면 p2는 vertex 아래 수직
        let theta = (180 - angleDegrees) * .pi / 180  // p1에서 시계방향으로 angleDegrees 만큼
        let p2 = CGPoint(
            x: vertex.x + radius * sin(theta),
            y: vertex.y - radius * cos(theta)
        )
        return make(view: .side, confidence: confidence, [
            (jointTriple.0, p1),
            (jointTriple.1, vertex),
            (jointTriple.2, p2),
        ])
    }
}
```

- [ ] **Step 3: 빌드 확인**

PoseAnalyzerTests에 Helpers 폴더를 만들고 위 파일을 거기에 둠. Xcode에서 Target Membership이 PoseAnalyzerTests로 되어 있는지 확인.

- [ ] **Step 4: commit**

```bash
git add Domain/Evaluation/PostureEvaluator.swift PoseAnalyzerTests/Helpers/
git commit -m "feat(evaluation): define PostureEvaluator protocol and PoseFrame fixtures"
```

---

## Phase 6: 8개 Evaluator 구현 (TDD)

### Task 10: ForwardHeadEvaluator (거북목)

**측정 방식:** 귀-어깨-엉덩이 세 점 각도. 좌/우 페어는 평균 confidence 높은 쪽 자동 선택.
**임계값:** 정상 ≥170°, 주의 160-170°, 의심 <160°.

**파일/경로:**
- 생성: `PoseAnalyzer/Domain/Evaluation/ForwardHeadEvaluator.swift`
- 생성: `PoseAnalyzerTests/Evaluators/ForwardHeadEvaluatorTests.swift`

- [ ] **Step 1: 실패하는 테스트 먼저 작성**

```swift
import XCTest
import Vision
@testable import PoseAnalyzer

final class ForwardHeadEvaluatorTests: XCTestCase {
    
    let evaluator = ForwardHeadEvaluator()
    
    func test_정상_각도_175도_normal_반환() {
        let frame = PoseFrame.sideViewWithAngle(
            175,
            atJoints: (.leftEar, .leftShoulder, .leftHip)
        )
        let result = evaluator.evaluate(frame)
        XCTAssertEqual(result.status, .normal)
        XCTAssertEqual(result.primaryMetric, 175, accuracy: 1)
    }
    
    func test_경계_각도_165도_caution_반환() {
        let frame = PoseFrame.sideViewWithAngle(
            165,
            atJoints: (.leftEar, .leftShoulder, .leftHip)
        )
        let result = evaluator.evaluate(frame)
        XCTAssertEqual(result.status, .caution)
    }
    
    func test_의심_각도_150도_suspect_반환() {
        let frame = PoseFrame.sideViewWithAngle(
            150,
            atJoints: (.leftEar, .leftShoulder, .leftHip)
        )
        let result = evaluator.evaluate(frame)
        XCTAssertEqual(result.status, .suspect)
    }
    
    func test_관절_누락_unmeasurable_반환() {
        let frame = PoseFrame.empty()
        let result = evaluator.evaluate(frame)
        XCTAssertEqual(result.status, .unmeasurable)
    }
    
    func test_신뢰도_낮음_unmeasurable_반환() {
        let frame = PoseFrame.sideViewWithAngle(
            175,
            atJoints: (.leftEar, .leftShoulder, .leftHip),
            confidence: 0.2  // < 0.3
        )
        let result = evaluator.evaluate(frame)
        XCTAssertEqual(result.status, .unmeasurable)
    }
    
    func test_우측이_더_신뢰도_높으면_우측_사용() {
        // 좌측: 낮은 신뢰도, 우측: 정상
        var joints: [VNHumanBodyPoseObservation.JointName: PoseFrame.Joint] = [:]
        joints[.leftEar] = .init(name: .leftEar, location: .init(x: 0.5, y: 0.7), confidence: 0.1)
        joints[.leftShoulder] = .init(name: .leftShoulder, location: .init(x: 0.5, y: 0.5), confidence: 0.1)
        joints[.leftHip] = .init(name: .leftHip, location: .init(x: 0.5, y: 0.3), confidence: 0.1)
        // 우측: 정상 직선 (각도 180)
        joints[.rightEar] = .init(name: .rightEar, location: .init(x: 0.5, y: 0.7), confidence: 0.9)
        joints[.rightShoulder] = .init(name: .rightShoulder, location: .init(x: 0.5, y: 0.5), confidence: 0.9)
        joints[.rightHip] = .init(name: .rightHip, location: .init(x: 0.5, y: 0.3), confidence: 0.9)
        
        let frame = PoseFrame(joints: joints, view: .side, imageSize: CGSize(width: 1000, height: 1000))
        let result = evaluator.evaluate(frame)
        XCTAssertEqual(result.status, .normal)
        XCTAssertTrue(result.usedJointNames.contains { $0.contains("right") })
    }
}
```

- [ ] **Step 2: 테스트 실행하여 실패 확인**

`⌘U`. `ForwardHeadEvaluator` 없음 컴파일 실패.

- [ ] **Step 3: ForwardHeadEvaluator.swift 구현**

```swift
import Vision

/// 거북목 (Forward Head Posture) 판정
/// 측정: 귀-어깨-엉덩이 세 점이 이루는 각도
/// 임계값: 정상 ≥170°, 주의 160~170°, 의심 <170° (의심은 normalRange/cautionRange 둘 다 벗어남)
final class ForwardHeadEvaluator: PostureEvaluator {
    
    let type: PostureType = .forwardHead
    let requiredView: SessionView = .side
    
    private let thresholds = Thresholds(
        normalRange: 170...360,        // 170 이상 정상 (수학적으로 180까지)
        cautionRange: 160...170,
        direction: .higherIsNormal
    )
    
    func evaluate(_ frame: PoseFrame) -> PostureResult {
        // 좌/우 측 중 신뢰도 높은 쪽 자동 선택
        let leftJoints: [VNHumanBodyPoseObservation.JointName] = [.leftEar, .leftShoulder, .leftHip]
        let rightJoints: [VNHumanBodyPoseObservation.JointName] = [.rightEar, .rightShoulder, .rightHip]
        
        let leftReliable = frame.areReliable(leftJoints)
        let rightReliable = frame.areReliable(rightJoints)
        
        guard leftReliable || rightReliable else {
            return .unmeasurable(type: .forwardHead, reason: "측면 귀·어깨·엉덩이 관절 인식 부족")
        }
        
        let leftConf = leftReliable ? frame.averageConfidence(leftJoints) : 0
        let rightConf = rightReliable ? frame.averageConfidence(rightJoints) : 0
        
        let useRight = rightConf > leftConf
        let joints = useRight ? rightJoints : leftJoints
        
        guard let ear = frame.point(joints[0]),
              let shoulder = frame.point(joints[1]),
              let hip = frame.point(joints[2]) else {
            return .unmeasurable(type: .forwardHead, reason: "관절 좌표 누락")
        }
        
        let angle = GeometryMath.angleBetween(p1: ear, vertex: shoulder, p2: hip)
        let status = thresholds.evaluate(angle)
        
        return PostureResult(
            type: .forwardHead,
            status: status,
            primaryMetric: angle,
            primaryMetricUnit: .degree,
            thresholds: thresholds,
            usedJointNames: joints.map { String($0.rawValue) },
            confidence: useRight ? rightConf : leftConf,
            advice: status == .normal ? nil : "장시간 고개를 숙이지 마시고, 모니터 높이를 눈높이로 맞춰주세요."
        )
    }
}
```

- [ ] **Step 4: 테스트 실행하여 통과 확인**

`⌘U`. 모든 ForwardHeadEvaluatorTests 통과.

- [ ] **Step 5: commit**

```bash
git add Domain/Evaluation/ForwardHeadEvaluator.swift PoseAnalyzerTests/Evaluators/
git commit -m "feat(evaluation): add ForwardHeadEvaluator with TDD (귀-어깨-엉덩이 각도)"
```

---

### Task 11: RoundShoulderEvaluator (라운드숄더)

**측정 방식:** 측면에서 어깨가 귀보다 얼마나 앞에 있는지 (수평거리). 어깨 폭 기준 정규화 비율.

**파일/경로:**
- 생성: `PoseAnalyzer/Domain/Evaluation/RoundShoulderEvaluator.swift`
- 생성: `PoseAnalyzerTests/Evaluators/RoundShoulderEvaluatorTests.swift`

- [ ] **Step 1: 실패 테스트 작성**

```swift
import XCTest
import Vision
@testable import PoseAnalyzer

final class RoundShoulderEvaluatorTests: XCTestCase {
    
    let evaluator = RoundShoulderEvaluator()
    
    private func makeFrame(earX: Double, shoulderX: Double, shoulderWidth: Double, confidence: Float = 0.9) -> PoseFrame {
        // 측면이라 한쪽만 신뢰 가능
        // 어깨 폭은 leftShoulder-rightShoulder 거리로 추정 (측면에선 X 좌표 차이 거의 0이므로 어깨 폭은 별도로 주입)
        // 라운드숄더 측정은 동측 어깨와 동측 귀의 X 좌표 차이를 어깨 폭(reference)으로 나눈 비율
        return PoseFrame.make(view: .side, confidence: confidence, [
            (.leftEar, CGPoint(x: earX, y: 0.7)),
            (.leftShoulder, CGPoint(x: shoulderX, y: 0.5)),
            (.rightShoulder, CGPoint(x: shoulderX + shoulderWidth, y: 0.5)),  // 폭 추정용
        ])
    }
    
    func test_어깨와_귀_수직정렬_정상() {
        let frame = makeFrame(earX: 0.5, shoulderX: 0.5, shoulderWidth: 0.2)
        let result = evaluator.evaluate(frame)
        XCTAssertEqual(result.status, .normal)
    }
    
    func test_어깨가_귀보다_20퍼센트_앞_주의() {
        // 비율 0.2 → 0.15-0.25 사이 → caution
        let frame = makeFrame(earX: 0.5, shoulderX: 0.54, shoulderWidth: 0.2)
        let result = evaluator.evaluate(frame)
        XCTAssertEqual(result.status, .caution)
    }
    
    func test_어깨가_귀보다_심하게_앞_의심() {
        // 비율 0.4 → > 0.25 → suspect
        let frame = makeFrame(earX: 0.5, shoulderX: 0.58, shoulderWidth: 0.2)
        let result = evaluator.evaluate(frame)
        XCTAssertEqual(result.status, .suspect)
    }
    
    func test_관절_없으면_unmeasurable() {
        let frame = PoseFrame.empty()
        let result = evaluator.evaluate(frame)
        XCTAssertEqual(result.status, .unmeasurable)
    }
}
```

- [ ] **Step 2: 테스트 실행, 실패 확인**

- [ ] **Step 3: RoundShoulderEvaluator.swift 구현**

```swift
import Vision

/// 라운드숄더 (Round Shoulder) 판정
/// 측정: 측면 사진에서 어깨가 귀보다 얼마나 앞에 있는지 (수평 거리 / 어깨 폭 비율)
/// 임계값: < 0.15 정상, 0.15~0.25 주의, > 0.25 의심
final class RoundShoulderEvaluator: PostureEvaluator {
    
    let type: PostureType = .roundShoulder
    let requiredView: SessionView = .side
    
    private let thresholds = Thresholds(
        normalRange: 0...0.15,
        cautionRange: 0.15...0.25,
        direction: .lowerIsNormal
    )
    
    func evaluate(_ frame: PoseFrame) -> PostureResult {
        // 어깨 폭 기준 잡기: leftShoulder ~ rightShoulder 거리
        guard let leftShoulder = frame.point(.leftShoulder),
              let rightShoulder = frame.point(.rightShoulder) else {
            return .unmeasurable(type: .roundShoulder, reason: "어깨 관절 인식 부족")
        }
        let shoulderWidth = GeometryMath.distance(leftShoulder, rightShoulder)
        guard shoulderWidth > 0.01 else {
            return .unmeasurable(type: .roundShoulder, reason: "어깨 폭 측정 실패")
        }
        
        // 좌/우 측 중 confidence 높은 쪽 사용 (귀-어깨)
        let leftReliable = frame.areReliable([.leftEar, .leftShoulder])
        let rightReliable = frame.areReliable([.rightEar, .rightShoulder])
        
        guard leftReliable || rightReliable else {
            return .unmeasurable(type: .roundShoulder, reason: "귀·어깨 관절 신뢰도 부족")
        }
        
        let leftConf = leftReliable ? frame.averageConfidence([.leftEar, .leftShoulder]) : 0
        let rightConf = rightReliable ? frame.averageConfidence([.rightEar, .rightShoulder]) : 0
        let useRight = rightConf > leftConf
        
        let earName: VNHumanBodyPoseObservation.JointName = useRight ? .rightEar : .leftEar
        let shoulderName: VNHumanBodyPoseObservation.JointName = useRight ? .rightShoulder : .leftShoulder
        
        guard let ear = frame.point(earName),
              let shoulder = frame.point(shoulderName) else {
            return .unmeasurable(type: .roundShoulder, reason: "관절 좌표 누락")
        }
        
        let ratio = GeometryMath.horizontalGapRatio(from: ear, to: shoulder, referenceWidth: shoulderWidth)
        let status = thresholds.evaluate(ratio)
        
        return PostureResult(
            type: .roundShoulder,
            status: status,
            primaryMetric: ratio,
            primaryMetricUnit: .ratio,
            thresholds: thresholds,
            usedJointNames: [earName.rawValue.rawValue, shoulderName.rawValue.rawValue],
            confidence: useRight ? rightConf : leftConf,
            advice: status == .normal ? nil : "어깨를 뒤로 펴는 스트레칭을 정기적으로 해주세요."
        )
    }
}
```

- [ ] **Step 4: 테스트 통과 확인**

- [ ] **Step 5: commit**

```bash
git add Domain/Evaluation/RoundShoulderEvaluator.swift PoseAnalyzerTests/Evaluators/RoundShoulderEvaluatorTests.swift
git commit -m "feat(evaluation): add RoundShoulderEvaluator with TDD (어깨-귀 수평거리/어깨폭 비율)"
```

---

### Task 12: KyphosisEvaluator (흉추 후만증)

**측정 방식:** 측면 목-어깨-엉덩이 세 점 각도. 정상 ≥175°, 주의 165~175°, 의심 <165°.

**파일/경로:**
- 생성: `PoseAnalyzer/Domain/Evaluation/KyphosisEvaluator.swift`
- 생성: `PoseAnalyzerTests/Evaluators/KyphosisEvaluatorTests.swift`

- [ ] **Step 1: 실패 테스트 작성**

```swift
import XCTest
@testable import PoseAnalyzer

final class KyphosisEvaluatorTests: XCTestCase {
    let evaluator = KyphosisEvaluator()
    
    func test_정상_180도_normal() {
        // neck, shoulder, hip 직선 → 180도
        let frame = PoseFrame.sideViewWithAngle(180, atJoints: (.neck, .leftShoulder, .leftHip))
        let result = evaluator.evaluate(frame)
        XCTAssertEqual(result.status, .normal)
    }
    
    func test_경계_170도_caution() {
        let frame = PoseFrame.sideViewWithAngle(170, atJoints: (.neck, .leftShoulder, .leftHip))
        let result = evaluator.evaluate(frame)
        XCTAssertEqual(result.status, .caution)
    }
    
    func test_의심_160도_suspect() {
        let frame = PoseFrame.sideViewWithAngle(160, atJoints: (.neck, .leftShoulder, .leftHip))
        let result = evaluator.evaluate(frame)
        XCTAssertEqual(result.status, .suspect)
    }
    
    func test_관절_누락_unmeasurable() {
        let frame = PoseFrame.empty()
        let result = evaluator.evaluate(frame)
        XCTAssertEqual(result.status, .unmeasurable)
    }
}
```

- [ ] **Step 2: 테스트 실행, 실패 확인**

- [ ] **Step 3: KyphosisEvaluator.swift 구현**

```swift
import Vision

/// 흉추 후만증 (Kyphosis) — 등 위쪽 굽음 판정
/// 측정: 목-어깨-엉덩이 세 점 각도
/// 임계값: ≥175° 정상, 165~175° 주의, <165° 의심
final class KyphosisEvaluator: PostureEvaluator {
    
    let type: PostureType = .kyphosis
    let requiredView: SessionView = .side
    
    private let thresholds = Thresholds(
        normalRange: 175...360,
        cautionRange: 165...175,
        direction: .higherIsNormal
    )
    
    func evaluate(_ frame: PoseFrame) -> PostureResult {
        let leftJoints: [VNHumanBodyPoseObservation.JointName] = [.neck, .leftShoulder, .leftHip]
        let rightJoints: [VNHumanBodyPoseObservation.JointName] = [.neck, .rightShoulder, .rightHip]
        
        let leftReliable = frame.areReliable(leftJoints)
        let rightReliable = frame.areReliable(rightJoints)
        
        guard leftReliable || rightReliable else {
            return .unmeasurable(type: .kyphosis, reason: "목·어깨·엉덩이 관절 인식 부족")
        }
        
        let leftConf = leftReliable ? frame.averageConfidence(leftJoints) : 0
        let rightConf = rightReliable ? frame.averageConfidence(rightJoints) : 0
        let useRight = rightConf > leftConf
        let joints = useRight ? rightJoints : leftJoints
        
        guard let neck = frame.point(joints[0]),
              let shoulder = frame.point(joints[1]),
              let hip = frame.point(joints[2]) else {
            return .unmeasurable(type: .kyphosis, reason: "관절 좌표 누락")
        }
        
        let angle = GeometryMath.angleBetween(p1: neck, vertex: shoulder, p2: hip)
        let status = thresholds.evaluate(angle)
        
        return PostureResult(
            type: .kyphosis,
            status: status,
            primaryMetric: angle,
            primaryMetricUnit: .degree,
            thresholds: thresholds,
            usedJointNames: joints.map { String($0.rawValue) },
            confidence: useRight ? rightConf : leftConf,
            advice: status == .normal ? nil : "흉추 신전 스트레칭(폼롤러)을 권장합니다."
        )
    }
}
```

- [ ] **Step 4: 테스트 통과 확인**

- [ ] **Step 5: commit**

```bash
git add Domain/Evaluation/KyphosisEvaluator.swift PoseAnalyzerTests/Evaluators/KyphosisEvaluatorTests.swift
git commit -m "feat(evaluation): add KyphosisEvaluator with TDD (목-어깨-엉덩이 각도)"
```

---

### Task 13: AnteriorPelvicTiltEvaluator (골반 전방경사)

**측정 방식:** 측면 어깨-엉덩이-무릎 세 점 각도. 정상 175~185°, 주의 170~175° 또는 185~190°, 의심 그 바깥.

**파일/경로:**
- 생성: `PoseAnalyzer/Domain/Evaluation/AnteriorPelvicTiltEvaluator.swift`
- 생성: `PoseAnalyzerTests/Evaluators/AnteriorPelvicTiltEvaluatorTests.swift`

- [ ] **Step 1: 실패 테스트 작성**

```swift
import XCTest
@testable import PoseAnalyzer

final class AnteriorPelvicTiltEvaluatorTests: XCTestCase {
    let evaluator = AnteriorPelvicTiltEvaluator()
    
    func test_180도_normal() {
        let frame = PoseFrame.sideViewWithAngle(180, atJoints: (.leftShoulder, .leftHip, .leftKnee))
        XCTAssertEqual(evaluator.evaluate(frame).status, .normal)
    }
    
    func test_172도_caution_전방경사_주의() {
        let frame = PoseFrame.sideViewWithAngle(172, atJoints: (.leftShoulder, .leftHip, .leftKnee))
        XCTAssertEqual(evaluator.evaluate(frame).status, .caution)
    }
    
    func test_165도_suspect_전방경사_의심() {
        let frame = PoseFrame.sideViewWithAngle(165, atJoints: (.leftShoulder, .leftHip, .leftKnee))
        XCTAssertEqual(evaluator.evaluate(frame).status, .suspect)
    }
    
    func test_188도_caution_후방경사_주의() {
        let frame = PoseFrame.sideViewWithAngle(188, atJoints: (.leftShoulder, .leftHip, .leftKnee))
        XCTAssertEqual(evaluator.evaluate(frame).status, .caution)
    }
    
    func test_관절_누락_unmeasurable() {
        XCTAssertEqual(evaluator.evaluate(.empty()).status, .unmeasurable)
    }
}
```

- [ ] **Step 2: 테스트 실행, 실패 확인**

- [ ] **Step 3: AnteriorPelvicTiltEvaluator.swift 구현**

```swift
import Vision

/// 골반 전방경사 / 후방경사 판정
/// 측정: 어깨-엉덩이-무릎 세 점 각도
/// 임계값: 175~185 정상, 170~175 / 185~190 주의, 그 바깥 의심
final class AnteriorPelvicTiltEvaluator: PostureEvaluator {
    
    let type: PostureType = .anteriorPelvicTilt
    let requiredView: SessionView = .side
    
    private let thresholds = Thresholds(
        normalRange: 175...185,
        cautionRange: 170...190,   // 정상 범위 바깥 + caution 범위 안 = caution
        direction: .centeredOnRange
    )
    
    func evaluate(_ frame: PoseFrame) -> PostureResult {
        let leftJoints: [VNHumanBodyPoseObservation.JointName] = [.leftShoulder, .leftHip, .leftKnee]
        let rightJoints: [VNHumanBodyPoseObservation.JointName] = [.rightShoulder, .rightHip, .rightKnee]
        
        let leftReliable = frame.areReliable(leftJoints)
        let rightReliable = frame.areReliable(rightJoints)
        
        guard leftReliable || rightReliable else {
            return .unmeasurable(type: .anteriorPelvicTilt, reason: "어깨·엉덩이·무릎 관절 인식 부족")
        }
        
        let leftConf = leftReliable ? frame.averageConfidence(leftJoints) : 0
        let rightConf = rightReliable ? frame.averageConfidence(rightJoints) : 0
        let useRight = rightConf > leftConf
        let joints = useRight ? rightJoints : leftJoints
        
        guard let shoulder = frame.point(joints[0]),
              let hip = frame.point(joints[1]),
              let knee = frame.point(joints[2]) else {
            return .unmeasurable(type: .anteriorPelvicTilt, reason: "관절 좌표 누락")
        }
        
        let angle = GeometryMath.angleBetween(p1: shoulder, vertex: hip, p2: knee)
        let status = thresholds.evaluate(angle)
        
        let direction: String
        if angle < 175 { direction = "전방경사 경향" }
        else if angle > 185 { direction = "후방경사 경향" }
        else { direction = "" }
        
        return PostureResult(
            type: .anteriorPelvicTilt,
            status: status,
            primaryMetric: angle,
            primaryMetricUnit: .degree,
            thresholds: thresholds,
            usedJointNames: joints.map { String($0.rawValue) },
            confidence: useRight ? rightConf : leftConf,
            advice: status == .normal ? nil : "\(direction). 코어 강화와 골반 정렬 운동을 권장합니다."
        )
    }
}
```

- [ ] **Step 4: 테스트 통과 확인**

- [ ] **Step 5: commit**

```bash
git add Domain/Evaluation/AnteriorPelvicTiltEvaluator.swift PoseAnalyzerTests/Evaluators/AnteriorPelvicTiltEvaluatorTests.swift
git commit -m "feat(evaluation): add AnteriorPelvicTiltEvaluator with TDD (어깨-엉덩이-무릎 각도)"
```

---

### Task 14: KneeHyperextensionEvaluator (무릎 과신전)

**측정 방식:** 측면 엉덩이-무릎-발목 세 점 각도. 정상 175~185°, 주의 185~190°, 의심 >190°.

**파일/경로:**
- 생성: `PoseAnalyzer/Domain/Evaluation/KneeHyperextensionEvaluator.swift`
- 생성: `PoseAnalyzerTests/Evaluators/KneeHyperextensionEvaluatorTests.swift`

- [ ] **Step 1: 실패 테스트 작성**

```swift
import XCTest
@testable import PoseAnalyzer

final class KneeHyperextensionEvaluatorTests: XCTestCase {
    let evaluator = KneeHyperextensionEvaluator()
    
    func test_180도_normal() {
        let frame = PoseFrame.sideViewWithAngle(180, atJoints: (.leftHip, .leftKnee, .leftAnkle))
        XCTAssertEqual(evaluator.evaluate(frame).status, .normal)
    }
    
    func test_187도_caution() {
        let frame = PoseFrame.sideViewWithAngle(187, atJoints: (.leftHip, .leftKnee, .leftAnkle))
        XCTAssertEqual(evaluator.evaluate(frame).status, .caution)
    }
    
    func test_195도_suspect() {
        let frame = PoseFrame.sideViewWithAngle(195, atJoints: (.leftHip, .leftKnee, .leftAnkle))
        XCTAssertEqual(evaluator.evaluate(frame).status, .suspect)
    }
    
    func test_관절_누락_unmeasurable() {
        XCTAssertEqual(evaluator.evaluate(.empty()).status, .unmeasurable)
    }
}
```

- [ ] **Step 2: 테스트 실행, 실패 확인**

- [ ] **Step 3: KneeHyperextensionEvaluator.swift 구현**

```swift
import Vision

/// 무릎 과신전 (Knee Hyperextension) 판정
/// 측정: 엉덩이-무릎-발목 각도
/// 임계값: ≤185 정상, 185~190 주의, >190 의심 (한 방향 — 과신전만 평가)
final class KneeHyperextensionEvaluator: PostureEvaluator {
    
    let type: PostureType = .kneeHyperextension
    let requiredView: SessionView = .side
    
    private let thresholds = Thresholds(
        normalRange: 0...185,
        cautionRange: 185...190,
        direction: .higherIsNormal
    )
    
    func evaluate(_ frame: PoseFrame) -> PostureResult {
        let leftJoints: [VNHumanBodyPoseObservation.JointName] = [.leftHip, .leftKnee, .leftAnkle]
        let rightJoints: [VNHumanBodyPoseObservation.JointName] = [.rightHip, .rightKnee, .rightAnkle]
        
        let leftReliable = frame.areReliable(leftJoints)
        let rightReliable = frame.areReliable(rightJoints)
        
        guard leftReliable || rightReliable else {
            return .unmeasurable(type: .kneeHyperextension, reason: "엉덩이·무릎·발목 관절 인식 부족")
        }
        
        let leftConf = leftReliable ? frame.averageConfidence(leftJoints) : 0
        let rightConf = rightReliable ? frame.averageConfidence(rightJoints) : 0
        let useRight = rightConf > leftConf
        let joints = useRight ? rightJoints : leftJoints
        
        guard let hip = frame.point(joints[0]),
              let knee = frame.point(joints[1]),
              let ankle = frame.point(joints[2]) else {
            return .unmeasurable(type: .kneeHyperextension, reason: "관절 좌표 누락")
        }
        
        let angle = GeometryMath.angleBetween(p1: hip, vertex: knee, p2: ankle)
        let status = thresholds.evaluate(angle)
        
        return PostureResult(
            type: .kneeHyperextension,
            status: status,
            primaryMetric: angle,
            primaryMetricUnit: .degree,
            thresholds: thresholds,
            usedJointNames: joints.map { String($0.rawValue) },
            confidence: useRight ? rightConf : leftConf,
            advice: status == .normal ? nil : "서 있을 때 무릎을 살짝 굽혀 정렬을 유지해보세요."
        )
    }
}
```

- [ ] **Step 4: 테스트 통과 확인**

- [ ] **Step 5: commit**

```bash
git add Domain/Evaluation/KneeHyperextensionEvaluator.swift PoseAnalyzerTests/Evaluators/KneeHyperextensionEvaluatorTests.swift
git commit -m "feat(evaluation): add KneeHyperextensionEvaluator with TDD"
```

---

### Task 15: ScoliosisEvaluator (척추측만 — 정면)

**측정 방식:** 정면 양 어깨 기울기 + 양 엉덩이 기울기 (둘 다 수평 대비 각도). 둘 다 <2° 정상, 둘 중 하나 2~5° 주의, 5° 이상 의심.

**파일/경로:**
- 생성: `PoseAnalyzer/Domain/Evaluation/ScoliosisEvaluator.swift`
- 생성: `PoseAnalyzerTests/Evaluators/ScoliosisEvaluatorTests.swift`

- [ ] **Step 1: 실패 테스트 작성**

```swift
import XCTest
@testable import PoseAnalyzer

final class ScoliosisEvaluatorTests: XCTestCase {
    let evaluator = ScoliosisEvaluator()
    
    private func makeFront(
        leftShoulder: CGPoint, rightShoulder: CGPoint,
        leftHip: CGPoint, rightHip: CGPoint,
        confidence: Float = 0.9
    ) -> PoseFrame {
        return PoseFrame.make(view: .front, confidence: confidence, [
            (.leftShoulder, leftShoulder),
            (.rightShoulder, rightShoulder),
            (.leftHip, leftHip),
            (.rightHip, rightHip),
        ])
    }
    
    func test_어깨_엉덩이_수평_normal() {
        let frame = makeFront(
            leftShoulder: CGPoint(x: 0.4, y: 0.7), rightShoulder: CGPoint(x: 0.6, y: 0.7),
            leftHip: CGPoint(x: 0.4, y: 0.4), rightHip: CGPoint(x: 0.6, y: 0.4)
        )
        XCTAssertEqual(evaluator.evaluate(frame).status, .normal)
    }
    
    func test_어깨_3도_기울기_caution() {
        // tan(3°) ≈ 0.0524 → 어깨 폭 0.2면 높이차 약 0.0105
        let frame = makeFront(
            leftShoulder: CGPoint(x: 0.4, y: 0.7), rightShoulder: CGPoint(x: 0.6, y: 0.7 + 0.0105),
            leftHip: CGPoint(x: 0.4, y: 0.4), rightHip: CGPoint(x: 0.6, y: 0.4)
        )
        XCTAssertEqual(evaluator.evaluate(frame).status, .caution)
    }
    
    func test_어깨_7도_기울기_suspect() {
        let frame = makeFront(
            leftShoulder: CGPoint(x: 0.4, y: 0.7), rightShoulder: CGPoint(x: 0.6, y: 0.7 + 0.0246),
            leftHip: CGPoint(x: 0.4, y: 0.4), rightHip: CGPoint(x: 0.6, y: 0.4)
        )
        XCTAssertEqual(evaluator.evaluate(frame).status, .suspect)
    }
    
    func test_관절_없으면_unmeasurable() {
        XCTAssertEqual(evaluator.evaluate(.empty()).status, .unmeasurable)
    }
}
```

- [ ] **Step 2: 테스트 실행, 실패 확인**

- [ ] **Step 3: ScoliosisEvaluator.swift 구현**

```swift
import Vision

/// 척추측만 (Scoliosis) — 어깨/엉덩이 좌우 기울기로 추정
/// 측정: 양 어깨 직선과 수평 사이 각도 + 양 엉덩이 직선과 수평 사이 각도
/// 임계값: 두 값 모두 <2° 정상, 둘 중 하나 2~5° 주의, 5°초과 의심
final class ScoliosisEvaluator: PostureEvaluator {
    
    let type: PostureType = .scoliosis
    let requiredView: SessionView = .front
    
    private let thresholds = Thresholds(
        normalRange: 0...2,
        cautionRange: 2...5,
        direction: .lowerIsNormal
    )
    
    func evaluate(_ frame: PoseFrame) -> PostureResult {
        let needed: [VNHumanBodyPoseObservation.JointName] = [
            .leftShoulder, .rightShoulder, .leftHip, .rightHip
        ]
        guard frame.areReliable(needed) else {
            return .unmeasurable(type: .scoliosis, reason: "양 어깨·엉덩이 관절 신뢰도 부족")
        }
        
        guard let ls = frame.point(.leftShoulder),
              let rs = frame.point(.rightShoulder),
              let lh = frame.point(.leftHip),
              let rh = frame.point(.rightHip) else {
            return .unmeasurable(type: .scoliosis, reason: "관절 좌표 누락")
        }
        
        let shoulderTilt = GeometryMath.absLineAngleFromHorizontal(ls, rs)
        let hipTilt = GeometryMath.absLineAngleFromHorizontal(lh, rh)
        
        // 더 큰 기울기를 primaryMetric으로 사용
        let primary = max(shoulderTilt, hipTilt)
        let status = thresholds.evaluate(primary)
        
        return PostureResult(
            type: .scoliosis,
            status: status,
            primaryMetric: primary,
            primaryMetricUnit: .degree,
            thresholds: thresholds,
            usedJointNames: needed.map { String($0.rawValue) },
            confidence: frame.averageConfidence(needed),
            advice: status == .normal ? nil : "어깨 기울기 \(String(format: "%.1f", shoulderTilt))° / 골반 기울기 \(String(format: "%.1f", hipTilt))°. 전문가 상담을 권장합니다."
        )
    }
}
```

- [ ] **Step 4: 테스트 통과 확인**

- [ ] **Step 5: commit**

```bash
git add Domain/Evaluation/ScoliosisEvaluator.swift PoseAnalyzerTests/Evaluators/ScoliosisEvaluatorTests.swift
git commit -m "feat(evaluation): add ScoliosisEvaluator with TDD (어깨/엉덩이 좌우 기울기)"
```

---

### Task 16: HeadTiltEvaluator (머리 좌우 기울기)

**측정 방식:** 정면 양 귀(또는 양 눈) 직선의 수평 대비 기울기. <2° 정상, 2~5° 주의, 5° 초과 의심.

**파일/경로:**
- 생성: `PoseAnalyzer/Domain/Evaluation/HeadTiltEvaluator.swift`
- 생성: `PoseAnalyzerTests/Evaluators/HeadTiltEvaluatorTests.swift`

- [ ] **Step 1: 실패 테스트 작성**

```swift
import XCTest
@testable import PoseAnalyzer

final class HeadTiltEvaluatorTests: XCTestCase {
    let evaluator = HeadTiltEvaluator()
    
    func test_양귀_수평_normal() {
        let frame = PoseFrame.make(view: .front, [
            (.leftEar, CGPoint(x: 0.4, y: 0.8)),
            (.rightEar, CGPoint(x: 0.6, y: 0.8)),
        ])
        XCTAssertEqual(evaluator.evaluate(frame).status, .normal)
    }
    
    func test_귀_3도_기울기_caution() {
        let frame = PoseFrame.make(view: .front, [
            (.leftEar, CGPoint(x: 0.4, y: 0.8)),
            (.rightEar, CGPoint(x: 0.6, y: 0.8 + 0.0105)),
        ])
        XCTAssertEqual(evaluator.evaluate(frame).status, .caution)
    }
    
    func test_귀_7도_기울기_suspect() {
        let frame = PoseFrame.make(view: .front, [
            (.leftEar, CGPoint(x: 0.4, y: 0.8)),
            (.rightEar, CGPoint(x: 0.6, y: 0.8 + 0.0246)),
        ])
        XCTAssertEqual(evaluator.evaluate(frame).status, .suspect)
    }
    
    func test_귀_없으면_눈으로_fallback() {
        let frame = PoseFrame.make(view: .front, [
            (.leftEye, CGPoint(x: 0.4, y: 0.8)),
            (.rightEye, CGPoint(x: 0.6, y: 0.8)),
        ])
        XCTAssertEqual(evaluator.evaluate(frame).status, .normal)
    }
    
    func test_관절_없으면_unmeasurable() {
        XCTAssertEqual(evaluator.evaluate(.empty()).status, .unmeasurable)
    }
}
```

- [ ] **Step 2: 테스트 실행, 실패 확인**

- [ ] **Step 3: HeadTiltEvaluator.swift 구현**

```swift
import Vision

/// 머리 좌우 기울기 (Head Tilt) — 정면 사진
/// 측정: 양 귀 직선의 수평 대비 기울기 (귀 신뢰도 낮으면 양 눈으로 fallback)
final class HeadTiltEvaluator: PostureEvaluator {
    
    let type: PostureType = .headTilt
    let requiredView: SessionView = .front
    
    private let thresholds = Thresholds(
        normalRange: 0...2,
        cautionRange: 2...5,
        direction: .lowerIsNormal
    )
    
    func evaluate(_ frame: PoseFrame) -> PostureResult {
        let earsReliable = frame.areReliable([.leftEar, .rightEar])
        let eyesReliable = frame.areReliable([.leftEye, .rightEye])
        
        let leftName: VNHumanBodyPoseObservation.JointName
        let rightName: VNHumanBodyPoseObservation.JointName
        let usedConfidence: Double
        
        if earsReliable {
            leftName = .leftEar
            rightName = .rightEar
            usedConfidence = frame.averageConfidence([.leftEar, .rightEar])
        } else if eyesReliable {
            leftName = .leftEye
            rightName = .rightEye
            usedConfidence = frame.averageConfidence([.leftEye, .rightEye])
        } else {
            return .unmeasurable(type: .headTilt, reason: "양 귀·양 눈 모두 인식 부족")
        }
        
        guard let left = frame.point(leftName),
              let right = frame.point(rightName) else {
            return .unmeasurable(type: .headTilt, reason: "관절 좌표 누락")
        }
        
        let tilt = GeometryMath.absLineAngleFromHorizontal(left, right)
        let status = thresholds.evaluate(tilt)
        
        return PostureResult(
            type: .headTilt,
            status: status,
            primaryMetric: tilt,
            primaryMetricUnit: .degree,
            thresholds: thresholds,
            usedJointNames: [leftName.rawValue.rawValue, rightName.rawValue.rawValue],
            confidence: usedConfidence,
            advice: status == .normal ? nil : "한쪽으로 머리를 기우는 습관이 있는지 확인해보세요."
        )
    }
}
```

- [ ] **Step 4: 테스트 통과 확인**

- [ ] **Step 5: commit**

```bash
git add Domain/Evaluation/HeadTiltEvaluator.swift PoseAnalyzerTests/Evaluators/HeadTiltEvaluatorTests.swift
git commit -m "feat(evaluation): add HeadTiltEvaluator with TDD (양 귀 또는 양 눈 기울기)"
```

---

### Task 17: KneeAlignmentEvaluator (무릎 X자/O자 — Genu Valgum/Varum)

**측정 방식:** 정면 양 다리의 엉덩이-무릎-발목 각도 각각 계산. 175~180° 정상, 170~175° 또는 180~185° 주의, <170° (X자) 또는 >185° (O자) 의심.

**파일/경로:**
- 생성: `PoseAnalyzer/Domain/Evaluation/KneeAlignmentEvaluator.swift`
- 생성: `PoseAnalyzerTests/Evaluators/KneeAlignmentEvaluatorTests.swift`

- [ ] **Step 1: 실패 테스트 작성**

```swift
import XCTest
@testable import PoseAnalyzer

final class KneeAlignmentEvaluatorTests: XCTestCase {
    let evaluator = KneeAlignmentEvaluator()
    
    private func makeFront(
        leftHip: CGPoint, leftKnee: CGPoint, leftAnkle: CGPoint,
        rightHip: CGPoint, rightKnee: CGPoint, rightAnkle: CGPoint,
        confidence: Float = 0.9
    ) -> PoseFrame {
        PoseFrame.make(view: .front, confidence: confidence, [
            (.leftHip, leftHip),
            (.leftKnee, leftKnee),
            (.leftAnkle, leftAnkle),
            (.rightHip, rightHip),
            (.rightKnee, rightKnee),
            (.rightAnkle, rightAnkle),
        ])
    }
    
    func test_양다리_수직정렬_normal() {
        // 엉덩이-무릎-발목 직선 (각도 180)
        let frame = makeFront(
            leftHip: CGPoint(x: 0.4, y: 0.5),
            leftKnee: CGPoint(x: 0.4, y: 0.3),
            leftAnkle: CGPoint(x: 0.4, y: 0.1),
            rightHip: CGPoint(x: 0.6, y: 0.5),
            rightKnee: CGPoint(x: 0.6, y: 0.3),
            rightAnkle: CGPoint(x: 0.6, y: 0.1)
        )
        XCTAssertEqual(evaluator.evaluate(frame).status, .normal)
    }
    
    func test_X자_다리_의심() {
        // 무릎이 안쪽으로 (각도 < 170°)
        // 왼쪽: hip(0.4, 0.5) → knee(0.5, 0.3) → ankle(0.4, 0.1) — 무릎이 안으로
        let frame = makeFront(
            leftHip: CGPoint(x: 0.4, y: 0.5),
            leftKnee: CGPoint(x: 0.5, y: 0.3),
            leftAnkle: CGPoint(x: 0.4, y: 0.1),
            rightHip: CGPoint(x: 0.6, y: 0.5),
            rightKnee: CGPoint(x: 0.5, y: 0.3),
            rightAnkle: CGPoint(x: 0.6, y: 0.1)
        )
        XCTAssertEqual(evaluator.evaluate(frame).status, .suspect)
    }
    
    func test_관절_누락_unmeasurable() {
        XCTAssertEqual(evaluator.evaluate(.empty()).status, .unmeasurable)
    }
}
```

- [ ] **Step 2: 테스트 실행, 실패 확인**

- [ ] **Step 3: KneeAlignmentEvaluator.swift 구현**

```swift
import Vision

/// 무릎 X자(Genu Valgum) / O자(Genu Varum) 다리 정렬 판정
/// 측정: 좌·우 다리 각각 엉덩이-무릎-발목 각도
/// 임계값: 175~180 정상, 170~175 / 180~185 주의, <170 X자(의심) / >185 O자(의심)
final class KneeAlignmentEvaluator: PostureEvaluator {
    
    let type: PostureType = .kneeAlignment
    let requiredView: SessionView = .front
    
    private let thresholds = Thresholds(
        normalRange: 175...180,
        cautionRange: 170...185,
        direction: .centeredOnRange
    )
    
    func evaluate(_ frame: PoseFrame) -> PostureResult {
        let leftJoints: [VNHumanBodyPoseObservation.JointName] = [.leftHip, .leftKnee, .leftAnkle]
        let rightJoints: [VNHumanBodyPoseObservation.JointName] = [.rightHip, .rightKnee, .rightAnkle]
        
        guard frame.areReliable(leftJoints) && frame.areReliable(rightJoints) else {
            return .unmeasurable(type: .kneeAlignment, reason: "양 다리 관절 신뢰도 부족")
        }
        
        guard let lh = frame.point(.leftHip), let lk = frame.point(.leftKnee), let la = frame.point(.leftAnkle),
              let rh = frame.point(.rightHip), let rk = frame.point(.rightKnee), let ra = frame.point(.rightAnkle) else {
            return .unmeasurable(type: .kneeAlignment, reason: "관절 좌표 누락")
        }
        
        let leftAngle = GeometryMath.angleBetween(p1: lh, vertex: lk, p2: la)
        let rightAngle = GeometryMath.angleBetween(p1: rh, vertex: rk, p2: ra)
        
        // 정상 범위에서 더 멀리 떨어진 다리의 각도를 primary로 사용
        let leftDeviation = min(abs(leftAngle - 175), abs(leftAngle - 180))
        let rightDeviation = min(abs(rightAngle - 175), abs(rightAngle - 180))
        let primary = leftDeviation > rightDeviation ? leftAngle : rightAngle
        let status = thresholds.evaluate(primary)
        
        let pattern: String
        if leftAngle < 175 && rightAngle < 175 { pattern = "X자(내반슬) 경향" }
        else if leftAngle > 180 && rightAngle > 180 { pattern = "O자(외반슬) 경향" }
        else { pattern = "한쪽 다리 정렬 이상" }
        
        return PostureResult(
            type: .kneeAlignment,
            status: status,
            primaryMetric: primary,
            primaryMetricUnit: .degree,
            thresholds: thresholds,
            usedJointNames: (leftJoints + rightJoints).map { String($0.rawValue) },
            confidence: frame.averageConfidence(leftJoints + rightJoints),
            advice: status == .normal ? nil : "\(pattern). 좌측 \(String(format: "%.0f", leftAngle))° / 우측 \(String(format: "%.0f", rightAngle))°"
        )
    }
}
```

- [ ] **Step 4: 테스트 통과 확인**

- [ ] **Step 5: commit**

```bash
git add Domain/Evaluation/KneeAlignmentEvaluator.swift PoseAnalyzerTests/Evaluators/KneeAlignmentEvaluatorTests.swift
git commit -m "feat(evaluation): add KneeAlignmentEvaluator with TDD (X자/O자 다리 정렬)"
```

---

## Phase 7: 비대칭 분석

### Task 18: AsymmetryAnalyzer (좌우 비대칭 — 정면)

**측정 방식:** 정면에서 양 어깨/엉덩이 Y 좌표 차이 → 각도 + 어깨너비 비율 + (키 있을 때) cm 환산.

**파일/경로:**
- 생성: `PoseAnalyzer/Domain/Asymmetry/AsymmetryAnalyzer.swift`
- 생성: `PoseAnalyzer/Domain/Asymmetry/DefaultAsymmetryAnalyzer.swift`
- 생성: `PoseAnalyzerTests/Asymmetry/AsymmetryAnalyzerTests.swift`

- [ ] **Step 1: 프로토콜과 실패 테스트 작성**

`AsymmetryAnalyzer.swift`:
```swift
import Foundation

/// 정면 사진 기반 좌우 비대칭 분석
protocol AsymmetryAnalyzer {
    /// - Parameters:
    ///   - frontFrame: 정면 사진 PoseFrame
    ///   - heightCm: 사용자 키 (옵션, 있으면 cm 환산)
    func analyze(_ frontFrame: PoseFrame, heightCm: Double?) -> AsymmetryResult
}
```

`AsymmetryAnalyzerTests.swift`:
```swift
import XCTest
@testable import PoseAnalyzer

final class AsymmetryAnalyzerTests: XCTestCase {
    let analyzer: AsymmetryAnalyzer = DefaultAsymmetryAnalyzer()
    
    func test_어깨_엉덩이_수평이면_balanced() {
        let frame = PoseFrame.make(view: .front, [
            (.leftShoulder, CGPoint(x: 0.4, y: 0.7)),
            (.rightShoulder, CGPoint(x: 0.6, y: 0.7)),
            (.leftHip, CGPoint(x: 0.4, y: 0.4)),
            (.rightHip, CGPoint(x: 0.6, y: 0.4)),
            (.nose, CGPoint(x: 0.5, y: 0.9)),
            (.leftAnkle, CGPoint(x: 0.4, y: 0.05)),
            (.rightAnkle, CGPoint(x: 0.6, y: 0.05)),
        ])
        let r = analyzer.analyze(frame, heightCm: nil)
        XCTAssertEqual(r.shoulder.direction, .balanced)
        XCTAssertEqual(r.hip.direction, .balanced)
        XCTAssertEqual(r.shoulder.cm, nil)  // 키 없음
    }
    
    func test_우측_어깨_높음_rightHigher() {
        let frame = PoseFrame.make(view: .front, [
            (.leftShoulder, CGPoint(x: 0.4, y: 0.7)),
            (.rightShoulder, CGPoint(x: 0.6, y: 0.72)),  // 위쪽
            (.leftHip, CGPoint(x: 0.4, y: 0.4)),
            (.rightHip, CGPoint(x: 0.6, y: 0.4)),
            (.nose, CGPoint(x: 0.5, y: 0.9)),
            (.leftAnkle, CGPoint(x: 0.4, y: 0.05)),
            (.rightAnkle, CGPoint(x: 0.6, y: 0.05)),
        ])
        let r = analyzer.analyze(frame, heightCm: nil)
        XCTAssertEqual(r.shoulder.direction, .rightHigher)
        XCTAssertGreaterThan(r.shoulder.angleDegrees, 0)
    }
    
    func test_키_입력시_cm_환산() {
        // 머리에서 발목까지 정규화 거리 0.85, 키 170cm → 1정규화단위 = 200cm
        let frame = PoseFrame.make(view: .front, [
            (.leftShoulder, CGPoint(x: 0.4, y: 0.7)),
            (.rightShoulder, CGPoint(x: 0.6, y: 0.71)),  // 0.01 차이
            (.leftHip, CGPoint(x: 0.4, y: 0.4)),
            (.rightHip, CGPoint(x: 0.6, y: 0.4)),
            (.nose, CGPoint(x: 0.5, y: 0.9)),
            (.leftAnkle, CGPoint(x: 0.4, y: 0.05)),
            (.rightAnkle, CGPoint(x: 0.6, y: 0.05)),
        ])
        let r = analyzer.analyze(frame, heightCm: 170)
        XCTAssertNotNil(r.shoulder.cm)
        // 0.01 정규화 거리 × (170 / 0.85) ≈ 2cm
        XCTAssertEqual(r.shoulder.cm!, 2.0, accuracy: 0.5)
    }
}
```

- [ ] **Step 2: 테스트 실행, 실패 확인**

- [ ] **Step 3: DefaultAsymmetryAnalyzer.swift 구현**

```swift
import Vision
import CoreGraphics

final class DefaultAsymmetryAnalyzer: AsymmetryAnalyzer {
    
    /// 균형으로 판단할 각도 임계값 (도)
    private let balancedThreshold: Double = 0.5
    
    func analyze(_ frontFrame: PoseFrame, heightCm: Double?) -> AsymmetryResult {
        let shoulder = analyzePair(
            frontFrame, left: .leftShoulder, right: .rightShoulder, heightCm: heightCm
        )
        let hip = analyzePair(
            frontFrame, left: .leftHip, right: .rightHip, heightCm: heightCm
        )
        return AsymmetryResult(shoulder: shoulder, hip: hip)
    }
    
    private func analyzePair(
        _ frame: PoseFrame,
        left: VNHumanBodyPoseObservation.JointName,
        right: VNHumanBodyPoseObservation.JointName,
        heightCm: Double?
    ) -> AsymmetryResult.Difference {
        guard let lp = frame.point(left), let rp = frame.point(right) else {
            return AsymmetryResult.Difference(cm: nil, ratio: 0, angleDegrees: 0, direction: .balanced)
        }
        
        let angle = GeometryMath.absLineAngleFromHorizontal(lp, rp)
        let referenceWidth = GeometryMath.distance(lp, rp)
        let normalizedYDiff = abs(Double(lp.y - rp.y))
        let ratio = referenceWidth > 0 ? (normalizedYDiff / referenceWidth) : 0
        
        let direction: AsymmetryResult.Direction
        if angle < balancedThreshold {
            direction = .balanced
        } else if lp.y > rp.y {
            // Vision 좌표: Y 큰 쪽이 위. lp.y > rp.y면 왼쪽이 높음
            direction = .leftHigher
        } else {
            direction = .rightHigher
        }
        
        // cm 환산 — 키 있으면 머리-발목 정규화 거리로 환산 비율 계산
        var cm: Double? = nil
        if let height = heightCm,
           let nose = frame.point(.nose),
           let leftAnkle = frame.point(.leftAnkle),
           let rightAnkle = frame.point(.rightAnkle) {
            let ankleAvgY = Double(leftAnkle.y + rightAnkle.y) / 2
            let bodyPixelHeight = abs(Double(nose.y) - ankleAvgY)
            if bodyPixelHeight > 0 {
                let cmPerNormalized = height / bodyPixelHeight
                cm = normalizedYDiff * cmPerNormalized
            }
        }
        
        return AsymmetryResult.Difference(
            cm: cm,
            ratio: ratio,
            angleDegrees: angle,
            direction: direction
        )
    }
}
```

- [ ] **Step 4: 테스트 통과 확인**

- [ ] **Step 5: commit**

```bash
git add Domain/Asymmetry/ PoseAnalyzerTests/Asymmetry/
git commit -m "feat(asymmetry): add DefaultAsymmetryAnalyzer with TDD (어깨/엉덩이 좌우 비대칭)"
```

---

## Phase 8: UseCase

### Task 19: AnalyzeSessionUseCase + Mock PoseDetector

**파일/경로:**
- 생성: `PoseAnalyzer/Domain/UseCase/AnalyzeSessionUseCase.swift`
- 생성: `PoseAnalyzerTests/Helpers/MockPoseDetector.swift`
- 생성: `PoseAnalyzerTests/UseCase/AnalyzeSessionUseCaseTests.swift`

- [ ] **Step 1: MockPoseDetector 작성**

`MockPoseDetector.swift`:
```swift
import UIKit
@testable import PoseAnalyzer

final class MockPoseDetector: PoseDetector {
    var frontFrameToReturn: PoseFrame?
    var sideFrameToReturn: PoseFrame?
    var errorToThrow: Error?
    
    func detect(image: UIImage, view: SessionView) async throws -> PoseFrame {
        if let error = errorToThrow {
            throw error
        }
        switch view {
        case .front:
            return frontFrameToReturn ?? .empty(view: .front)
        case .side:
            return sideFrameToReturn ?? .empty(view: .side)
        }
    }
}
```

- [ ] **Step 2: 실패 테스트 작성**

`AnalyzeSessionUseCaseTests.swift`:
```swift
import XCTest
@testable import PoseAnalyzer

final class AnalyzeSessionUseCaseTests: XCTestCase {
    
    func test_정상_세션_8개_PostureResult_반환() async throws {
        let detector = MockPoseDetector()
        // 정면 사진: 어깨/엉덩이/머리 등
        detector.frontFrameToReturn = PoseFrame.make(view: .front, [
            (.leftShoulder, CGPoint(x: 0.4, y: 0.7)),
            (.rightShoulder, CGPoint(x: 0.6, y: 0.7)),
            (.leftHip, CGPoint(x: 0.4, y: 0.4)),
            (.rightHip, CGPoint(x: 0.6, y: 0.4)),
            (.leftEar, CGPoint(x: 0.45, y: 0.85)),
            (.rightEar, CGPoint(x: 0.55, y: 0.85)),
            (.leftKnee, CGPoint(x: 0.4, y: 0.25)),
            (.rightKnee, CGPoint(x: 0.6, y: 0.25)),
            (.leftAnkle, CGPoint(x: 0.4, y: 0.1)),
            (.rightAnkle, CGPoint(x: 0.6, y: 0.1)),
            (.nose, CGPoint(x: 0.5, y: 0.9)),
        ])
        // 측면 사진: 거북목/라운드숄더 등
        detector.sideFrameToReturn = PoseFrame.sideViewWithAngle(180, atJoints: (.leftEar, .leftShoulder, .leftHip))
        
        let evaluators: [PostureEvaluator] = [
            ForwardHeadEvaluator(),
            RoundShoulderEvaluator(),
            KyphosisEvaluator(),
            AnteriorPelvicTiltEvaluator(),
            KneeHyperextensionEvaluator(),
            ScoliosisEvaluator(),
            HeadTiltEvaluator(),
            KneeAlignmentEvaluator(),
        ]
        let useCase = AnalyzeSessionUseCase(
            detector: detector,
            evaluators: evaluators,
            asymmetryAnalyzer: DefaultAsymmetryAnalyzer()
        )
        
        let image = UIImage()
        let report = try await useCase.analyze(front: image, side: image, heightCm: 170)
        
        XCTAssertEqual(report.postures.count, 8)
        XCTAssertEqual(Set(report.postures.map { $0.type }), Set(PostureType.allCases))
        XCTAssertEqual(report.heightCmAtMeasure, 170)
    }
    
    func test_detector_에러시_throw() async {
        let detector = MockPoseDetector()
        detector.errorToThrow = PoseDetectionError.noPersonDetected
        
        let useCase = AnalyzeSessionUseCase(
            detector: detector,
            evaluators: [],
            asymmetryAnalyzer: DefaultAsymmetryAnalyzer()
        )
        
        do {
            _ = try await useCase.analyze(front: UIImage(), side: UIImage(), heightCm: nil)
            XCTFail("에러를 던져야 함")
        } catch let error as PoseDetectionError {
            XCTAssertEqual(error, PoseDetectionError.noPersonDetected)
        } catch {
            XCTFail("예상하지 못한 에러: \(error)")
        }
    }
}
```

- [ ] **Step 3: 테스트 실행, 실패 확인**

- [ ] **Step 4: AnalyzeSessionUseCase.swift 구현**

```swift
import Foundation
import UIKit

/// View가 호출하는 단일 진입점: 정면+측면 사진 → SessionReport
final class AnalyzeSessionUseCase {
    
    private let detector: PoseDetector
    private let evaluators: [PostureEvaluator]
    private let asymmetryAnalyzer: AsymmetryAnalyzer
    
    init(detector: PoseDetector, evaluators: [PostureEvaluator], asymmetryAnalyzer: AsymmetryAnalyzer) {
        self.detector = detector
        self.evaluators = evaluators
        self.asymmetryAnalyzer = asymmetryAnalyzer
    }
    
    func analyze(front: UIImage, side: UIImage, heightCm: Double?) async throws -> SessionReport {
        // 1) 두 사진 병렬 분석
        async let frontFrameTask = detector.detect(image: front, view: .front)
        async let sideFrameTask = detector.detect(image: side, view: .side)
        let frontFrame = try await frontFrameTask
        let sideFrame = try await sideFrameTask
        
        // 2) 각 Evaluator 실행 (해당 view에 맞춰 분배)
        var results: [PostureResult] = []
        for evaluator in evaluators {
            let frame = (evaluator.requiredView == .front) ? frontFrame : sideFrame
            results.append(evaluator.evaluate(frame))
        }
        
        // 3) 비대칭 분석 (정면 사진)
        let asymmetry = asymmetryAnalyzer.analyze(frontFrame, heightCm: heightCm)
        
        return SessionReport(
            id: UUID(),
            measuredAt: .now,
            frontImage: front,
            sideImage: side,
            frontFrame: frontFrame,
            sideFrame: sideFrame,
            postures: results,
            asymmetry: asymmetry,
            heightCmAtMeasure: heightCm
        )
    }
}
```

- [ ] **Step 5: 테스트 통과 확인**

- [ ] **Step 6: commit**

```bash
git add Domain/UseCase/AnalyzeSessionUseCase.swift PoseAnalyzerTests/UseCase/ PoseAnalyzerTests/Helpers/MockPoseDetector.swift
git commit -m "feat(usecase): add AnalyzeSessionUseCase with TDD (병렬 detect + 8 evaluator + asymmetry)"
```

---

## Phase 9: 영상 분석 인터페이스 (2차 대비, 구현 X)

### Task 20: MotionAnalyzer 프로토콜 정의 (구현 X)

**파일/경로:**
- 생성: `PoseAnalyzer/Domain/Motion/MotionAnalyzer.swift`
- 생성: `PoseAnalyzer/Domain/Motion/MotionResult.swift`

- [ ] **Step 1: MotionResult.swift 작성**

```swift
import Foundation

/// 영상 기반 동적 자세 분석 결과 (2차 확장용 — MVP에서는 사용 안 함)
struct MotionResult: Equatable {
    let timestamp: TimeInterval
    let motionType: String        // 향후: enum으로 ("squat", "running" 등)
    let phase: String             // 동작 단계 (예: "descent", "bottom", "ascent")
    let metrics: [String: Double] // 동작별 측정값 (예: ["knee_angle": 90, "depth": 0.4])
    let qualityScore: Double      // 0~1
}
```

- [ ] **Step 2: MotionAnalyzer.swift 작성**

```swift
import Foundation

/// 2차 영상 분석 인터페이스 (MVP에서는 구현 X)
/// 향후 SquatAnalyzer, RunningAnalyzer 등이 이 프로토콜을 구현
protocol MotionAnalyzer {
    var name: String { get }
    
    /// 시간순 PoseFrame 스트림을 받아 MotionResult 스트림 반환
    func analyze(_ stream: AsyncStream<PoseFrame>) -> AsyncStream<MotionResult>
}
```

- [ ] **Step 3: 빌드 확인 후 commit**

```bash
git add Domain/Motion/
git commit -m "feat(motion): define MotionAnalyzer protocol for future video analysis (2nd phase)"
```

---

## Phase 10: 데이터 레이어

### Task 21: SwiftData 모델 정의 (UserProfile, SessionRecord, PostureRecord)

**파일/경로:**
- 생성: `PoseAnalyzer/Data/SwiftData/UserProfile.swift`
- 생성: `PoseAnalyzer/Data/SwiftData/SessionRecord.swift`
- 생성: `PoseAnalyzer/Data/SwiftData/PostureRecord.swift`

- [ ] **Step 1: UserProfile.swift 작성**

```swift
import Foundation
import SwiftData

/// 사용자 프로필 (앱당 1개 인스턴스 유지)
@Model
final class UserProfile {
    var heightCm: Double?
    var updatedAt: Date
    
    init(heightCm: Double? = nil) {
        self.heightCm = heightCm
        self.updatedAt = .now
    }
}
```

- [ ] **Step 2: SessionRecord.swift 작성**

```swift
import Foundation
import SwiftData

/// 한 번의 측정 세션 (정면+측면 사진 1세트)
@Model
final class SessionRecord {
    @Attribute(.unique) var id: UUID
    var measuredAt: Date
    var frontImagePath: String      // 상대 경로 (Documents 기준)
    var sideImagePath: String
    var heightCmAtMeasure: Double?
    
    @Relationship(deleteRule: .cascade, inverse: \PostureRecord.session)
    var postures: [PostureRecord]
    
    // 비대칭 결과
    var asymmetryShoulderCm: Double?
    var asymmetryShoulderRatio: Double
    var asymmetryShoulderAngle: Double
    var asymmetryShoulderDirectionRaw: String
    var asymmetryHipCm: Double?
    var asymmetryHipRatio: Double
    var asymmetryHipAngle: Double
    var asymmetryHipDirectionRaw: String
    
    init(
        id: UUID = UUID(),
        measuredAt: Date = .now,
        frontImagePath: String,
        sideImagePath: String,
        heightCmAtMeasure: Double?,
        asymmetryShoulderCm: Double?,
        asymmetryShoulderRatio: Double,
        asymmetryShoulderAngle: Double,
        asymmetryShoulderDirection: AsymmetryResult.Direction,
        asymmetryHipCm: Double?,
        asymmetryHipRatio: Double,
        asymmetryHipAngle: Double,
        asymmetryHipDirection: AsymmetryResult.Direction
    ) {
        self.id = id
        self.measuredAt = measuredAt
        self.frontImagePath = frontImagePath
        self.sideImagePath = sideImagePath
        self.heightCmAtMeasure = heightCmAtMeasure
        self.postures = []
        self.asymmetryShoulderCm = asymmetryShoulderCm
        self.asymmetryShoulderRatio = asymmetryShoulderRatio
        self.asymmetryShoulderAngle = asymmetryShoulderAngle
        self.asymmetryShoulderDirectionRaw = asymmetryShoulderDirection.rawValue
        self.asymmetryHipCm = asymmetryHipCm
        self.asymmetryHipRatio = asymmetryHipRatio
        self.asymmetryHipAngle = asymmetryHipAngle
        self.asymmetryHipDirectionRaw = asymmetryHipDirection.rawValue
    }
    
    // 편의 접근자
    var asymmetryShoulderDirection: AsymmetryResult.Direction {
        AsymmetryResult.Direction(rawValue: asymmetryShoulderDirectionRaw) ?? .balanced
    }
    var asymmetryHipDirection: AsymmetryResult.Direction {
        AsymmetryResult.Direction(rawValue: asymmetryHipDirectionRaw) ?? .balanced
    }
}
```

- [ ] **Step 3: PostureRecord.swift 작성**

```swift
import Foundation
import SwiftData

/// 한 세션 안의 개별 자세 판정 결과
@Model
final class PostureRecord {
    @Attribute(.unique) var id: UUID
    var typeRaw: String              // PostureType.rawValue
    var statusRaw: String            // PostureStatus.rawValue
    var primaryMetric: Double
    var primaryMetricUnitRaw: String // PostureResult.MetricUnit.rawValue
    var confidence: Double
    var advice: String?
    
    var session: SessionRecord?
    
    init(
        id: UUID = UUID(),
        type: PostureType,
        status: PostureStatus,
        primaryMetric: Double,
        primaryMetricUnit: PostureResult.MetricUnit,
        confidence: Double,
        advice: String?
    ) {
        self.id = id
        self.typeRaw = type.rawValue
        self.statusRaw = status.rawValue
        self.primaryMetric = primaryMetric
        self.primaryMetricUnitRaw = primaryMetricUnit.rawValue
        self.confidence = confidence
        self.advice = advice
    }
    
    // 편의 접근자
    var type: PostureType { PostureType(rawValue: typeRaw) ?? .forwardHead }
    var status: PostureStatus { PostureStatus(rawValue: statusRaw) ?? .unmeasurable }
    var primaryMetricUnit: PostureResult.MetricUnit {
        PostureResult.MetricUnit(rawValue: primaryMetricUnitRaw) ?? .degree
    }
}
```

- [ ] **Step 4: 빌드 확인 후 commit**

```bash
git add Data/SwiftData/
git commit -m "feat(data): add SwiftData models (UserProfile, SessionRecord, PostureRecord)"
```

---

### Task 22: ImageStore (사진 파일 저장/로드 — TDD)

**파일/경로:**
- 생성: `PoseAnalyzer/Data/ImageStore.swift`
- 생성: `PoseAnalyzerTests/Data/ImageStoreTests.swift`

- [ ] **Step 1: 실패 테스트 작성**

```swift
import XCTest
@testable import PoseAnalyzer

final class ImageStoreTests: XCTestCase {
    
    var tempDir: URL!
    var store: ImageStore!
    
    override func setUpWithError() throws {
        tempDir = FileManager.default.temporaryDirectory.appendingPathComponent("ImageStoreTests-\(UUID())")
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        store = ImageStore(baseDirectory: tempDir)
    }
    
    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: tempDir)
    }
    
    func test_저장_로드_라운드트립() throws {
        let image = makeTestImage(color: .red)
        let sessionID = UUID()
        
        let path = try store.save(image, for: sessionID, view: .front)
        XCTAssertFalse(path.isEmpty)
        
        let loaded = store.load(path: path)
        XCTAssertNotNil(loaded)
    }
    
    func test_삭제_후_파일_없음() throws {
        let image = makeTestImage(color: .blue)
        let sessionID = UUID()
        _ = try store.save(image, for: sessionID, view: .front)
        _ = try store.save(image, for: sessionID, view: .side)
        
        try store.delete(for: sessionID)
        
        let sessionDir = tempDir.appendingPathComponent("sessions").appendingPathComponent(sessionID.uuidString)
        XCTAssertFalse(FileManager.default.fileExists(atPath: sessionDir.path))
    }
    
    func test_정면_측면_파일_분리() throws {
        let image = makeTestImage(color: .green)
        let sessionID = UUID()
        let frontPath = try store.save(image, for: sessionID, view: .front)
        let sidePath = try store.save(image, for: sessionID, view: .side)
        XCTAssertNotEqual(frontPath, sidePath)
        XCTAssertTrue(frontPath.contains("front"))
        XCTAssertTrue(sidePath.contains("side"))
    }
    
    private func makeTestImage(color: UIColor) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 10, height: 10))
        return renderer.image { ctx in
            color.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 10, height: 10))
        }
    }
}
```

- [ ] **Step 2: 테스트 실행, 실패 확인**

- [ ] **Step 3: ImageStore.swift 구현**

```swift
import UIKit

/// 사진 파일을 Documents 폴더에 저장·로드·삭제
final class ImageStore {
    
    private let baseDirectory: URL
    private let fileManager = FileManager.default
    
    init(baseDirectory: URL? = nil) {
        if let base = baseDirectory {
            self.baseDirectory = base
        } else {
            self.baseDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        }
    }
    
    enum ImageStoreError: Error {
        case encodingFailed
        case writeFailed(underlying: Error)
    }
    
    /// 사진 저장 후 상대 경로 반환
    @discardableResult
    func save(_ image: UIImage, for sessionID: UUID, view: SessionView) throws -> String {
        let sessionDir = baseDirectory
            .appendingPathComponent("sessions")
            .appendingPathComponent(sessionID.uuidString)
        try fileManager.createDirectory(at: sessionDir, withIntermediateDirectories: true)
        
        // 저장용 다운샘플링 (max 1024px)
        let downsized = image.downscaled(maxDimension: 1024)
        guard let data = downsized.jpegData(compressionQuality: 0.85) else {
            throw ImageStoreError.encodingFailed
        }
        
        let filename = "\(view.rawValue).jpg"
        let fileURL = sessionDir.appendingPathComponent(filename)
        do {
            try data.write(to: fileURL, options: .atomic)
        } catch {
            throw ImageStoreError.writeFailed(underlying: error)
        }
        
        // 상대 경로 (Documents 기준)
        return "sessions/\(sessionID.uuidString)/\(filename)"
    }
    
    /// 경로로 사진 로드
    func load(path: String) -> UIImage? {
        let url = baseDirectory.appendingPathComponent(path)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }
    
    /// 세션의 모든 사진 삭제
    func delete(for sessionID: UUID) throws {
        let sessionDir = baseDirectory
            .appendingPathComponent("sessions")
            .appendingPathComponent(sessionID.uuidString)
        if fileManager.fileExists(atPath: sessionDir.path) {
            try fileManager.removeItem(at: sessionDir)
        }
    }
}

// MARK: - UIImage Downscale

extension UIImage {
    /// 긴 변이 maxDimension을 넘지 않도록 축소 (작으면 원본 반환)
    func downscaled(maxDimension: CGFloat) -> UIImage {
        let longest = max(size.width, size.height)
        guard longest > maxDimension else { return self }
        let scale = maxDimension / longest
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
```

- [ ] **Step 4: 테스트 통과 확인**

- [ ] **Step 5: commit**

```bash
git add Data/ImageStore.swift PoseAnalyzerTests/Data/ImageStoreTests.swift
git commit -m "feat(data): add ImageStore with TDD (save/load/delete + downscaling)"
```

---

### Task 23: SessionRepository (SwiftData CRUD — TDD)

**파일/경로:**
- 생성: `PoseAnalyzer/Data/SessionRepository.swift`
- 생성: `PoseAnalyzerTests/Data/SessionRepositoryTests.swift`

- [ ] **Step 1: 프로토콜과 실패 테스트 작성**

```swift
import XCTest
import SwiftData
@testable import PoseAnalyzer

@MainActor
final class SessionRepositoryTests: XCTestCase {
    
    var container: ModelContainer!
    var tempDir: URL!
    var imageStore: ImageStore!
    var repository: SessionRepository!
    
    override func setUp() async throws {
        let schema = Schema([
            UserProfile.self, SessionRecord.self, PostureRecord.self
        ])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, configurations: [config])
        
        tempDir = FileManager.default.temporaryDirectory.appendingPathComponent("SessionRepoTests-\(UUID())")
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        imageStore = ImageStore(baseDirectory: tempDir)
        
        repository = SessionRepository(
            context: container.mainContext,
            imageStore: imageStore
        )
    }
    
    override func tearDown() async throws {
        try? FileManager.default.removeItem(at: tempDir)
    }
    
    func test_세션_저장_후_조회() async throws {
        let report = makeReport()
        try repository.save(report)
        
        let all = try repository.fetchAll()
        XCTAssertEqual(all.count, 1)
        XCTAssertEqual(all.first?.postures.count, 8)
    }
    
    func test_시간_역순_조회() async throws {
        let oldReport = makeReport(measuredAt: Date(timeIntervalSinceNow: -100))
        let newReport = makeReport(measuredAt: .now)
        try repository.save(oldReport)
        try repository.save(newReport)
        
        let all = try repository.fetchAll()
        XCTAssertEqual(all.first?.id, newReport.id)
        XCTAssertEqual(all.last?.id, oldReport.id)
    }
    
    func test_세션_삭제시_사진도_삭제() async throws {
        let report = makeReport()
        try repository.save(report)
        
        let sessionDir = tempDir
            .appendingPathComponent("sessions")
            .appendingPathComponent(report.id.uuidString)
        XCTAssertTrue(FileManager.default.fileExists(atPath: sessionDir.path))
        
        try repository.delete(id: report.id)
        
        XCTAssertFalse(FileManager.default.fileExists(atPath: sessionDir.path))
        let all = try repository.fetchAll()
        XCTAssertEqual(all.count, 0)
    }
    
    // MARK: - Helper
    
    private func makeReport(measuredAt: Date = .now) -> SessionReport {
        let image = UIGraphicsImageRenderer(size: CGSize(width: 10, height: 10)).image { ctx in
            UIColor.gray.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 10, height: 10))
        }
        let dummyFrame = PoseFrame.empty()
        let postures = PostureType.allCases.map { type in
            PostureResult(
                type: type, status: .normal, primaryMetric: 180,
                primaryMetricUnit: .degree,
                thresholds: Thresholds(normalRange: 170...360, cautionRange: 160...170, direction: .higherIsNormal),
                usedJointNames: [], confidence: 0.9, advice: nil
            )
        }
        let asymmetry = AsymmetryResult(
            shoulder: .init(cm: nil, ratio: 0, angleDegrees: 0, direction: .balanced),
            hip: .init(cm: nil, ratio: 0, angleDegrees: 0, direction: .balanced)
        )
        return SessionReport(
            id: UUID(), measuredAt: measuredAt,
            frontImage: image, sideImage: image,
            frontFrame: dummyFrame, sideFrame: dummyFrame,
            postures: postures, asymmetry: asymmetry, heightCmAtMeasure: 170
        )
    }
}
```

- [ ] **Step 2: 테스트 실행, 실패 확인**

- [ ] **Step 3: SessionRepository.swift 구현**

```swift
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
```

- [ ] **Step 4: 테스트 통과 확인**

- [ ] **Step 5: commit**

```bash
git add Data/SessionRepository.swift PoseAnalyzerTests/Data/SessionRepositoryTests.swift
git commit -m "feat(data): add SessionRepository with TDD (CRUD + cascade image delete)"
```

---

### Task 24: UserProfileRepository (키 저장/조회 — TDD)

**파일/경로:**
- 생성: `PoseAnalyzer/Data/UserProfileRepository.swift`
- 생성: `PoseAnalyzerTests/Data/UserProfileRepositoryTests.swift`

- [ ] **Step 1: 실패 테스트 작성**

```swift
import XCTest
import SwiftData
@testable import PoseAnalyzer

@MainActor
final class UserProfileRepositoryTests: XCTestCase {
    
    var container: ModelContainer!
    var repository: UserProfileRepository!
    
    override func setUp() async throws {
        let schema = Schema([UserProfile.self, SessionRecord.self, PostureRecord.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, configurations: [config])
        repository = UserProfileRepository(context: container.mainContext)
    }
    
    func test_초기에는_키_nil() throws {
        XCTAssertNil(try repository.getHeightCm())
    }
    
    func test_키_저장_후_조회() throws {
        try repository.updateHeightCm(170)
        XCTAssertEqual(try repository.getHeightCm(), 170)
    }
    
    func test_키_업데이트_시_단일_레코드_유지() throws {
        try repository.updateHeightCm(170)
        try repository.updateHeightCm(175)
        
        let descriptor = FetchDescriptor<UserProfile>()
        let all = try container.mainContext.fetch(descriptor)
        XCTAssertEqual(all.count, 1, "프로필 레코드는 단일 인스턴스 유지")
        XCTAssertEqual(try repository.getHeightCm(), 175)
    }
}
```

- [ ] **Step 2: 테스트 실행, 실패 확인**

- [ ] **Step 3: UserProfileRepository.swift 구현**

```swift
import Foundation
import SwiftData

/// 사용자 키 등 단일 프로필 저장/조회 (앱당 1개 레코드만 유지)
@MainActor
final class UserProfileRepository {
    
    private let context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    func getHeightCm() throws -> Double? {
        return try fetchProfile()?.heightCm
    }
    
    func updateHeightCm(_ value: Double?) throws {
        if let profile = try fetchProfile() {
            profile.heightCm = value
            profile.updatedAt = .now
        } else {
            let profile = UserProfile(heightCm: value)
            context.insert(profile)
        }
        try context.save()
    }
    
    private func fetchProfile() throws -> UserProfile? {
        let descriptor = FetchDescriptor<UserProfile>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        return try context.fetch(descriptor).first
    }
}
```

- [ ] **Step 4: 테스트 통과 확인**

- [ ] **Step 5: commit**

```bash
git add Data/UserProfileRepository.swift PoseAnalyzerTests/Data/UserProfileRepositoryTests.swift
git commit -m "feat(data): add UserProfileRepository with TDD (single instance height storage)"
```

---

## Phase 11: 앱 진입점 & DI

### Task 25: AppDependencies (의존성 컨테이너)

**파일/경로:**
- 생성: `PoseAnalyzer/App/AppDependencies.swift`

- [ ] **Step 1: AppDependencies.swift 작성**

```swift
import Foundation
import SwiftData
import UIKit

/// 앱 전역 의존성을 보관하고 주입하는 단순 Service Locator
/// SwiftUI Environment를 통해 View에 전달
@MainActor
final class AppDependencies: ObservableObject {
    
    let modelContainer: ModelContainer
    let imageStore: ImageStore
    let sessionRepository: SessionRepository
    let userProfileRepository: UserProfileRepository
    let analyzeSessionUseCase: AnalyzeSessionUseCase
    
    init(modelContainer: ModelContainer? = nil) {
        // 1) ModelContainer
        let schema = Schema([
            UserProfile.self,
            SessionRecord.self,
            PostureRecord.self,
        ])
        if let container = modelContainer {
            self.modelContainer = container
        } else {
            do {
                let config = ModelConfiguration(schema: schema)
                self.modelContainer = try ModelContainer(for: schema, configurations: [config])
            } catch {
                fatalError("ModelContainer 생성 실패: \(error)")
            }
        }
        
        // 2) ImageStore
        self.imageStore = ImageStore()
        
        // 3) Repository
        let context = self.modelContainer.mainContext
        self.sessionRepository = SessionRepository(context: context, imageStore: imageStore)
        self.userProfileRepository = UserProfileRepository(context: context)
        
        // 4) Domain
        let detector: PoseDetector = VisionPoseDetector()
        let evaluators: [PostureEvaluator] = [
            ForwardHeadEvaluator(),
            RoundShoulderEvaluator(),
            KyphosisEvaluator(),
            AnteriorPelvicTiltEvaluator(),
            KneeHyperextensionEvaluator(),
            ScoliosisEvaluator(),
            HeadTiltEvaluator(),
            KneeAlignmentEvaluator(),
        ]
        let asymmetryAnalyzer: AsymmetryAnalyzer = DefaultAsymmetryAnalyzer()
        self.analyzeSessionUseCase = AnalyzeSessionUseCase(
            detector: detector,
            evaluators: evaluators,
            asymmetryAnalyzer: asymmetryAnalyzer
        )
    }
}
```

- [ ] **Step 2: 빌드 확인**

```bash
xcodebuild build -project PoseAnalyzer.xcodeproj -scheme PoseAnalyzer -destination 'platform=iOS Simulator,name=iPhone 15' 2>&1 | tail -10
```

- [ ] **Step 3: commit**

```bash
git add App/AppDependencies.swift
git commit -m "feat(app): add AppDependencies container with Vision/SwiftData wiring"
```

---

### Task 26: PoseAnalyzerApp 진입점 수정 + Placeholder Root View

**파일/경로:**
- 수정: `PoseAnalyzer/App/PoseAnalyzerApp.swift`
- 삭제: `PoseAnalyzer/ContentView.swift` (기본 템플릿)
- 삭제: `PoseAnalyzer/Item.swift` (기본 SwiftData 템플릿)
- 생성: `PoseAnalyzer/Presentation/Common/RootPlaceholderView.swift` (Plan 2에서 교체)

- [ ] **Step 1: 기본 템플릿 파일 삭제**

Xcode에서 `ContentView.swift`, `Item.swift` 선택 → Delete → Move to Trash.

- [ ] **Step 2: RootPlaceholderView.swift 작성**

```swift
import SwiftUI

/// Plan 2에서 실제 탭 화면으로 교체될 임시 루트
struct RootPlaceholderView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "figure.stand")
                .font(.system(size: 80))
                .foregroundStyle(.tint)
            Text("PoseAnalyzer")
                .font(.largeTitle.bold())
            Text("Foundation 완료. UI는 Plan 2에서 작성합니다.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .padding()
    }
}

#Preview {
    RootPlaceholderView()
}
```

- [ ] **Step 3: PoseAnalyzerApp.swift 수정**

기존 SwiftData 템플릿 코드 전부 대체:

```swift
import SwiftUI
import SwiftData

@main
struct PoseAnalyzerApp: App {
    
    @StateObject private var dependencies = AppDependencies()
    
    var body: some Scene {
        WindowGroup {
            RootPlaceholderView()
                .environmentObject(dependencies)
                .modelContainer(dependencies.modelContainer)
        }
    }
}
```

- [ ] **Step 4: 빌드 + 시뮬레이터 실행 확인**

`⌘R`. 시뮬레이터에서 "PoseAnalyzer / Foundation 완료" 화면이 보여야 함.

- [ ] **Step 5: commit**

```bash
git add App/ Presentation/Common/RootPlaceholderView.swift
git rm PoseAnalyzer/ContentView.swift PoseAnalyzer/Item.swift
git commit -m "feat(app): wire AppDependencies into PoseAnalyzerApp with placeholder root"
```

---

## Phase 12: 마무리

### Task 27: 전체 단위테스트 통과 확인 + Vision smoke test

**파일/경로:**
- 생성: `PoseAnalyzerTests/Detection/VisionPoseDetectorSmokeTests.swift`
- 생성: `PoseAnalyzerTests/Fixtures/images/normal_front.jpg` (실제 인물 정면 사진 1장 — 본인 또는 무료 stock)
- 생성: `PoseAnalyzerTests/Fixtures/images/normal_side.jpg`

- [ ] **Step 1: 인물 사진 fixture 준비**

`PoseAnalyzerTests/Fixtures/images/` 폴더에 정면·측면 사진 각 1장씩 추가.
- 본인 사진 또는 저작권 free 사진 (Unsplash 등)
- 전신이 다 보이고 1명만 있는 사진
- 사진을 Xcode 프로젝트에 추가 (PoseAnalyzerTests 타겟에 포함)
- Build Phases → Copy Bundle Resources에 포함 확인

- [ ] **Step 2: smoke test 작성**

```swift
import XCTest
@testable import PoseAnalyzer

final class VisionPoseDetectorSmokeTests: XCTestCase {
    
    func test_정면_사진_사람_인식_성공() async throws {
        let bundle = Bundle(for: type(of: self))
        guard let url = bundle.url(forResource: "normal_front", withExtension: "jpg"),
              let data = try? Data(contentsOf: url),
              let image = UIImage(data: data) else {
            XCTFail("fixture 사진 로드 실패")
            return
        }
        
        let detector = VisionPoseDetector()
        let frame = try await detector.detect(image: image, view: .front)
        
        // 어깨 한 쌍은 신뢰도 충분히 잡혀야 함
        XCTAssertTrue(frame.areReliable([.leftShoulder, .rightShoulder]),
                      "사람 인물 사진이면 양 어깨는 잡혀야 함")
    }
    
    func test_측면_사진_사람_인식_성공() async throws {
        let bundle = Bundle(for: type(of: self))
        guard let url = bundle.url(forResource: "normal_side", withExtension: "jpg"),
              let data = try? Data(contentsOf: url),
              let image = UIImage(data: data) else {
            XCTFail("fixture 사진 로드 실패")
            return
        }
        
        let detector = VisionPoseDetector()
        let frame = try await detector.detect(image: image, view: .side)
        
        // 측면이라 한쪽 어깨/엉덩이는 반드시 잡혀야 함
        let leftOk = frame.areReliable([.leftShoulder, .leftHip])
        let rightOk = frame.areReliable([.rightShoulder, .rightHip])
        XCTAssertTrue(leftOk || rightOk, "한쪽 측면 라인은 잡혀야 함")
    }
}
```

- [ ] **Step 3: 전체 테스트 실행**

Xcode `⌘U`. 모든 테스트 통과해야 함:
- GeometryMathTests (6+ 케이스)
- ForwardHeadEvaluatorTests (6 케이스)
- RoundShoulderEvaluatorTests
- KyphosisEvaluatorTests
- AnteriorPelvicTiltEvaluatorTests
- KneeHyperextensionEvaluatorTests
- ScoliosisEvaluatorTests
- HeadTiltEvaluatorTests
- KneeAlignmentEvaluatorTests
- AsymmetryAnalyzerTests
- AnalyzeSessionUseCaseTests
- ImageStoreTests
- SessionRepositoryTests
- UserProfileRepositoryTests
- VisionPoseDetectorSmokeTests

- [ ] **Step 4: 빌드 경고 정리**

`⌘B` 결과의 Warning을 확인하고 의미 있는 것 수정 (deprecation 등). 일부 SwiftData @MainActor 경고는 무시 가능.

- [ ] **Step 5: 시뮬레이터 실행 확인**

`⌘R`. "Foundation 완료" 화면이 정상적으로 보임.

- [ ] **Step 6: commit**

```bash
git add PoseAnalyzerTests/Detection/ PoseAnalyzerTests/Fixtures/
git commit -m "test: add Vision smoke tests with real image fixtures"
```

- [ ] **Step 7: Plan 1 완료 tag**

```bash
git tag plan-1-foundation-complete
```

---

## ✅ Plan 1 완료 정의

다음이 모두 만족되면 Plan 1 완료:

- [ ] Xcode 프로젝트 빌드 성공 (시뮬레이터에서 placeholder 화면 정상 표시)
- [ ] 8개 Evaluator 각각 단위테스트 통과 (각 4-5 케이스 이상)
- [ ] GeometryMath 단위테스트 통과
- [ ] AsymmetryAnalyzer 단위테스트 통과
- [ ] AnalyzeSessionUseCase 단위테스트 통과 (Mock detector)
- [ ] ImageStore 단위테스트 통과
- [ ] SessionRepository 단위테스트 통과 (in-memory SwiftData)
- [ ] UserProfileRepository 단위테스트 통과
- [ ] VisionPoseDetector smoke test 통과 (실제 인물 사진)
- [ ] 모든 commit이 의미 있는 단위로 분리됨
- [ ] `plan-1-foundation-complete` git tag 생성

---

## ⏭ 다음 단계 (Plan 2)

Plan 1이 완료되면 Plan 2 작성·실행:
- 모든 UI 화면 (Home, MeasurementWizard, Camera, AnalysisResult, History, Trend, Settings)
- 사진 입력 흐름 (카메라 + PhotosPicker)
- 결과 화면의 관절 오버레이 (Canvas)
- Swift Charts 추이 그래프
- UI 테스트 (핵심 흐름 3-5개)
- 권한 처리 흐름

Plan 2는 Plan 1이 완료되고 사용자 리뷰 후 작성됩니다.
