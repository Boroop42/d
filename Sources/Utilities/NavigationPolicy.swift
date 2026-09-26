import Foundation

enum NavigationDecision: String {
    case allow, openExternal, cancel
}

enum NavigationPolicy {
    static func decide(url: URL?, userActivatedLink: Bool, isMainFrame: Bool) -> NavigationDecision {
        guard let url else { return .cancel }
        if XURLParser.isInternal(url) || XURLParser.isSafeBlank(url) { return .allow }
        guard let scheme = url.scheme?.lowercased(), let host = url.host, !host.isEmpty,
              url.user == nil, url.password == nil else { return .cancel }
        // Third-party HTTPS frames may be needed by the website; never launch an app for a frame.
        if !isMainFrame { return scheme == "https" ? .allow : .cancel }
        // Untrusted automatic redirects cannot launch Safari or replace the trusted main page.
        if userActivatedLink && ["https", "http"].contains(scheme) { return .openExternal }
        return .cancel
    }
}

enum NavigationErrorPolicy {
    static func isExpectedInterruption(_ error: NSError) -> Bool {
        (error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled) ||
        (error.domain == "WebKitErrorDomain" && error.code == 102)
    }
}

/// Retains the current navigation so a delayed failure from an old load cannot cover a newer page.
struct MainFrameNavigationState {
    private var current: AnyObject?
    mutating func begin(_ navigation: AnyObject) { current = navigation }
    func isCurrent(_ navigation: AnyObject?) -> Bool {
        guard let navigation, let current else { return false }
        return navigation === current
    }
    func shouldPresent(_ error: NSError, for navigation: AnyObject?) -> Bool {
        isCurrent(navigation) && !NavigationErrorPolicy.isExpectedInterruption(error)
    }
    mutating func finish(_ navigation: AnyObject?) -> Bool {
        guard isCurrent(navigation) else { return false }
        current = nil
        return true
    }
}
