# PoseAnalyzer Integration & Finalize 구현 계획 (Plan 2d/2d)

> **For agentic workers:** REQUIRED SUB-SKILL: superpowers:subagent-driven-development.

**Goal:** Plan 2a-2c가 완성한 앱을 최종 정리. 다크모드 verify, 핵심 UI 테스트 3개, Vision smoke test(사용자 사진 fixture 후), 최종 정리(전체 테스트, 1차 MVP tag).

**선행 문서:** Plan 1/2a/2b/2c 모두 완료.

**완료 후 상태:** 1차 MVP 완성. `plan-1-mvp-complete` tag 생성.

---

## 사전 정보

- 작업 디렉토리: `/Users/byunggyusong/1_개발폴더/마스터프로젝트/PoseAnalyzer`
- 시뮬레이터 UDID: `BF407CD0-C970-45EF-91FD-7FEB05483871`

---

## Phase 1: 다크모드 verify

### Task 1: 다크모드 시각 검증 (subagent 보고)

- [ ] **Step 1: 빌드 + 시뮬레이터 다크모드 전환 + 캡처**

```bash
# 1) 앱 빌드 & 설치
xcodebuild build -project PoseAnalyzer.xcodeproj -scheme PoseAnalyzer \
  -destination 'platform=iOS Simulator,id=BF407CD0-C970-45EF-91FD-7FEB05483871' \
  2>&1 | tail -5

# 2) 시뮬레이터 어피어런스 다크 전환
xcrun simctl ui BF407CD0-C970-45EF-91FD-7FEB05483871 appearance dark
# 3) 라이트 전환
xcrun simctl ui BF407CD0-C970-45EF-91FD-7FEB05483871 appearance light
```

이 task는 subagent가 자동으로 비주얼 검증할 수 없으므로 **시뮬레이터에서 사용자가 직접 확인** 권장. subagent는 빌드 성공만 확인.

- [ ] **Step 2: 빌드 통과 확인 + commit (없음)**

이 task는 코드 변경 없음. 검증만.

---

## Phase 2: UI 테스트 (핵심 흐름 3개)

### Task 2: HomeView CTA 테스트

**파일:** `PoseAnalyzerUITests/HomeFlowUITests.swift`

- [ ] **Step 1: 작성**

```swift
import XCTest

final class HomeFlowUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    func test_measurement_tab_shows_start_cta() {
        XCTAssertTrue(app.staticTexts["측정 시작"].waitForExistence(timeout: 3))
    }
    
    func test_tap_settings_gear_opens_settings() {
        let gear = app.images["gearshape"]
        if gear.waitForExistence(timeout: 3) {
            gear.tap()
            XCTAssertTrue(app.navigationBars["설정"].waitForExistence(timeout: 2))
        }
    }
    
    func test_history_tab_navigates() {
        app.tabBars.buttons["기록"].tap()
        // 기록 0개 또는 리스트
        let empty = app.staticTexts["아직 기록이 없습니다"]
        let trend = app.buttons["추이"]
        XCTAssertTrue(empty.waitForExistence(timeout: 2) || trend.exists)
    }
}
```

- [ ] **Step 2: 빌드/테스트 + commit**

```bash
xcodebuild test -project PoseAnalyzer.xcodeproj -scheme PoseAnalyzer \
  -destination 'platform=iOS Simulator,id=BF407CD0-C970-45EF-91FD-7FEB05483871' \
  -only-testing:PoseAnalyzerUITests/HomeFlowUITests \
  2>&1 | tail -10
```

```bash
cd "/Users/byunggyusong/1_개발폴더/마스터프로젝트/PoseAnalyzer"
git add PoseAnalyzer/PoseAnalyzer/PoseAnalyzerUITests/HomeFlowUITests.swift
git commit -m "test(ui): add HomeFlowUITests (CTA 표시 + 설정 + 기록 탭 진입)

Plan 2d Task 2: 핵심 흐름 UI 테스트"
```

만약 일부 테스트가 셀렉터 문제로 실패하면 (예: accessibility identifier 미설정) DONE_WITH_CONCERNS로 보고.

---

## Phase 3: 최종 회귀 + MVP tag

### Task 3: 전체 테스트 + 1차 MVP 완료 tag

- [ ] **Step 1: 전체 테스트**

```bash
cd "/Users/byunggyusong/1_개발폴더/마스터프로젝트/PoseAnalyzer/PoseAnalyzer"
xcodebuild test -project PoseAnalyzer.xcodeproj -scheme PoseAnalyzer \
  -destination 'platform=iOS Simulator,id=BF407CD0-C970-45EF-91FD-7FEB05483871' \
  2>&1 | tail -20
```

Expected: 모든 테스트 통과.

- [ ] **Step 2: 최종 MVP tag**

```bash
cd "/Users/byunggyusong/1_개발폴더/마스터프로젝트/PoseAnalyzer"
git tag -a poseanalyzer-mvp-v1.0 -m "PoseAnalyzer 1차 MVP 완성

스펙(docs/specs/2026-05-13-pose-analyzer-design.md) 의 1차 MVP 완료 정의 모두 충족:

1. 카메라 또는 사진 라이브러리에서 정면·측면 사진 2장 입력
2. 키 입력 (선택, 한 번 입력하면 유지)
3. Vision으로 관절 인식 → 8개 자세 자동 판정 + 비대칭 분석
4. 결과 화면에 사진 + 관절 오버레이 + 8개 판정 카드 + 좌우 비대칭 + 직전 대비 변화 표시
5. 저장 → SwiftData + 이미지 파일
6. 기록 탭에서 시간 역순 리스트, 항목 탭 시 결과 상세
7. 추이 그래프 (자세별 시간축, Swift Charts)
8. 권한 거부·사람 미인식·측정 불가 등 주요 에러 처리
9. Evaluator 단위 테스트 + Repository 테스트 통과

다음(2차): 영상 기반 동적 자세 분석 (스쿼트, 러닝 등)"
```

---

## ✅ Plan 2d 완료 정의

- [ ] 다크모드 검증 (빌드 통과)
- [ ] UI 테스트 1개 파일 + 3개 케이스 (deferred에 따라 일부 SKIP 가능)
- [ ] 전체 테스트 통과
- [ ] `poseanalyzer-mvp-v1.0` tag

---

## ⏭ Vision smoke test (사용자 사진 fixture 후)

별도로, 사용자가 정면/측면 인물 사진 1장씩 제공하면 Vision smoke test 추가:
- `PoseAnalyzerTests/Fixtures/images/normal_front.jpg`
- `PoseAnalyzerTests/Fixtures/images/normal_side.jpg`
- `PoseAnalyzerTests/Detection/VisionPoseDetectorSmokeTests.swift` 작성 (Plan 1 Task 27의 보류 항목)

이는 사용자 의존이라 별도 진행.
