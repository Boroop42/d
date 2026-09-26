# Feature compatibility · Phase 1–2

분류는 현재 소스의 구현 범위입니다. **Fully Supported도 실제 기기·실계정 X 검증을 통과했다는 뜻은 아닙니다.** 최신 GitHub 컴파일 및 IPA artifact 검증 결과는 `RELEASE_STATUS.md`를 참고하세요.

| 기능 | 분류 | 현재 구현·제약·대체 방법 |
|---|---|---|
| SwiftUI 앱, iPhone/iPad 레이아웃 | Fully Supported | iOS 17+, 네이티브 Form/NavigationStack, 기기 회전 지원. 설치 후 실제 기기에서 UI 검증 필요 |
| 뒤로/앞으로/새로고침/홈/당겨서 새로고침 | Fully Supported | WebKit 기록과 UIRefreshControl 사용 |
| 로딩/네트워크 오류/프로세스 종료 처리 | Fully Supported | ProgressView, 재시도 화면 |
| 공식 X 로그인 및 로그인 유지 | Partially Supported | 공식 웹 화면과 persistent default data store. X가 임베디드 브라우저 로그인을 제한하거나 외부 SSO를 요구하면 우회하지 않음. 공식 X 웹 로그인 사용 |
| 홈/검색/알림/DM/프로필/상세 | Partially Supported | 공식 웹 페이지로 이동. X의 계정·지역·브라우저 정책에 종속 |
| 외부 링크 | Fully Supported | HTTP(S) 외부 링크를 시스템 기본 브라우저에 전달. 기본 브라우저가 Safari가 아닐 수 있음. 외부 SSO 쿠키는 WebKit과 공유하지 않음 |
| 설정 저장/툴바 숨김 | Fully Supported | UserDefaults Codable 저장. 툴바 숨김 시 작은 설정 버튼 유지 |
| Promoted posts | Partially Supported | 구조화된 광고 표식 또는 placementTracking+광고 라벨. 본문 단어로 판정하지 않음. DOM/언어 변경 시 원래 UI 유지 |
| Promoted trends | Partially Supported | trend 내부 정확히 일치하는 광고 라벨. 지원 라벨은 코드에 명시 |
| Recommended users | Partially Supported | 명시적 aria-label 및 UserCell을 가진 aside/section만 숨김. 타임라인과 섞인 모듈은 남을 수 있음 |
| View count | Partially Supported | 게시물 action group의 정확한 status/ID/analytics 경로만 숨김. 일반 조회수 텍스트는 보존 |
| Custom post font size | Partially Supported | tweetText의 computed font size에 비율 적용. 별도 자식 폰트를 지정한 웹 UI는 적용 범위가 다를 수 있음 |
| JS enhancements 켜기/끄기, 규칙 초기화 | Fully Supported | 즉시 재주입·스타일 복원·observer 해제. 스크롤/탐색 리로드 불필요 |
| X 캐시·로그인 데이터 삭제 | Fully Supported | X/Twitter/twimg 도메인 WebKit record만 삭제. 캐시는 메모리·디스크 캐시만. 로그인 삭제는 로컬 로그아웃이며 서버 세션 폐기 아님 |
| 현재 URL 공유/복사/외부에서 열기 | Fully Supported | 기본 브라우저 메뉴에 포함. 특정 게시물 context menu는 후속 단계 |
| APK Java/Kotlin/DEX 이식 | Not Implemented | 독립 SwiftUI 재구현이라는 요구에 따라 미포함 |
| Live Threads, Community Notes, Grok 최소화 | Not Implemented | 첫 요청의 Phase 1–2 범위 밖. 별도 보수적 DOM 규칙 필요 |
| Compact Timeline/Spacing, OLED, Custom Accent | Not Implemented | 후속 Appearance 단계. 현재는 시스템 기본 스타일 |
| 미디어 버튼/길게 누르기/Photos/Files/URL 복사 | Not Implemented | Phase 4. 공개 DOM 미디어 URL 및 사용자 선택 기반 저장 계층 필요 |
| 영상 다운로드, MediaMetadataProvider, FxTwitter | Not Implemented | Phase 4. 공개 URL만 취급할 교체 가능 provider 필요. blob/DRM/접근 제한은 우회 불가 |
| 번역 및 TranslationProvider | Not Implemented | Phase 4. 대상 iOS 버전에 맞는 Apple 번역 API와 fallback 설계를 별도로 검토 |
| XPostReference 및 게시물별 메뉴 | Not Implemented | Phase 3. 현재 URL 감시는 있으나 게시물 모델·전용 메뉴는 없음 |
| Default 아이콘 | Fully Supported | 사용자가 제공한 강아지 PNG를 1024px RGB AppIcon으로 적용 |
| Dark/Blue/Minimal 대체 아이콘 | Not Implemented | Phase 5. 별도 appiconset 및 alternate icon build setting/API 필요 |
| Debug Console | Not Implemented | Phase 5. 현재는 콘텐츠·URL·인증 정보를 로그로 수집하지 않음 |
| JavaScript → native bridge | Not Implemented | Phase 1–2에서는 불필요하므로 등록하지 않음. 추후 origin/main-frame/type/payload 검증 필수 |
| 토큰·비밀번호 추출, 토큰 import/export, private API | Not Implemented | 요구에 따라 의도적으로 제외. 향후 단계에서도 구현하지 않음 |

웹 enhancement는 콘텐츠를 시각적으로 숨깁니다. 네트워크 광고 요청이나 추적 요청을 차단하는 콘텐츠 차단기는 아닙니다. 셀 여백이 남을 수 있으며 삭제 대상이 불확실하면 그대로 표시합니다.
