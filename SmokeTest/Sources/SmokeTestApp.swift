import SwiftUI
import WebKit

@main
struct SmokeTestApp: App {
    var body: some Scene {
        WindowGroup { SmokeTestView() }
    }
}

@MainActor
final class EventLog: ObservableObject {
    @Published var lines: [String] = []

    func record(_ event: String, webView: WKWebView, error: Error? = nil) {
        // Only the host is shown: never URL paths, queries, headers or error descriptions.
        var line = "\(event) | host: \(webView.url?.host ?? "—")"
        if let error {
            let nsError = error as NSError
            line += " | \(nsError.domain)/\(nsError.code)"
        }
        lines.append(line)
        if lines.count > 8 { lines.removeFirst(lines.count - 8) }
    }
}

struct SmokeTestView: View {
    @StateObject private var log = EventLog()

    var body: some View {
        VStack(spacing: 0) {
            SmokeWebView(log: log)
            VStack(alignment: .leading, spacing: 2) {
                Text("WKWebView events (latest 8)").bold()
                ForEach(Array(log.lines.enumerated()), id: \.offset) { _, line in
                    Text(line).fixedSize(horizontal: false, vertical: true)
                }
            }
            .font(.system(size: 9, design: .monospaced))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(6)
            .background(Color(uiColor: .secondarySystemBackground))
        }
    }
}

struct SmokeWebView: UIViewRepresentable {
    let log: EventLog

    func makeCoordinator() -> Coordinator { Coordinator(log: log) }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .default()
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        let view = WKWebView(frame: .zero, configuration: configuration)
        view.navigationDelegate = context.coordinator
        view.load(URLRequest(url: URL(string: "https://x.com/home")!))
        return view
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    // Observation only. No policy delegate, URL filtering, scripts, or Safari handoff.
    @MainActor
    final class Coordinator: NSObject, WKNavigationDelegate {
        let log: EventLog
        init(log: EventLog) { self.log = log }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            log.record("didStartProvisionalNavigation", webView: webView)
        }
        func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
            log.record("didReceiveServerRedirectForProvisionalNavigation", webView: webView)
        }
        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            log.record("didCommit", webView: webView)
        }
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            log.record("didFinish", webView: webView)
        }
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            log.record("didFail", webView: webView, error: error)
        }
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            log.record("didFailProvisionalNavigation", webView: webView, error: error)
        }
    }
}
