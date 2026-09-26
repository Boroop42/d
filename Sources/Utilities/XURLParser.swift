import Foundation

enum XURLParser {
    static func isInternal(_ url: URL) -> Bool {
        guard url.scheme?.lowercased() == "https",
              url.user == nil, url.password == nil,
              url.port == nil || url.port == 443,
              let host = url.host?.lowercased() else { return false }
        return ["x.com", "www.x.com", "twitter.com", "www.twitter.com"].contains(host)
    }

    static func isXDataDomain(_ domain: String) -> Bool {
        let host = domain.lowercased().trimmingCharacters(in: CharacterSet(charactersIn: "."))
        return ["x.com", "twitter.com", "twimg.com"].contains {
            host == $0 || host.hasSuffix("." + $0)
        }
    }
}
