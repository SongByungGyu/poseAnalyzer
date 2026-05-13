# UI Kit · iOS app

Pixel-fidelity recreation of the PoseAnalyzer iOS app per the spec at `source/spec.md`.

> ⚠️ **No Swift source exists.** This kit is built from the *functional* spec, not from running code. It is a strong design proposal for how the spec should look, not a documentation of an already-built app.

## Files

| File | What |
|---|---|
| `index.html` | Live interactive prototype. Open this for a clickable demo. |
| `ios-frame.jsx` | iOS 26 device bezel + status bar (starter component) |
| `components.jsx` | Primitives: `StatusBadge`, `PrimaryButton`, `Icon`, `Card`, `NavTop`, `TabBar`, `PoseSilhouette`, plus shared data `POSE_TYPES`, `STATUS_COLOR`, `STATUS_LABEL` |
| `screens.jsx` | Screen components: `HomeScreen`, `WizardScreen`, `AnalyzingScreen`, `ResultScreen`, `HistoryScreen`, `TrendScreen`, `PostureResultCard` |
| `app.jsx` | Root with screen-switching state + mock data |

## Click-through flow demonstrated in `index.html`

```
Home (측정 tab)
  └─ "측정 시작" → Wiz 1 (정면)
       → "촬영" → Wiz 2 (측면)
       → "촬영" → Wiz 3 (키 입력)
       → "분석 시작" → Analyzing (breathing loader, ~1.8s)
       → Result (8 cards + 비대칭 + 직전 대비 변화)
            ├─ "다시 측정" → Home
            └─ "저장하기" → History

History (기록 tab)
  ├─ row tap → Result (read-only)
  └─ trending-up icon → Trend (Swift Charts mock)
```

## Coverage

Implemented to match the spec's nine view list:
- ✅ HomeView (entry point + recent + 8 conditions teaser)
- ✅ MeasurementWizardView (3 steps)
- ✅ CameraView — represented by the wizard step with shutter + library buttons; live camera preview is faked with a silhouette + dashed guide overlay
- ✅ AnalyzingView (breathing pulse, two-phase text)
- ✅ AnalysisResultView (two photos + joint overlay + 8 cards + 비대칭 + delta)
- ✅ HistoryListView (4 sample sessions, 8 status dots per row, delta vs previous)
- ✅ TrendView (Swift Charts mock — line graph with normal/caution/suspect bands, pose selector, 7일/30일/전체 segmented control)
- ➖ SettingsView — gear icon present in nav, no destination screen mocked (single setting per spec)
- ➖ PermissionView — error pattern shown via wizard guidance, no dedicated screen mocked

## Components — usage notes

### `<StatusBadge status="normal|caution|suspect|unknown" large tone="soft|solid"/>`
The single source of truth for the 4-step judgment scale. Always pair color with text and dot (color-blind safe).

### `<PostureResultCard pose={POSE_TYPES[0]} />`
The 8x repeating tile from the result screen. Carries a 4px left status strip, a tabular-num metric readout, and a gauge marker positioned by status.

### `<PoseSilhouette view="front|side" joints status?/>`
Faked photo + joint overlay. Used as both the wizard guide visual and the result-screen photo. **In production**, the photo would be a real `UIImage` and the overlay would be a `PoseOverlayView` per spec §3.

### `<NavTop title subtitle leftIcon rightIcon onLeft onRight/>`
Custom top nav (we don't use `IOSNavBar` from the starter because we need a `subtitle` for the wizard step counter `STEP 2 / 3`).

### `<TabBar active onChange/>`
iOS-style vibrancy tab bar. Two tabs hardcoded — 측정 (camera) and 기록 (bar-chart).

## Caveats specific to this kit

- **Camera preview is faked.** A real implementation would use `AVCaptureSession` (spec §3). The dashed guide overlay is real and reusable.
- **The "two photos" at the top of the result screen don't sticky-collapse on scroll.** The spec calls for this; not implemented in the mock.
- **No edit-on-tap for height.** Spec says you can change height from settings or the result screen; not wired.
- **TrendView chart is a single mock dataset.** No real Swift Charts — just an SVG path with threshold bands. The visual language (bands, line + nodes, threshold labels) is what the iOS Charts implementation should target.
- **Icons are Lucide stand-ins for SF Symbols.** Swap to `Image(systemName:)` in Swift.
