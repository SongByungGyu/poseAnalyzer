# PoseAnalyzer · App icon + Launch screen handoff

선택된 디자인을 Claude Code에 바로 넘길 수 있는 형태로 패키징했습니다.

## 들어 있는 것

```
exports/
├── AppIcon.appiconset/        ← 그대로 Xcode에 드래그
│   ├── Contents.json
│   ├── icon-1024.png          1024×1024 (App Store)
│   ├── icon-60-2x.png         120×120 (iPhone 앱)
│   ├── icon-60-3x.png         180×180 (iPhone 앱 @3x)
│   ├── icon-40-2x.png         80×80   (Spotlight @2x)
│   ├── icon-40-3x.png         120×120 (Spotlight @3x)
│   ├── icon-29-2x.png         58×58   (Settings @2x)
│   ├── icon-29-3x.png         87×87   (Settings @3x)
│   ├── icon-20-2x.png         40×40   (Notification @2x)
│   ├── icon-20-3x.png         60×60   (Notification @3x)
│   └── icon.svg               원본 SVG (참고용, Xcode가 안 씀)
└── LaunchView.swift           SwiftUI 스플래시
```

## 클러드 코드에 전달할 명령

> `PoseAnalyzer/docs/design/exports/` 폴더에 새 에셋이 있어. 두 가지 작업 해줘:
>
> **1. 앱 아이콘 교체** — `exports/AppIcon.appiconset/` 안의 모든 파일 (Contents.json + 9개 PNG) 을 `PoseAnalyzer/PoseAnalyzer/PoseAnalyzer/Assets.xcassets/AppIcon.appiconset/`로 복사해서 기존 파일을 덮어써줘. Xcode가 자동으로 인식할 거야.
>
> **2. 스플래시 추가** — `exports/LaunchView.swift`를 `PoseAnalyzer/PoseAnalyzer/PoseAnalyzer/Presentation/`로 복사하고, `PoseAnalyzerApp.swift`를 수정해서 첫 진입 시 1.2초 동안 LaunchView를 띄운 후 메인 탭으로 fade out 하도록 만들어줘. (LaunchView.swift 파일 상단 주석에 통합 예시 코드가 있어.)
>
> 빌드 통과 확인하고, Simulator에서 (1) 홈스크린 아이콘이 새 디자인인지, (2) 앱 진입 시 인디고 스플래시 → 메인 탭 전환이 부드러운지 검토해줘.

## 파일명 표기

PNG 파일명은 일반적인 Apple 컨벤션 `@2x` / `@3x` 대신 `-2x` / `-3x`를 씁니다 (`@` 문자가 export 환경에서 변환됨). **Xcode는 `Contents.json`의 filename 항목을 그대로 읽으므로 동작에 문제 없습니다** — Contents.json 안의 filename도 같이 `-2x`로 맞춰뒀습니다. 원한다면 클러드 코드가 `@` 형태로 일괄 이름 바꾸고 Contents.json도 같이 고쳐도 됩니다.

## 디자인 시스템 토큰

LaunchView는 디자인 시스템 색상을 inline RGB로 박아뒀습니다 (`#3B5BDB`, `#56BAB0` 등) — `AppColor.swift`의 `.brandPrimary`를 안 쓴 이유는 LaunchView가 가장 먼저 뜨는 화면이라 의존성을 최소화하기 위함입니다. 원하시면 `Color.brandPrimary`로 바꿔도 무방합니다.

## 검토 포인트

- **마크 사이즈**: 120pt × 120pt — iPhone에서 적절. iPad는 자동 스케일.
- **스플래시 지속 시간**: 1.2초 + 0.35초 fade. 데이터 로딩 동안 자연스럽게 가려질 수 있게 짧게 잡았어요. 필요 없으면 `.task` 블럭에서 sleep 빼면 됩니다.
- **정적 LaunchScreen (Xcode storyboard)**: 별도로 만들지 않았습니다. SwiftUI LaunchView가 거의 즉시 뜨므로 보통은 필요 없지만, 앱 콜드 스타트 직후 흰 화면이 잠깐 보이면 Xcode → Info → Launch Screen에서 `Background Color = #3B5BDB`만 지정해두세요.

## 변경 이력

- icon A "Aligned column" — `assets/app-icon.svg`의 placeholder를 다듬은 버전. 캐노피 안에 머리 + 어깨 바 + 척추 컬럼 + 골반 바 + mint 정렬 도트.
- splash 2 "Full-bleed indigo" — 인디고 그라디언트 풀블리드, 상단 광원, 마크 + 워드마크, 하단 캡션.
