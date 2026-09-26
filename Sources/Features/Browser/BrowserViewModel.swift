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
    var navigationState = MainFrameNavigationState()
    private var removalContinuation: CheckedContinuation<Void, Never>?

    func navigate(_ path: String) {
        guard let request = BrowserRequest.request(path: path), let webView else { return }
        start(webView.load(request))
    }

    func reload() {
        errorMessage = nil
        if let url = webView?.url, !XURLParser.isSafeBlank(url) {
            start(webView?.reload())
        } else {
            navigate("/home")
        }
    }

    func goBack() { start(webView?.goBack()) }
    func goForward() { start(webView?.goForward()) }

    func start(_ navigation: WKNavigation?) {
        guard let navigation else { return }
        errorMessage = nil
        navigationState.begin(navigation)
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
        navigationState = MainFrameNavigationState()
        removalContinuation?.resume()
        removalContinuation = nil
    }
}
