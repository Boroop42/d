import SwiftUI

struct PikoSettingsView: View {
    @ObservedObject var settings: SettingsStore
    @ObservedObject var browser: BrowserViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var confirmLogout = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("Hide Promoted Posts", isOn: $settings.preferences.hidePromotedPosts)
                    Toggle("Hide Promoted Trends", isOn: $settings.preferences.hidePromotedTrends)
                    Toggle("Hide Recommended Users", isOn: $settings.preferences.hideRecommendedUsers)
                    Toggle("Hide View Count", isOn: $settings.preferences.hideViewCount)
                } header: { Text("Timeline") } footer: {
                    Text("확실한 웹 요소만 숨깁니다. X의 화면 구조나 언어가 바뀌면 일부 항목이 계속 표시될 수 있습니다.")
                }
                .disabled(!settings.preferences.enableEnhancements)
                Section("Appearance") {
                    LabeledContent("게시물 글꼴", value: "\(Int(settings.preferences.postFontPercent))%")
                    Slider(value: $settings.preferences.postFontPercent, in: 80...160, step: 5)
                        .accessibilityLabel("게시물 글꼴 크기")
                        .disabled(!settings.preferences.enableEnhancements)
                    Toggle("Hide Native Toolbar", isOn: $settings.preferences.hideNativeToolbar)
                    Text("툴바를 숨겨도 오른쪽 아래 설정 버튼으로 복구할 수 있습니다.").font(.caption)
                }
                Section("Advanced") {
                    Toggle("Enable JavaScript Enhancements", isOn: $settings.preferences.enableEnhancements)
                    Button("Reset injected rules") { settings.resetRules() }
                    Button("Clear X website cache") {
                        Task { await browser.clearWebsiteData(includingLogin: false) }
                    }
                    Button("로그아웃 / Clear X login data", role: .destructive) { confirmLogout = true }
                }
                Section("구현 범위") {
                    Text("Phase 1–2 · 공식 X 웹 로그인, 브라우저 및 타임라인 표시 설정")
                    Text("미디어 저장, 번역, Grok UI, 대체 아이콘은 후속 단계입니다. 로그인 제한이나 인증 요구사항은 X가 결정합니다.")
                        .font(.caption).foregroundStyle(.secondary)
                }
            }
            .disabled(browser.clearingData)
            .navigationTitle("Piko 설정")
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("완료") { dismiss() } } }
            .confirmationDialog("이 기기의 X 로그인과 X 웹사이트 데이터를 삭제할까요?", isPresented: $confirmLogout, titleVisibility: .visible) {
                Button("X 데이터 삭제", role: .destructive) {
                    Task { await browser.clearWebsiteData(includingLogin: true) }
                }
            } message: { Text("서버의 다른 로그인 세션은 종료하지 않습니다.") }
        }
    }
}
