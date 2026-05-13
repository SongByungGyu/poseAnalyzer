---
name: poseanalyzer-design
description: Use this skill to generate well-branded interfaces and assets for PoseAnalyzer, a Korean iOS posture-analysis app. Contains essential design guidelines, colors, type, fonts, assets, and an iOS UI kit for prototyping. Korean-language UI throughout; iOS 17+ / SwiftUI conventions.
user-invocable: true
---

Read the `README.md` file within this skill, and explore the other available files.

If creating visual artifacts (slides, mocks, throwaway prototypes, etc), copy assets out and create static HTML files for the user to view. If working on production code, you can copy assets and read the rules here to become an expert in designing with this brand.

If the user invokes this skill without any other guidance, ask them what they want to build or design, ask some questions, and act as an expert designer who outputs HTML artifacts or production code, depending on the need.

## Quick orientation

- `README.md` — full brand guide: product context, content fundamentals (voice/tone in Korean), visual foundations (color, type, spacing, motion, etc), iconography.
- `colors_and_type.css` — all design tokens as CSS variables. Light + dark mode. Drop into any HTML file with `<link rel="stylesheet">`.
- `source/spec.md` — the original Korean functional spec (the only canonical source of truth for what the product does).
- `assets/` — `app-icon.svg`, `wordmark.svg`, `icons.svg` (Lucide sprite as SF Symbols stand-in).
- `preview/` — static cards used in the Design System tab. Good source of small isolated visual patterns to copy.
- `ui_kits/ios_app/` — interactive iOS prototype + JSX components. Start here when building screen mocks.

## The most important rules

1. **Status colors are sacred.** The 4-step judgment scale (정상 / 주의 / 의심 / 측정 불가) drives all result visualization. Never invent a 5th state. Never use red — `의심` is `#E0683A` (burnt orange), not red. Always pair color with text + dot for color-blind safety.
2. **All UI text is Korean, 합니다체.** Calm, neutral, observer voice. No "you" pronouns. No exclamation marks except in genuine errors.
3. **Tabular numerics** on every metric readout — angles, cm, dates, deltas. `font-variant-numeric: tabular-nums`.
4. **No gradients except brand CTA.** Surfaces are flat. The hero "측정 시작" card uses a subtle indigo gradient — that's it.
5. **No emoji in body copy.** The four status emojis only, as paired icon reinforcement.

## Caveats inherited from how this system was built

- **The visual direction is invented**, not extracted from production code — there was no production code, just a spec. Treat as a strong proposal.
- **Pretendard fonts ship via jsDelivr CDN** — local woff2 hosting was deferred (write timeouts).
- **Icons use Lucide as a stand-in for SF Symbols** in HTML; in real Swift code use `Image(systemName:)` directly.
- **Logo / wordmark is a placeholder.** A real brand mark hasn't been designed.
