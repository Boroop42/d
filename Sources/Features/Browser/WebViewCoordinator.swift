import UIKit
import WebKit

@MainActor
final class WebViewCoordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
    let model: BrowserViewModel
    private var observations: [NSKeyValueObservation] = []
    private var appliedPreferences: PikoPreferences?
    private static let world = WKContentWorld.world(name: "PikoEnhancements")

    init(model: BrowserViewModel) { self.model = model }

    func observe(_ view: WKWebView) {
        observations = [
            view.observe(\.url, options: [.new]) { [weak self] _, _ in self?.scheduleSync() },
            view.observe(\.estimatedProgress, options: [.new]) { [weak self] _, _ in self?.scheduleSync() },
            view.observe(\.isLoading, options: [.new]) { [weak self] _, _ in self?.scheduleSync() },
            view.observe(\.canGoBack, options: [.new]) { [weak self] _, _ in self?.scheduleSync() },
            view.observe(\.canGoForward, options: [.new]) { [weak self] _, _ in self?.scheduleSync() }
        ]
    }

    nonisolated private func scheduleSync() {
        Task { @MainActor [weak self] in self?.sync() }
    }

    private func sync() {
        guard let view = model.webView else { return }
        model.url = view.url
        model.progress = view.estimatedProgress
        model.isLoading = view.isLoading
        model.canGoBack = view.canGoBack
        model.canGoForward = view.canGoForward
        if !view.isLoading { view.scrollView.refreshControl?.endRefreshing() }
    }

    func invalidate() { observations.removeAll() }
    @objc func refresh() { model.reload() }

    func apply(_ preferences: PikoPreferences, to view: WKWebView) {
        guard preferences != appliedPreferences else { return }
        appliedPreferences = preferences
        let source = WebScript.source(preferences: preferences)
        let controller = view.configuration.userContentController
        controller.removeAllUserScripts()
        controller.addUserScript(WKUserScript(source: source, injectionTime: .atDocumentEnd,
                                              forMainFrameOnly: true, in: Self.world))
        guard let url = view.url, XURLParser.isInternal(url) else { return }
        view.evaluateJavaScript(source, in: nil, in: Self.world) { _ in
            // Missing selectors or unavailable documents never prevent browsing.
        }
    }

    func webView(_ webView: WKWebView, decidePolicyFor action: WKNavigationAction,
                 decisionHandler: @escaping @MainActor @Sendable (WKNavigationActionPolicy) -> Void) {
        let decision = NavigationPolicy.decide(url: action.request.url,
                                               userActivatedLink: action.navigationType == .linkActivated,
                                               isMainFrame: action.targetFrame?.isMainFrame ?? true)
        NavigationDiagnostics.navigation(url: action.request.url, type: action.navigationType.rawValue,
                                         mainFrame: action.targetFrame?.isMainFrame, decision: decision)
        switch decision {
        case .allow:
            decisionHandler(.allow)
        case .openExternal:
            decisionHandler(.cancel)
            if let url = action.request.url { UIApplication.shared.open(url) }
        case .cancel:
            decisionHandler(.cancel)
        }
    }

    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration,
                 for action: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if action.targetFrame == nil, let url = action.request.url, XURLParser.isInternal(url) {
            model.start(webView.load(action.request))
        }
        return nil
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        model.errorMessage = nil
        model.start(navigation)
    }
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        if model.navigationState.isCurrent(navigation) { model.errorMessage = nil }
    }
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        if model.navigationState.isCurrent(navigation) { model.errorMessage = nil }
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if model.navigationState.finish(navigation) { model.errorMessage = nil }
        sync()
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        fail(error, navigation: navigation)
    }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        fail(error, navigation: navigation)
    }
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        model.errorMessage = "웹 콘텐츠가 종료되었습니다. 다시 불러오세요."
        model.isLoading = false
        webView.scrollView.refreshControl?.endRefreshing()
    }
    private func fail(_ error: Error, navigation: WKNavigation?) {
        // WKNavigationDelegate failure callbacks describe main-frame loads. Match their navigation
        // identity as well, so stale callbacks cannot overwrite a newly started or finished page.
        let shouldPresent = model.navigationState.shouldPresent(error as NSError, for: navigation)
        NavigationDiagnostics.failure(error as NSError, ignored: !shouldPresent)
        guard shouldPresent else { return }
        _ = model.navigationState.finish(navigation)
        model.errorMessage = error.localizedDescription
        model.isLoading = false
        model.webView?.scrollView.refreshControl?.endRefreshing()
    }
}
