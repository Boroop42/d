# 검증 기록

2026-09-26 · Windows · Node.js v24.19.0 · jsdom 30.1.1 · yaml 2.9.1

## 무료 Apple ID용 IPA 빌드 변경

- GitHub `macos-latest`에서 iPhoneOS arm64 Release를 빌드하고 `Payload/PikoIOS.app`을 IPA로 패키징하도록 변경했습니다.
- 인증서/배포 profile/API key/유료 계정 의존성을 제거했습니다. 재서명은 Windows의 AltStore Classic 또는 Sideloadly에서 사용자가 수행합니다.
- Python 검사 5개 추가 및 통과: 기기 bundle 허용, Simulator/잘못된 식별자 거부, 버전과 재시도, 입력값 검증, plist/manifest 검사.
- 실제 원격 컴파일·IPA artifact 결과는 [RELEASE_STATUS.md](RELEASE_STATUS.md)를 우선 확인하세요. 아래는 최초 Phase 1–2 작성 당시의 기록입니다.

## 수행 결과

- APK ZIP/DEX의 지정된 기능 문자열 검사 및 SHA-256 기록 완료. APK 코드는 실행하지 않았습니다.
- JavaScript/프로젝트 구성 자동 테스트: **9개 통과, 실패 0개**.
- Info.plist: .NET XML parser로 파싱 성공.
- XcodeGen YAML: 중복 키 검사 및 source/Info.plist 경로 존재 검사 통과.
- 임시 아이콘: 1024×1024 PNG 및 Asset Catalog metadata 포함.
- 소스 검색: TODO/FIXME, document.cookie, httpCookieStore, auth_token, URLSession, fetch 호출 없음. 이 검사는 일반 보안 감사 전체를 대신하지 않습니다.

자동 테스트는 Swift raw string 안의 실제 JavaScript를 추출하여 합성된 DOM에 실행했습니다.

1. 주입 JavaScript 문법, YAML 키 및 경로 유효성.
2. 광고/트렌드/추천/조회수의 제한된 구조 식별 및 본문 오탐 방지.
3. 재주입·비활성화 시 원래 스타일 복원 및 글꼴 누적 확대 방지.
4. 개별 기능 토글 독립성.
5. placementTracking 광고 표식 판정에서 본문·작성자 이름 제외.
6. 유사 도메인 및 HTTP origin에서 미실행.
7. 동적 DOM 삽입/재활용 후 재판정 및 observer 자체 반복 방지.
8. 글꼴 크기 상·하한 및 기존 inline priority 복원.
9. selector 오류 시 해당 기능 실패를 격리하고 다른 기능 유지.

## 확인하지 못한 항목

- Windows에 Swift compiler, Xcode, XcodeGen, iOS SDK가 없어 **Phase 1/2의 iOS 컴파일 성공은 검증하지 못했습니다.** Swift 파일은 API·접근 범위·라이프사이클을 수동 검토했으나 컴파일 검사와 동등하지 않습니다.
- Swift XCTest 3개는 작성했으나 실행하지 못했습니다. URL 경계, 삭제 대상 도메인 경계, 설정 저장·복원을 Mac에서 테스트해야 합니다.
- 실제 WKWebView에서 로그인, 쿠키 지속성, 로그아웃, 레이아웃, 공유, 외부 SSO, 접근성, 성능을 확인하지 못했습니다.
- 실제 X DOM과 광고 노출에 대한 검증은 수행하지 않았습니다. fixture 통과는 현재 X 사이트의 selector 호환성을 보장하지 않습니다.
- 앱 서명, 실제 기기 설치, IPA 생성은 수행하지 않았습니다.

현재 빌드와 설치 절차는 `README.md` 및 `docs/IPHONE_INSTALL.md`를 따릅니다. 사용자가 Mac을 준비할 필요 없이 GitHub runner가 빌드를 담당합니다. 테스트 설치 의존성은 앱에 포함되지 않습니다.
