# 실기기 Frame load interrupted 수정

## 확인한 원인

이전 `isInternal()`은 네 개 호스트만 허용해 정상 `x.com` / `twitter.com` 하위 도메인을 차단했습니다. coordinator는 main-frame 외부 주소를 탐색 유형과 무관하게 취소하고 외부 브라우저로 전달했습니다. 이후 WebKitErrorDomain 102 정책 중단을 실제 페이지 실패와 동일하게 표시했습니다.

실기기에서 보고된 오류는 이 잘못된 오류 처리와 일치합니다. 다만 기기의 전체 redirect 로그는 제공되지 않았으므로 실제 차단된 주소가 `mobile.x.com`이었다고 단정하지 않습니다.

## 수정 파일

| 파일 | 변경 |
|---|---|
| Sources/Utilities/XURLParser.swift | HTTPS X/Twitter 루트 및 점으로 구분된 하위 도메인 판정, about:blank 검사 |
| Sources/Utilities/NavigationPolicy.swift | 링크 클릭/자동 이동/iframe 구분, domain+code 오류 분류, 탐색 identity 추적 |
| Sources/Utilities/BrowserRequest.swift | 홈 요청 캐시 재검증 및 30초 timeout |
| Sources/Utilities/NavigationDiagnostics.swift | Debug 전용 URL 비식별화 및 정책·오류 로그 |
| Sources/Features/Browser/WebViewCoordinator.swift | 새 정책 적용, 현재 main-frame 최종 실패만 overlay 표시 |
| Sources/Features/Browser/BrowserViewModel.swift | 요청 생성·탐색 시작 상태 관리, 재시도/앞뒤 탐색 추적 |
| Sources/Features/Browser/BrowserView.swift | 모델을 통한 앞뒤 탐색 |
| Sources/WebEnhancements/WebScript.swift | 허용한 하위 도메인에서도 enhancement 유지 |
| Sources/WebEnhancements/TimelineCleanupScript.swift | 하위 도메인의 analytics 링크 조회수 숨김 유지 |
| Tests/Swift/PolicyTests.swift | URL 경계, navigation 결정, 오류 domain/code, stale callback, 홈 요청, 로그 비식별화 회귀 검사 |
| Tests/JavaScript/enhancements.test.cjs | 하위 도메인 적용 및 가짜 도메인/포트 차단 검사 |
| scripts/test-ios.sh | 실제 iOS Simulator XCTest 실행 |
| .github/workflows/ios-build.yml | XCTest 성공 후 기기용 IPA 빌드 |
| Resources/Assets.xcassets/AppIcon.appiconset/AppIcon.png | 사용자 제공 강아지 이미지, 1024×1024 RGB |
| README.md / FEATURE_COMPATIBILITY.md / VALIDATION.md / RELEASE_STATUS.md | 동작 및 실제 검증 결과 갱신 |

`TwitterWebView.makeUIView`는 delegate와 persistent website data store를 먼저 설정하고 모델에 web view를 연결한 뒤 홈을 요청하는 기존 순서를 유지합니다. 실제 최초 URL과 cachePolicy/timeout은 BrowserRequest 회귀 검사로 검증합니다.

## 오류 및 보안 동작

- `NSURLErrorDomain/-999`, `WebKitErrorDomain/102`: overlay 표시하지 않음.
- DNS/오프라인/timeout/TLS 오류: 현재 main-frame 탐색의 실패이면 표시.
- 새 탐색 시작, 현재 탐색의 redirect/commit/finish: 이전 errorMessage 제거.
- 예전 탐색이나 이미 완료된 탐색의 뒤늦은 실패: 새 페이지를 덮지 않음.
- X 소유 HTTPS: 허용. about:blank: 허용. 임의 custom scheme: 취소.
- 외부 HTTP(S) main-frame 사용자 클릭: 시스템 브라우저. 외부 자동 탐색: 취소하되 fatal overlay를 만들지 않음.
- 외부 HTTPS iframe: 웹 콘텐츠용으로 허용하되 스크립트를 주입하지 않고 외부 앱도 실행하지 않음.
- Debug 로그: URL의 query/fragment/credentials/알 수 없는 경로를 제거. 쿠키·Authorization header·request body는 읽거나 출력하지 않음.

## 실기기 재확인

새 IPA를 같은 Apple ID/Bundle ID로 Sideloadly에서 재서명하여 업데이트합니다. 앱을 삭제하지 않고 업데이트해 기존 설정·로그인을 보존하세요. 실행 → 공식 로그인/홈 → 검색/알림/메시지 → 외부 링크 → 비행기 모드의 실제 오류/재시도를 확인합니다. 이번 CI 테스트는 실제 사용자 계정의 X 로그인 성공을 대체하지 않습니다.
