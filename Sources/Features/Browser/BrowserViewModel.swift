import Combine
import WebKit

@MainActor
final class BrowserViewModel: ObservableObject {
    @Published var url: URL?
    @Published var canGoBack = false
    @Published var canGoForward = false
    @Published var isLoading = false
    @Published var progress = 0.0
    @Published var errorMessage: String?
    @Published var clearingData = false
    @Published var webViewID = UUID()
    weak var webView: WKWebView?
    private var removalContinuation: CheckedContinuation<Void, Never>?

    func navigate(_ path: String) {
        guard let target = URL(string: "https://x.com" + path) else { return }
        errorMessage = nil
        webView?.load(URLRequest(url: target))
    }

    func reload() {
        errorMessage = nil
        if webView?.url == nil { navigate("/home") } else { webView?.reload() }
    }

    func clearWebsiteData(includingLogin: Bool) async {
        guard !clearingData else { return }
        if webView != nil {
            // Wait for UIViewRepresentable's teardown before deleting website data.
            await withCheckedContinuation { continuation in
                removalContinuation = continuation
                clearingData = true
            }
        } else {
            clearingData = true
        }
        await WebsiteDataManager.clear(in: .default(), includingLogin: includingLogin)
        webViewID = UUID()
        errorMessage = nil
        clearingData = false
    }

    func didDismantle(_ view: WKWebView) {
        guard webView === view else { return }
        webView = nil
        removalContinuation?.resume()
        removalContinuation = nil
    }
}
