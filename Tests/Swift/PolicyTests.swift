import XCTest
@testable import PikoIOS

final class PolicyTests: XCTestCase {
    func testInternalNavigationBoundary() throws {
        for value in ["https://x.com/home", "https://www.x.com/home", "https://mobile.x.com/home",
                      "https://foo.x.com/test", "https://twitter.com/home", "https://mobile.twitter.com/home",
                      "https://twitter.com/a/status/1", "https://www.x.com/search?q=piko"] {
            XCTAssertTrue(XURLParser.isInternal(try XCTUnwrap(URL(string: value))))
        }
        for value in ["http://x.com", "javascript:alert(1)", "https://x.com.evil.com", "https://evilx.com",
                      "https://faketwitter.com", "https://x.com:8443", "https://name@x.com"] {
            XCTAssertFalse(XURLParser.isInternal(try XCTUnwrap(URL(string: value))))
        }
    }

    func testMainFrameRoutingSeparatesRedirectsFromUserLinks() throws {
        for address in ["https://mobile.x.com/home", "https://foo.twitter.com/login", "about:blank"] {
            let url = try XCTUnwrap(URL(string: address))
            XCTAssertEqual(NavigationPolicy.decide(url: url, userActivatedLink: false, isMainFrame: true), .allow)
        }
        let external = try XCTUnwrap(URL(string: "https://example.org/page"))
        XCTAssertEqual(NavigationPolicy.decide(url: external, userActivatedLink: true, isMainFrame: true), .openExternal)
        XCTAssertEqual(NavigationPolicy.decide(url: external, userActivatedLink: false, isMainFrame: true), .cancel)
        XCTAssertEqual(NavigationPolicy.decide(url: external, userActivatedLink: true, isMainFrame: false), .allow)
        for address in ["javascript:alert(1)", "myapp://open", "about:config", "about:blank?token=secret", "file:///tmp/test"] {
            let url = try XCTUnwrap(URL(string: address))
            XCTAssertEqual(NavigationPolicy.decide(url: url, userActivatedLink: true, isMainFrame: true), .cancel)
            XCTAssertEqual(NavigationPolicy.decide(url: url, userActivatedLink: false, isMainFrame: false), .cancel)
        }
    }

    func testOnlyKnownInterruptionDomainsAreIgnored() {
        XCTAssertTrue(NavigationErrorPolicy.isExpectedInterruption(NSError(domain: NSURLErrorDomain, code: NSURLErrorCancelled)))
        XCTAssertTrue(NavigationErrorPolicy.isExpectedInterruption(NSError(domain: "WebKitErrorDomain", code: 102)))
        XCTAssertFalse(NavigationErrorPolicy.isExpectedInterruption(NSError(domain: NSURLErrorDomain, code: 102)))
        XCTAssertFalse(NavigationErrorPolicy.isExpectedInterruption(NSError(domain: "OtherDomain", code: NSURLErrorCancelled)))
        for code in [NSURLErrorNotConnectedToInternet, NSURLErrorCannotFindHost,
                     NSURLErrorDNSLookupFailed, NSURLErrorSecureConnectionFailed, NSURLErrorTimedOut] {
            XCTAssertFalse(NavigationErrorPolicy.isExpectedInterruption(NSError(domain: NSURLErrorDomain, code: code)))
        }
    }

    func testOldFailureCannotCoverNewNavigationOrFinishedPage() {
        let old = NSObject(), current = NSObject()
        let offline = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet)
        var state = MainFrameNavigationState()
        state.begin(old)
        state.begin(current)
        XCTAssertFalse(state.shouldPresent(offline, for: old))
        XCTAssertFalse(state.shouldPresent(offline, for: nil))
        XCTAssertFalse(state.finish(old))
        XCTAssertTrue(state.shouldPresent(offline, for: current))
        XCTAssertFalse(state.shouldPresent(NSError(domain: "WebKitErrorDomain", code: 102), for: current))
        XCTAssertTrue(state.isCurrent(current))
        XCTAssertTrue(state.finish(current))
        XCTAssertFalse(state.shouldPresent(offline, for: current))
    }

    func testHomeRequestHasExplicitTimeoutAndRevalidationPolicy() throws {
        let request = try XCTUnwrap(BrowserRequest.request(path: "/home"))
        XCTAssertEqual(request.url?.absoluteString, "https://x.com/home")
        XCTAssertEqual(request.timeoutInterval, 30)
        XCTAssertEqual(request.cachePolicy, .reloadRevalidatingCacheData)
    }

    func testDebugURLNeverIncludesCredentialsQueryFragmentOrUnknownPath() throws {
        let url = try XCTUnwrap(URL(string: "https://user:password@mobile.x.com/private-token?auth=secret#session"))
        XCTAssertEqual(NavigationDiagnostics.redactedURL(url), "https://mobile.x.com/<path-redacted>")
        let home = try XCTUnwrap(URL(string: "https://x.com/home?token=secret"))
        XCTAssertEqual(NavigationDiagnostics.redactedURL(home), "https://x.com/home")
        XCTAssertEqual(NavigationDiagnostics.redactedURL(URL(string: "myapp://secret")), "<non-web URL>")
    }
    func testDataDeletionBoundary() {
        XCTAssertTrue(XURLParser.isXDataDomain(".x.com"))
        XCTAssertTrue(XURLParser.isXDataDomain("pbs.twimg.com"))
        XCTAssertFalse(XURLParser.isXDataDomain("notx.com"))
        XCTAssertFalse(XURLParser.isXDataDomain("x.com.example.org"))
    }
    @MainActor
    func testSettingsSurviveRelaunchAndReset() throws {
        let suite = "PikoTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let first = SettingsStore(defaults: defaults)
        first.preferences.hidePromotedPosts = true
        first.preferences.postFontPercent = 145
        first.preferences.hideNativeToolbar = true
        let second = SettingsStore(defaults: defaults)
        XCTAssertEqual(first.preferences, second.preferences)
        second.resetRules()
        XCTAssertFalse(second.preferences.hidePromotedPosts)
        XCTAssertEqual(second.preferences.postFontPercent, 100)
        XCTAssertTrue(second.preferences.hideNativeToolbar)
    }
}
