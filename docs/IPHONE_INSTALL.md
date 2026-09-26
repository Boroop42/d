# Windows + 무료 Apple ID로 Piko 설치

준비물: Windows PC, iOS 17 이상 iPhone, USB 케이블, 본인 Apple ID, GitHub Actions에서 받은 **PikoIOS.ipa**. 별도 유료 개발자 가입은 필요하지 않습니다.

## 1. 실제 IPA 받기

[Actions](https://github.com/Boroop42/d/actions/workflows/ios-build.yml) → 성공한 **Build PikoIOS IPA** 실행 → 아래 Artifacts의 **PikoIOS-ipa**를 다운로드합니다. ZIP을 풀면 `PikoIOS.ipa`가 나옵니다. GitHub의 Code → Download ZIP은 소스 코드이므로 설치에 사용하지 않습니다.

## 2. AltStore Classic / AltServer

1. Windows에 [공식 AltServer](https://altstore.io/)를 설치합니다. **Classic용** Windows 설치 절차를 따릅니다.
2. AltStore 공식 안내에 맞는 Apple iTunes와 iCloud를 설치합니다. 필요한 다운로드와 Microsoft Store 버전 관련 예외는 [공식 Windows 가이드](https://faq.altstore.io/altstore-classic/how-to-install-altstore-windows)에 있습니다.
3. iPhone을 USB로 연결·잠금 해제하고 PC 신뢰를 승인합니다. AltServer에서 **Install AltStore → 본인 iPhone**을 선택합니다.
4. Apple ID 인증은 사용자가 AltServer에서 직접 완료합니다. 채팅이나 GitHub에 Apple 암호를 올리지 않습니다.
5. iPhone 설정에서 필요 시 개발자 프로필을 신뢰하고 **개인정보 보호 및 보안 → 개발자 모드**를 활성화합니다.
6. `PikoIOS.ipa`를 iCloud Drive 등 본인이 사용하는 파일 전송 방식으로 iPhone의 **파일 앱**에 옮깁니다.
7. iPhone의 AltStore Classic → **My Apps → +**에서 `PikoIOS.ipa`를 선택합니다. 이때 Windows AltServer가 실행 중이고 iPhone과 연결되어 있어야 합니다.
8. 설치가 끝나면 홈 화면의 **Piko**를 실행하고 공식 X 웹 페이지에서 로그인합니다.

AltStore의 무료 계정 앱은 7일 후 만료됩니다. Windows AltServer를 실행한 상태에서 기기를 연결하고 AltStore의 **Refresh All**을 만료 전에 사용합니다. 자동 갱신을 쓰려면 공식 안내에 따라 Wi-Fi 동기화·같은 네트워크 등 조건을 갖춰야 합니다. [AltStore 갱신 안내](https://faq.altstore.io/altstore-classic/your-altstore).

## 3. 대안: Sideloadly

[공식 Sideloadly](https://sideloadly.io/)를 Windows에 설치하고 iPhone을 연결합니다. `PikoIOS.ipa`를 앱에 끌어놓고 대상 기기와 본인 Apple ID를 선택한 뒤 설치합니다. 인증·재서명은 사용자가 도구에서 직접 수행합니다. 무료 계정 갱신 제한을 확인하고 Sideloadly의 갱신 기능을 사용하세요.

## 설치·갱신 문제

- 무료 Apple ID에는 동시 활성 sideload 앱 수 제한이 있으며 AltStore 자체도 한 자리를 사용합니다. 공간이 없으면 공식 안내대로 기존 앱을 비활성화해야 할 수 있습니다.
- `PikoIOS.ipa` 파일을 iPhone에서 누르는 것만으로 설치되지는 않습니다. 반드시 위 도구의 재서명 단계를 거칩니다.
- 갱신 시 같은 Apple ID와 Bundle ID를 유지합니다. 삭제 후 재설치나 식별자 변경은 기존 로그인·설정을 잃게 할 수 있습니다.
- 앱이 열리면 홈/검색/알림/메시지와 설정, 앱 재실행 후 X 로그인 유지를 확인합니다. X가 해당 로그인 환경을 제한하면 앱이 이를 우회하지 않습니다.
- 이 프로젝트의 CI artifact 생성 검증과 사용자 기기의 재서명·실행 검증은 별개입니다.
