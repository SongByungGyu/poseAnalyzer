# PoseAnalyzer Design System

> 사용자가 사진을 찍으면 해당 사진을 분석해서 현재 자세의 문제점을 제시합니다.
> *Take two photos — front and side — and PoseAnalyzer identifies eight posture issues from your joints, then tracks how they change over time.*

This design system supports the visual + interaction language of **PoseAnalyzer**, an iOS-native posture-analysis app for the Korean market.

---

## ⚠️ Important context for the reader

The "codebase" provided to build this system was a **single spec document**, not running visual code:
- `source/spec.md` — full Korean design spec (functional design, architecture, algorithms, data models, error handling, test strategy). 627 lines.
- Original location: `PoseAnalyzer/docs/specs/2026-05-13-pose-analyzer-design.md`
- No Swift code, no UI screenshots, no logos, no Figma — none of it exists yet.

This means **the visual direction in this system is invented**, not extracted. It is grounded in:
- the spec's functional vocabulary (8 posture types, 4-step judgment scale, two-tab structure, Korean UI text),
- Apple HIG conventions (the spec is iOS 17+ SwiftUI),
- and a calm, clinical-but-warm wellness aesthetic appropriate for a Korean posture/health app.

Anything in this system should be considered **a strong proposal to react to**, not a record of decisions already made. See "ASKS FOR THE USER" at the bottom.

---

## Product overview

**PoseAnalyzer** is an iOS app (iOS 17+, Swift / SwiftUI, no third-party libs) that uses Apple Vision to analyze body joints from two photos — front and side — and identifies eight posture conditions, plus left/right asymmetry, plus trend over time.

### The eight posture conditions
| Korean | English | View | Method |
|---|---|---|---|
| 거북목 | Forward head posture | side | ear–shoulder–hip angle |
| 라운드숄더 | Round shoulder | side | shoulder/ear horizontal distance |
| 흉추 후만증 | Kyphosis | side | neck–shoulder–hip angle |
| 골반 전방경사 | Anterior pelvic tilt | side | shoulder–hip–knee angle |
| 무릎 과신전 | Knee hyperextension | side | hip–knee–ankle angle |
| 척추측만 | Scoliosis | front | shoulder + hip line tilt |
| 머리 좌우 기울기 | Head tilt | front | ear-line tilt |
| 무릎 X자/O자 | Genu valgum/varum | front | leg-angle pair |

### The 4-step judgment scale (drives the entire visual language)
`정상 🟢 normal` · `주의 🟡 caution` · `의심 🟠 suspect` · `측정 불가 ⚪ unmeasurable`

Every result card, chart point, badge, and history row maps to one of these four states. This scale is the most important pattern in the system — **everything color-coded must use these tokens** (`--status-normal`, `--status-caution`, `--status-suspect`, `--status-unknown`).

### Two-tab structure
1. **📷 측정 (Measurement)** — Home → 3-step wizard (front photo → side photo → height) → Analyzing → Result
2. **📊 기록 (History)** — list of past sessions → tap for read-only result, or tap "추이" for Swift Charts trend graphs

A gear ⚙️ in the top-right of Home opens Settings.

---

## Index — files in this system

| Path | What's in it |
|---|---|
| `README.md` | this file |
| `SKILL.md` | Agent Skills front-matter for downloading and using this system in Claude Code |
| `colors_and_type.css` | All tokens (color, type, spacing, radii, shadows, motion) + base element styles |
| `source/spec.md` | The original Korean design spec — the only canonical source of truth |
| `fonts/` | Local font hosting target (currently empty — see CAVEATS) |
| `assets/` | Logos, icons, illustrations |
| `preview/` | Static HTML cards for the Design System tab |
| `ui_kits/ios_app/` | The iOS app UI kit — components + interactive index.html |

---

## CONTENT FUNDAMENTALS

### Language
- **Primary language is Korean.** All UI strings are Korean. English appears only in metric units (`cm`, `°`) and developer-facing strings.
- Numerical metrics use **Latin digits** with tabular figures (`170°`, `1.8 cm`, `7일`).

### Voice & tone
- **Calm, clinical-but-kind.** This is a posture/health app, not a fitness drill app. No "💪 GO!!" energy. No medical scolding either.
- **Neutral observer voice.** The app reports what it sees ("우측 어깨가 1.8cm 높음" — "Right shoulder is 1.8cm higher") rather than commanding ("어깨 펴세요!" — "Straighten your shoulders!").
- **Use 합니다체 (formal-polite)**, not 해요체 (casual-polite) and not 한다체 (plain).
  - ✅ "측정을 시작합니다" — "Beginning measurement"
  - ✅ "사람을 인식할 수 없습니다" — "Could not recognize a person"
  - ❌ "측정 시작할게요!" — too casual
  - ❌ "사람 못 찾음" — too curt

### Pronouns
- **No "I" / "you" voice.** The app does not refer to itself as "저" (I) or address the user as "당신" (you). It states facts or actions.
  - ✅ "측정을 다시 시도해주세요" — "Please try measuring again" (imperative-polite without naming the user)
  - ❌ "당신의 자세를 분석했습니다" — "I analyzed your posture" — too anthropomorphic

### Casing & punctuation
- No exclamation marks in normal UI states. Reserved for errors that genuinely need attention — and even then, prefer a calm tone.
- No emoji in body copy. The four status emojis (🟢🟡🟠⚪) are *icon-replacement* glyphs, not decoration — and we use color + label + icon together, never emoji alone (color-blind accessibility, per spec §6).
- Buttons use short verb-noun phrases: "측정 시작", "다시 찍기", "사용하기", "저장하기".
- Section headers are nominal: "최근 측정", "오늘의 분석", "이전 측정 대비".

### Vibe
- Quiet confidence, not enthusiasm.
- Numbers + visualization do the talking; copy stays out of the way.
- Treat the user's body data with respect — neutral language, no judgement, no "you have bad posture" framing.

### Examples (from spec + style-derived)
| Surface | Korean string | Notes |
|---|---|---|
| Home CTA | `측정 시작` | 4 chars — short verb phrase |
| Wizard step | `Step 2 / 3 · 측면 사진` | step counter + label, no fluff |
| Loading | `관절 인식 중…` → `자세 분석 중…` | progressive states, with ellipsis |
| Result card | `거북목 · 주의` | name · status, separated by middle dot |
| Asymmetry | `우측 어깨가 1.8cm 높음` | direction + amount + verb-as-adjective |
| Change vs prev | `직전 대비 +2° 개선` | delta + direction, no exclamation |
| Empty state | `아직 기록이 없습니다` | declarative, never "yet" pressure |
| Error | `사람을 인식할 수 없습니다.` | neutral fact + 다시 시도 button |
| Permission | `자세 분석을 위해 카메라 접근이 필요합니다.` | reason-first, request-second |

---

## VISUAL FOUNDATIONS

### Color
- **Primary: Pose Indigo `#3B5BDB`** — clean, trustworthy, distinct from any status color so it can never be confused with a judgment. Used for CTAs, focus, active tab, links.
- **Secondary mint `#56BAB0`** — wellness highlight, joint-overlay lines on photos, progress indicators.
- **Status palette** is the most important color decision in the app and maps directly to spec's 4 judgment levels:
  - 정상 normal `#22A06B` (calm green, never neon)
  - 주의 caution `#D9A106` (amber, not yellow-yellow)
  - 의심 suspect `#E0683A` (burnt orange — *not red*, because the app is not diagnosing illness)
  - 측정 불가 unknown `#8A94A6` (neutral slate)
- **Neutrals** are warm-cool slate (slight blue cast), not pure gray. iOS-aligned.
- **Background hierarchy**:
  - `--bg-canvas` (`#F4F6FA`) is the app background — tinted, warmer than pure `#F2F2F7` (stock iOS) to feel less clinical
  - `--bg-surface` (`#FFFFFF`) for cards and sheets
  - `--bg-surface-2` for nested cards
- **Dark mode** is a full first-class theme (spec §6 mandates it). Deep slate `#0B0F18` canvas, `#161B26` surfaces. All status colors have dedicated dark-mode-tinted-bg variants.

### Type
- **Pretendard** is the only display + body family. It is the de-facto standard for Korean iOS UI: optimized Hangul widths, Latin glyphs that match SF Pro's metrics, full weight range.
  - Substitution flagged: Pretendard ships from a jsDelivr CDN — local font files are **not yet** hosted (timeouts). See CAVEATS.
- Type ramp is iOS-aligned (Display 34 / H1 28 / H2 22 / H3 18 / Title 17 / Body 16 / Callout 15 / Caption 13 / Micro 11) but slightly larger across the board because Korean characters are square and benefit from more vertical room.
- **Tabular numerics everywhere** for angles/cm/dates (`font-variant-numeric: tabular-nums`). Critical: result cards constantly compare numbers across rows.
- A `.t-metric` style (40px tabular bold) for hero numbers — the angle / cm readouts on result cards.
- No serif. No display font. One family, eight weights.

### Spacing
- 4pt scale: 4 / 8 / 12 / 16 / 20 / 24 / 32 / 40 / 56 / 72. Standard iOS.
- Card inset: 16–20px on phone. Stack gap: 12–16px.
- Result cards: 16px outer pad, 12px inter-element gap.

### Backgrounds
- **No gradients** as primary backgrounds. The brand reads better as flat tinted surfaces.
- **No hand-drawn illustrations.** This app should feel like a measurement tool, not a coach.
- **No stock fitness photography.** When imagery is needed (e.g. wizard guidance), use minimal vector silhouettes or photographs of the user's own body (the whole point of the app).
- **Joint overlays** on photos use a thin (2px) Pose Indigo line with mint nodes at joints, with a soft drop shadow for legibility over varied photo backgrounds. Confidence < 0.3 = node dimmed to 30% opacity.

### Animation
- **Calm, never bouncy.** iOS spring easing only where iOS uses it natively (sheet present, button press); everything else is `cubic-bezier(0.16, 1, 0.3, 1)` ("ease-out") at 220ms.
- Loading uses a quiet **breathing pulse** (0.85 → 1.0 scale, 1.4s ease-in-out, infinite) rather than a spinning indicator — fits the "analyzing the body" metaphor.
- Result reveal: cards fade + 8px slide-up, staggered 60ms each. Not optional — the spec describes 8 cards appearing, and unstaggered is overwhelming.
- Tab transitions: instant. iOS native.
- **No parallax. No counter animations on numbers**. Numbers appear at their final value.

### Hover / press states
- Buttons: press → 0.96 scale + slightly darker fill (`--brand-primary-press`), 120ms. No hover state on touch.
- Cards: tap → 0.98 scale + brief tint of `--bg-tint`. No persistent highlight.
- Status badges: never interactive — never any state.

### Borders
- **Hairline philosophy.** 1px borders in `--border-1` (`#E2E6EE`). On dark mode, `#232A38`.
- Cards: prefer **shadow over border**, but use both when card sits on `--bg-surface` (white-on-white needs the border).
- Inputs: 1px border, 1.5px on focus in `--border-focus`.

### Shadows
- Two elevation tiers only:
  - `--shadow-card` — resting cards, very subtle
  - `--shadow-pop` — modals, dropdowns, action sheets
- All shadows use the navy ink color at low alpha — never pure black. Looks more iOS-correct.
- No inner shadows except `--shadow-press` for the pressed state of certain controls.

### Corner radii
- `--r-sm` 10px — small chips, badges
- `--r-md` 14px — buttons, inputs, list rows
- `--r-lg` 20px — cards, sheets
- `--r-xl` 28px — top of bottom sheets, large feature cards
- `--r-pill` — for status badges and segmented controls

### Transparency & blur
- Bottom tab bar uses iOS-style **vibrancy**: `backdrop-filter: blur(20px) saturate(180%)` over `rgba(255,255,255,0.72)` (light) / `rgba(22,27,38,0.72)` (dark).
- Result-screen "직전 대비 변화" overlay on photos uses a **protection gradient** (transparent → 60% navy ink) at the bottom so the joint overlay numbers stay legible regardless of photo background.
- Otherwise minimal transparency.

### Imagery vibe
- User photos: untouched, no filter, no tint. The whole product is "see your real body" — color-grading would feel deceptive.
- Empty states: simple stroke icons from SF Symbols-equivalent set, never illustrations.

### Layout rules
- Fixed elements: bottom tab bar (49pt + safe area), top navigation (44pt + safe area).
- Wizard progress bar is fixed below top nav (3px height, indigo fill).
- Scrollable area: everything between top nav and tab bar.
- Result screen's "two photos" header is sticky-collapsed (full height → 64px) on scroll.

### Cards
- Default card: `--bg-surface` background, `--r-lg` 20px radius, `--shadow-card`, 1px `--border-1` border.
- Status cards (the 8 result cards) carry a **left-side status indicator strip** — 4px wide, full height, in the status color. NOT a left-border accent on a whole card; specifically a positioned strip with its own radius, so it reads like a tab marker on a folder.
- History row: `--bg-surface`, 14px radius, hairline border only, no shadow (these stack densely).

---

## ICONOGRAPHY

### What we use
- **SF Symbols** are the canonical icon set for the iOS app — used for tab bar, navigation actions, list affordances. SF Symbols cannot be CDN'd (Apple-licensed), so:
  - **In-app (Swift)**: use SF Symbols directly via `Image(systemName: …)`.
  - **In this design system (HTML preview)**: substituted with **Lucide Icons** (open-source, near-identical stroke style at 1.5–2px). Loaded from CDN. Flagged.
- **No icon font in the codebase yet** — there's no codebase. Once Swift app exists, SF Symbols are the native answer; no icon font is needed.
- **No PNG icons.** Vector only. SVG sprite (`assets/icons.svg`) used in HTML kits.

### Specific icon mappings (HTML kit → Swift app)
| Use | SF Symbol (Swift) | Lucide (HTML preview) |
|---|---|---|
| 측정 tab | `camera.fill` | `camera` |
| 기록 tab | `chart.bar.fill` | `bar-chart-3` |
| Settings | `gearshape` | `settings` |
| Camera shutter | `circle.inset.filled` | `circle-dot` |
| Back | `chevron.left` | `chevron-left` |
| Joint marker | (custom dot) | (custom dot) |
| Trend up | `arrow.up.right` | `trending-up` |
| Trend down | `arrow.down.right` | `trending-down` |
| Trend flat | `arrow.right` | `arrow-right` |
| Re-shoot | `arrow.counterclockwise` | `rotate-ccw` |
| Use this | `checkmark.circle.fill` | `check-circle-2` |

### Logo / wordmark
- No real logo exists. A wordmark is proposed (`assets/wordmark.svg`) and an app icon (`assets/app-icon.svg`) based on a minimal "stacked rectangles → aligned" mark suggesting good posture. This is a *placeholder for review*, not a final brand mark.

### Emoji policy
- The four status emojis (🟢🟡🟠⚪) are **the only emojis** in the entire product, and they appear as visual reinforcement *next to* the colored badge — never as a standalone signifier. Per spec §6 accessibility: "색만 의존하지 않고 아이콘+텍스트 병기" — never rely on color alone, always pair with icon + text.
- No other emoji anywhere.

### Unicode glyphs
- Middle dot `·` used as separator: `Step 2 / 3 · 측면 사진`
- Degree sign `°` for angles: `170°`
- Em dash `—` only in long-form copy (this README); never in app UI.

---

## ASKS FOR THE USER — please review!

This design system was built from a single spec doc with no visual references. **Most of the visual identity is invented.** I need your input to know what to keep and what to redirect:

1. **Brand color.** Pose Indigo `#3B5BDB` is a placeholder primary. Do you want something more medical (deeper navy?), more wellness (softer sage/mint?), more friendly (warmer coral?), or something else entirely?
2. **Logo / app icon.** I drew a placeholder geometric mark. Do you have a real direction, or want me to explore 3–4 mark variations?
3. **Tone.** I committed to a calm, neutral, formal-polite (합니다체) clinical voice. If you want it warmer/more coaching, or more casual (해요체), say so — it changes every string.
4. **Local font hosting.** Pretendard is referenced via CDN; local woff2 writes timed out. The CDN works, but for a production iOS app you'd want bundled OTF/TTF files. Want me to retry, or are you fine with CDN for the design system?
5. **Imagery.** I assumed no stock photography and no illustrations. Confirm? Or do you want onboarding illustrations?
6. **Dark mode.** I built it. Confirm it's wanted (spec implies yes, but worth checking).
7. **Visual reference.** If you have any Korean apps you admire as a reference point (e.g. 인바디, 눔, 카카오헬스케어, 토스), please share — I can recalibrate against them.
