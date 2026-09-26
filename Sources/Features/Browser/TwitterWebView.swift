import SwiftUI
import WebKit

struct TwitterWebView: UIViewRepresentable {
    @ObservedObject var model: BrowserViewModel
    let preferences: PikoPreferences

    func makeCoordinator() -> WebViewCoordinator { WebViewCoordinator(model: model) }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .default()
        configuration.allowsInlineMediaPlayback = true
        let view = WKWebView(frame: .zero, configuration: configuration)
        view.allowsBackForwardNavigationGestures = true
        view.navigationDelegate = context.coordinator
        view.uiDelegate = context.coordinator
        view.scrollView.contentInsetAdjustmentBehavior = .automatic
        let refresh = UIRefreshControl()
        refresh.addTarget(context.coordinator, action: #selector(WebViewCoordinator.refresh), for: .valueChanged)
        view.scrollView.refreshControl = refresh
        model.webView = view
        context.coordinator.observe(view)
        context.coordinator.apply(preferences, to: view)
        model.navigate("/home")
        return view
    }

    func updateUIView(_ view: WKWebView, context: Context) {
        context.coordinator.apply(preferences, to: view)
    }

    static func dismantleUIView(_ view: WKWebView, coordinator: WebViewCoordinator) {
        coordinator.invalidate()
        view.stopLoading()
        view.navigationDelegate = nil
        view.uiDelegate = nil
        view.configuration.userContentController.removeAllUserScripts()
        coordinator.model.didDismantle(view)
    }
}
