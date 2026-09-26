import SwiftUI
import UIKit
import WebKit

struct BrowserView: View {
    let state: AppState
    var body: some View { BrowserContent(model: state.browser, settings: state.settings) }
}

private struct BrowserContent: View {
    @ObservedObject var model: BrowserViewModel
    @ObservedObject var settings: SettingsStore
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            ZStack {
                if model.clearingData {
                    ProgressView("X 웹사이트 데이터 삭제 중…")
                } else {
                    TwitterWebView(model: model, preferences: settings.preferences)
                        .id(model.webViewID)
                }
                if let error = model.errorMessage {
                    ContentUnavailableView {
                        Label("페이지를 열 수 없습니다", systemImage: "wifi.exclamationmark")
                    } description: { Text(error) } actions: {
                        Button("다시 시도") { model.reload() }.buttonStyle(.borderedProminent)
                    }
                    .background(.background)
                }
            }
            .safeAreaInset(edge: .top, spacing: 0) {
                if model.isLoading { ProgressView(value: model.progress).accessibilityLabel("페이지 로딩") }
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if !settings.preferences.hideNativeToolbar {
                    HStack {
                        navButton("홈", "house", "/home")
                        Spacer()
                        navButton("검색", "magnifyingglass", "/explore")
                        Spacer()
                        navButton("알림", "bell", "/notifications")
                        Spacer()
                        navButton("메시지", "envelope", "/messages")
                        Spacer()
                        Button { showSettings = true } label: { Image(systemName: "gearshape") }
                            .accessibilityLabel("Piko 설정")
                    }
                    .padding(.horizontal).frame(minHeight: 44).background(.bar)
                }
            }
            .overlay(alignment: .bottomTrailing) {
                if settings.preferences.hideNativeToolbar {
                    Button { showSettings = true } label: {
                        Image(systemName: "gearshape").padding(12).background(.regularMaterial, in: Circle())
                    }.padding().accessibilityLabel("Piko 설정 열기")
                }
            }
            .navigationTitle(model.url?.host ?? "Piko")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button { model.goBack() } label: { Image(systemName: "chevron.left") }
                        .disabled(!model.canGoBack).accessibilityLabel("뒤로")
                    Button { model.goForward() } label: { Image(systemName: "chevron.right") }
                        .disabled(!model.canGoForward).accessibilityLabel("앞으로")
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button { model.reload() } label: { Image(systemName: "arrow.clockwise") }
                        .accessibilityLabel("새로고침")
                    Menu {
                        Button("홈", systemImage: "house") { model.navigate("/home") }
                        if let url = model.url {
                            ShareLink(item: url) { Label("현재 URL 공유", systemImage: "square.and.arrow.up") }
                            Button("현재 URL 복사", systemImage: "doc.on.doc") { UIPasteboard.general.url = url }
                            Link(destination: url) { Label("외부 브라우저에서 열기", systemImage: "safari") }
                        }
                        Button("Piko 설정", systemImage: "gearshape") { showSettings = true }
                    } label: { Image(systemName: "ellipsis.circle") }
                    .accessibilityLabel("브라우저 메뉴")
                }
            }
            .toolbar(settings.preferences.hideNativeToolbar ? .hidden : .visible, for: .navigationBar)
            .disabled(model.clearingData)
            .sheet(isPresented: $showSettings) { PikoSettingsView(settings: settings, browser: model) }
        }
    }

    private func navButton(_ title: String, _ icon: String, _ path: String) -> some View {
        Button { model.navigate(path) } label: { Image(systemName: icon).frame(minWidth: 44, minHeight: 44) }
            .accessibilityLabel(title)
    }
}
