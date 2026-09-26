# APK 참고 분석

분석일: 2026-09-26. 분석 대상은 사용자가 지정한 로컬 파일 하나입니다.

- 파일: `twitter-piko-v12.11.0-release.0.apk`
- 크기: 168,058,422 bytes
- SHA-256: `75A33B0B87E3D74477BDEDD124B1923337919298B685EF8C24D21C19DC6C5183`
- 방식: ZIP 내부 `classes*.dex`에서 지정된 기능 이름의 ASCII 문자열 존재 여부만 검사했습니다.
- APK 실행, 전체 디컴파일, 서버 호출, 인증 정보 검색·추출은 수행하지 않았습니다. Android 코드와 자산은 프로젝트에 포함하지 않았습니다.

| 확인한 문자열 | 위치 | iOS 설계에 반영 |
|---|---|---|
| ADS_HIDE_PROMOTED_POSTS | classes.dex | 광고 표식이 있는 게시물을 DOM에서 숨김 |
| ADS_HIDE_PROMOTED_TRENDS | classes.dex | trend 영역 내부 프로모션 표식 확인 |
| MISC_HIDE_RECOMMENDED_USERS | classes.dex | 이름과 구조가 확인되는 추천 모듈만 숨김 |
| MISC_HIDE_VIEW_COUNT | classes.dex | 게시물 action group의 analytics 링크 숨김 |
| TIMELINE_HIDE_LIVETHREADS | classes.dex | 후속 단계로 분류 |
| CUSTOM_POST_FONT_SIZE | classes.dex | 게시물 본문 글꼴만 80–160% 조절 |
| InlineDownloadButton | classes.dex | Phase 4 이후 검토 |
| downloadVideoMedia | classes.dex | Phase 4 이후 공개 미디어만 검토 |
| copyVideoMediaLink | classes.dex | Phase 4 이후 검토 |
| MediaDownloader | classes.dex, classes9.dex, classes10.dex | 네이티브 다운로드 계층의 참고 자료 |

문자열 존재는 기능이 포함되었을 가능성을 뒷받침할 뿐 활성화 여부나 실제 UX를 입증하지 않습니다. 요청에 언급된 Community Notes, Grok, 번역, 아이콘 변경은 이 제한된 검사로 APK 내부 구현 여부를 확인하지 않았습니다. 웹 DOM 규칙은 별도로 작성했으며 APK에서 추출한 코드가 아닙니다.
