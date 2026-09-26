import XCTest
@testable import PikoIOS

final class PolicyTests: XCTestCase {
    func testInternalNavigationBoundary() throws {
        for value in ["https://x.com/home", "https://twitter.com/a/status/1", "https://www.x.com/search?q=piko"] {
            XCTAssertTrue(XURLParser.isInternal(try XCTUnwrap(URL(string: value))))
        }
        for value in ["http://x.com", "https://x.com.evil.example", "https://evilx.com", "https://x.com:8443", "https://name@x.com"] {
            XCTAssertFalse(XURLParser.isInternal(try XCTUnwrap(URL(string: value))))
        }
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
