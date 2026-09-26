# PikoWebViewSmokeTest

순수 WKWebView의 실제 iPhone 동작만 확인하는 별도 iOS 17+ SwiftUI 앱입니다.
기존 PikoIOS 소스와 리소스는 이 target에 포함되지 않습니다.

- 시작 즉시 https://x.com/home 요청, 기본 영구 website data store, JavaScript 활성화.
- WKWebView 하나와 최근 8개 delegate 이벤트를 표시하는 하단 패널만 사용합니다.
- 탐색 정책 delegate, user script, 광고 차단, DOM 수정, custom user agent, Safari 전환, 설정 없음.
- 패널은 이벤트 이름, 현재 host, 오류 domain/code만 표시합니다. URL 경로·query·오류 설명·쿠키·header는 표시하지 않습니다.

`smoke-test` branch에 push하면 **Build PikoWebViewSmokeTest IPA**가 실행됩니다.
성공한 실행의 **PikoWebViewSmokeTest-ipa** artifact에서 `PikoWebViewSmokeTest.ipa`를 다운로드하세요.
Windows의 Sideloadly/AltStore에서 무료 Apple ID로 재서명하여 설치합니다. 별도 Bundle ID
`com.local.pikowebviewsmoketest`이므로 기존 PikoIOS를 덮어쓰지 않습니다.

기기에서 실행 후 X 페이지 표시 여부와 하단 이벤트/host/domain/code를 확인하세요.
기존 PikoIOS와 로그인 저장소가 분리되어 있으므로 새 로그인이 필요할 수 있습니다.
검증 결과가 나오기 전까지 기존 PikoIOS 기능은 변경하지 않습니다.
