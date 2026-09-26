# PikoIOS

Target: 개인 iPhone에서 실행하는 iOS 17+ 앱.

Build: GitHub Actions `macos-latest`, `iphoneos` / `generic/platform=iOS`, arm64 Release.

Output: **`PikoIOS.ipa`** — Windows의 AltStore Classic/AltServer 또는 Sideloadly로 무료 Apple ID 재서명 후 설치.

유료 개발자 계정, 배포 인증서, Apple 관련 GitHub Secrets는 필요하지 않습니다. IPA는 기기용 실행 파일을 포함하지만 CI에서 개인 기기용 서명은 하지 않습니다. 설치 도구가 사용자의 Apple ID로 서명합니다.

## Quick Start for iPhone

1. [GitHub Actions](https://github.com/Boroop42/d/actions/workflows/ios-build.yml)에서 **Build PikoIOS IPA → Run workflow → main**을 실행합니다. main push에도 자동 실행됩니다.
2. 실행 결과가 성공하면 아래 **Artifacts → PikoIOS-ipa**를 Windows PC로 다운로드합니다.
3. artifact ZIP을 풀어 **`PikoIOS.ipa`**를 찾습니다. 소스 ZIP이나 Simulator `.app`이 아닙니다.
4. [iPhone 설치 안내](docs/IPHONE_INSTALL.md)에 따라 AltStore Classic 또는 Sideloadly에서 무료 Apple ID로 재서명·설치합니다.
5. 홈 화면의 **Piko**를 실행합니다. AltStore에서 만료 전에 **Refresh All**로 갱신합니다.

**실제로 확인한 빌드·artifact 상태:** [RELEASE_STATUS.md](RELEASE_STATUS.md). 앱이 iPhone에서 실행되는지의 최종 확인은 서명·설치 후 사용자 기기에서 수행합니다.

검증 완료된 IPA: [1.0 (3.1) — 성공한 Actions artifact](https://github.com/Boroop42/d/actions/runs/36235370149/artifacts/10903793524). artifact ZIP 내부의 `PikoIOS.ipa`를 사용하세요.

## 유지한 기능

- 공식 `https://x.com/home` WKWebView, `WKWebsiteDataStore.default()` 로그인 유지.
- 홈/검색/알림/메시지, 앞뒤 탐색, 새로고침, 당겨서 새로고침, 로딩·오류 복구.
- URL 공유/복사/외부 브라우저 열기, 저장되는 설정과 툴바 숨김.
- 프로모션 게시물·트렌드, 추천 계정, 조회수의 개별 숨김.
- 게시물 글꼴 80–160%, enhancement 해제 시 복원.
- X 관련 캐시·로그인 데이터 삭제.

X 웹사이트의 로그인 정책과 DOM 변경에 따른 제약은 [FEATURE_COMPATIBILITY.md](FEATURE_COMPATIBILITY.md)에 기록했습니다. 토큰·비밀번호 추출, private API, 인증 정보 외부 업로드는 없습니다. 기본 아이콘은 X 자산과 무관한 자체 제작 그림입니다.

## CI가 만드는 것

Checkout → 안정 Xcode 선택 → **XcodeGen 2.46.0**(공식 ZIP SHA-256 검사) → DOM/구성 테스트 → 프로젝트 생성 → iPhoneOS Release 컴파일 → `Payload/PikoIOS.app` 패키징 → `PikoIOS.ipa` 검사 → artifact 업로드.

패키징은 macOS `ditto`를 사용합니다. 검사 단계는 실제 Mach-O가 `arm64`이고 platform이 `IOS`인지 확인하여 arm64 Simulator와 구분합니다. Info.plist의 iPhoneOS, Bundle ID, 버전, 개인정보 매니페스트 및 IPA 구조를 검사합니다. 파일 누락이나 검증 실패 시 workflow는 성공 처리되지 않습니다.

artifact 내용:

```text
PikoIOS.ipa
SHA256SUMS.txt
INSTALL.txt
```

별도 `PikoIOS-build-report`에 컴파일 로그와 실행별 상태가 있습니다. artifact 보관 기간은 30일입니다. 만료되면 workflow를 다시 실행하세요. GitHub artifact 다운로드에는 GitHub 로그인이 필요할 수 있습니다.

## 설정

기본 Bundle Identifier는 `com.local.pikoios`이며 일반적인 명시적 식별자입니다. `project.yml`의 `IOS_BUNDLE_ID` build setting으로 연결되어 있습니다. AltStore/Sideloadly가 재서명 시 계정에 맞게 처리합니다. **갱신 때 같은 Apple ID와 같은 식별자를 유지**해야 기존 앱 데이터가 유지될 가능성이 높습니다. 앱 삭제·다른 ID로 설치하면 X 로그인과 설정이 사라질 수 있습니다.

GitHub Settings → Secrets and variables → Actions → **Variables**(Secrets 아님)에서 선택적으로 설정할 수 있습니다.

| Variable | 기본값 | 용도 |
|---|---|---|
| IOS_BUNDLE_ID | com.local.pikoios | 수동 Run workflow 입력값이 있으면 그 값 우선 |
| MARKETING_VERSION | 1.0 | 앱 버전, 수동 입력 우선 |
| CURRENT_PROJECT_VERSION | run_number.run_attempt | 재실행도 구분되는 빌드 번호 |
| XCODE_VERSION | runner 기본 안정 Xcode | runner에 실제 설치된 Xcode 버전을 지정할 때만 사용 |

프로젝트에는 Push, App Groups, iCloud, Associated Domains 등 무료 서명을 어렵게 하는 entitlement와 앱 확장이 없습니다. entitlement 파일을 지정하지 않습니다. 재서명 도구가 기본 application/team 식별 entitlement를 붙입니다. Photos/카메라/마이크 기능이 없으므로 해당 권한도 요청하지 않습니다.

## 소스와 테스트

`Sources/`에는 독립 SwiftUI 앱과 기능별 스크립트가 있습니다. `Resources/`에는 Info.plist, AppIcon, UserDefaults 목적을 선언한 PrivacyInfo.xcprivacy가 있습니다. `.github/workflows/ios-build.yml`이 실제 IPA를 만드는 유일한 배포 workflow입니다.

Node.js 24.15 이상인 24.x 및 Python 3.10+에서 로컬 검사를 실행할 수 있습니다.

```text
npm install
npm test
python -m unittest discover -s Tests/Python -v
```

Swift/iOS 컴파일은 Windows 로컬 테스트로 대신하지 않으며 GitHub macOS runner의 결과로 확인합니다. `xcodegen generate`로 프로젝트를 재생성할 수 있습니다. CI는 환경값을 별도 설정 파일에 반영하여 프로젝트를 생성합니다.

추가 자료: [APK 분석](APK_ANALYSIS.md), [기능 호환성](FEATURE_COMPATIBILITY.md), [검증 기록](VALIDATION.md), [CI 설명](docs/BUILD_IPA.md).
