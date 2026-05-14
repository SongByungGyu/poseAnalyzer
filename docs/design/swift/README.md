# SwiftUI handoff — Camera capture screen redesign

Drop-in replacement for the PoseAnalyzer iOS app's camera capture overlay.

## File

| File | Replaces |
|---|---|
| `PoseGuideOverlay.swift` | `PoseAnalyzer/Presentation/Measurement/PoseGuideOverlay.swift` |

## Variant B 구현

이 파일은 **Variant B** — clinical / 측정 도구 톤 — 의 SwiftUI 구현입니다.

- **외곽선**: 흰색 2pt 점선 (`dash: [6, 6]`). 내부는 3% 흰색으로 살짝 채워 영역 인지를 돕지만 카메라 피드는 그대로 보임.
- **십자선 마커**: 모든 측정 관절에 `Color.brandMint` 십자선 (반지름 8pt, lineWidth 1.5pt, round cap). 점보다 "이 정확한 지점에 맞추세요"라는 의도가 강함.
- **측면 plumb-line**: 귀→발목까지 세로 정렬선 + "정렬선" 캡슐 라벨. 거북목 / 흉추후만 / 골반전방경사 측정 기준을 시각화.
- **정면 정렬선**: 양 어깨 / 양 골반 가로 점선. 척추측만 / 어깨 비대칭 측정 기준.
- **한글 관절 라벨**: 측면에만 (귀·어깨·엉덩이·무릎·발목). 정면은 양쪽 페어가 있어 라벨이 빽빽해져 생략.
- **상단 STEP 배지**: indigo 숫자 칩이 들어간 vibrancy 캡슐. 기존 "정면 가이드" 단순 캡슐을 교체.

## 시그니처

기존 `PoseGuideOverlay`와 **동일**합니다. drop-in.

```swift
// CustomCameraView.swift, line 36 부근:
PoseGuideOverlay(view: view)              // ← 기존 그대로 동작
PoseGuideOverlay(view: view, step: 1)     // ← 새 옵션: STEP 배지 표시
```

`step` 파라미터는 `Optional<Int>` — nil이면 상단 배지에 숫자 없이 제목만 표시됩니다.

## 사용한 디자인 시스템 토큰

| 사용처 | 토큰 |
|---|---|
| 십자선·plumb-line·정렬선 | `Color.brandMint` |
| STEP 숫자 칩 | `Color.brandPrimary` |
| 본문 안내 텍스트 | `.appCallout` |
| STEP 캡슐 텍스트 | `.appMicro` |
| 패딩 | `AppSpacing.s2 / s3 / s5 / s10` |

브랜드 외 새 색은 없습니다.

## 검토해주세요

1. **실루엣 사이즈** — `0.62 × 0.72` (proxy의 width × height 비율) 로 중앙 배치. iPhone에 따라 다리가 너무 짧거나 머리가 island에 닿을 수 있어 실기 확인 필요. `body` 안의 두 상수만 조절하면 됩니다.
2. **하단 컨트롤 (셔터, 라이브러리, 플래시)** — 이 파일에는 손대지 않았습니다. `CustomCameraView.swift`에 있습니다. 같이 다듬을지 알려주세요.
3. **3-segment progress bar** — mockup 하단에 있던 그것. `MeasurementWizardView` 레벨에서 처리해야 자연스럽고, 이 overlay에는 넣지 않았습니다.
4. **dim 마스크 모양** — 현재 RoundedRectangle 60pt radius 라운드. 실루엣 그대로의 모양(머리/몸/다리 윤곽선)을 따라 mask 하고 싶으면 `guideArea`를 `bodyPath.scale(1.1)`로 바꾸면 됩니다 (실루엣 외부 dim이 더 타이트해짐).

문제 있으면 알려주세요. 다음 단계로 `CustomCameraView.swift`의 하단 컨트롤 + 진행 바를 다듬는 작업이 자연스럽습니다.
