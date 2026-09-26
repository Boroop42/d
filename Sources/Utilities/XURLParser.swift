import Foundation

enum XURLParser {
    static func isInternal(_ url: URL) -> Bool {
        guard url.scheme?.lowercased() == "https",
              url.user == nil, url.password == nil,
              url.port == nil || url.port == 443,
              let host = url.host?.lowercased() else { return false }
        return isXHost(host)
    }

    static func isXHost(_ host: String) -> Bool {
        let host = host.lowercased()
        return ["x.com", "twitter.com"].contains { host == $0 || host.hasSuffix("." + $0) }
    }

    static func isSafeBlank(_ url: URL) -> Bool {
        url.absoluteString.lowercased() == "about:blank"
    }

    static func isXDataDomain(_ domain: String) -> Bool {
        let host = domain.lowercased().trimmingCharacters(in: CharacterSet(charactersIn: "."))
        return ["x.com", "twitter.com", "twimg.com"].contains {
            host == $0 || host.hasSuffix("." + $0)
        }
    }
}
