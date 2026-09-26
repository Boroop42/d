import Foundation

enum NavigationDiagnostics {
    /// Login tokens can occur in a URL path as well as a query. Only known static routes are shown.
    static func redactedURL(_ url: URL?) -> String {
        guard let url else { return "<none>" }
        if XURLParser.isSafeBlank(url) { return "about:blank" }
        guard let scheme = url.scheme?.lowercased(), ["http", "https"].contains(scheme),
              let host = url.host else { return "<non-web URL>" }
        let safePaths = ["", "/", "/home", "/explore", "/notifications", "/messages", "/search", "/i/flow/login"]
        let path = safePaths.contains(url.path) ? url.path : "/<path-redacted>"
        let port = url.port.map { ":\($0)" } ?? ""
        return "\(scheme)://\(host)\(port)\(path)"
    }

    static func navigation(url: URL?, type: Int, mainFrame: Bool?, decision: NavigationDecision) {
        #if DEBUG
        let frame = mainFrame.map { String($0) } ?? "new-window"
        print("[PikoNavigation] URL=\(redactedURL(url)) host=\(url?.host ?? "<none>") type=\(type) mainFrame=\(frame) decision=\(decision.rawValue)")
        #endif
    }

    static func failure(_ error: NSError, ignored: Bool) {
        #if DEBUG
        let failingURL = (error.userInfo[NSURLErrorFailingURLErrorKey] as? URL) ??
            (error.userInfo[NSURLErrorFailingURLStringErrorKey] as? String).flatMap(URL.init(string:))
        print("[PikoNavigation] didFail domain=\(error.domain) code=\(error.code) URL=\(redactedURL(failingURL)) ignored=\(ignored)")
        #endif
    }
}
