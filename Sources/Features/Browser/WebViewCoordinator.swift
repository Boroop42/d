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
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = action.request.url else { decisionHandler(.cancel); return }
        // Subframe loading stays within WebKit; it never receives enhancement scripts.
        if action.targetFrame?.isMainFrame == false { decisionHandler(.allow); return }
        if XURLParser.isInternal(url) {
            decisionHandler(.allow)
        } else {
            decisionHandler(.cancel)
            if ["https", "http"].contains(url.scheme?.lowercased() ?? "") {
                UIApplication.shared.open(url)
            }
        }
    }

    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration,
                 for action: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if action.targetFrame == nil, let url = action.request.url, XURLParser.isInternal(url) {
            webView.load(action.request)
        }
        return nil
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        model.errorMessage = nil
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) { sync() }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) { fail(error) }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) { fail(error) }
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        model.errorMessage = "웹 콘텐츠가 종료되었습니다. 다시 불러오세요."
        model.isLoading = false
        webView.scrollView.refreshControl?.endRefreshing()
    }
    private func fail(_ error: Error) {
        guard (error as NSError).code != NSURLErrorCancelled else { return }
        model.errorMessage = error.localizedDescription
        model.isLoading = false
        model.webView?.scrollView.refreshControl?.endRefreshing()
    }
}
