# GitHub Actions IPA 빌드

Apple 인증서·profile·Team ID·API key를 GitHub에 등록하는 단계는 없습니다. GitHub Actions가 활성화되어 있으면 main push 또는 수동 Run workflow로 실행합니다.

핵심 명령은 다음과 같습니다. 사용자가 Mac에서 실행할 필요 없이 workflow에서 수행됩니다.

```bash
xcodebuild -project PikoIOS.xcodeproj -scheme PikoIOS -configuration Release \
  -sdk iphoneos -destination 'generic/platform=iOS' -derivedDataPath build/DerivedData \
  ARCHS=arm64 ONLY_ACTIVE_ARCH=NO CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY='' DEVELOPMENT_TEAM='' build
```

`Release-iphoneos/PikoIOS.app`을 `Payload` 아래에 넣어 IPA를 생성합니다. 이 출력은 실기기 Mach-O 앱이며 개인 ID의 서명만 설치 도구에 맡깁니다. Distribution용 exportArchive는 사용하지 않습니다.

## 문제 해결

| 실패 단계 | 확인할 것 |
|---|---|
| workflow 실행 안 됨 | Actions 활성화 여부, 계정/저장소 runner 사용 제한 |
| Xcode 선택 | XCODE_VERSION variable이 현재 runner에 없는 버전이면 제거 |
| XcodeGen 설치 | 공식 ZIP 다운로드와 고정 SHA-256 검사 |
| 프로젝트 생성 | CI 설정 파일 및 source/resource 경로 |
| 컴파일 | build-report의 compile.log에서 최초 Swift 오류 |
| 패키징 | Release-iphoneos app와 executable 존재 여부 |
| IPA 검사 | Payload 경로, Info.plist, arm64 및 Mach-O IOS platform |
| 설치 실패 | AltStore/Sideloadly 재서명, 신뢰, 개발자 모드, 무료 계정 앱 제한 |

GitHub artifact는 30일 보관합니다. 성공한 run의 `PikoIOS-ipa`에 실제 IPA가 있어야 빌드 산출물 완료로 판정합니다. Source ZIP과 simulator build는 이 조건을 충족하지 않습니다.
