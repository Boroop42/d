import Foundation

enum BrowserRequest {
    static func request(path: String) -> URLRequest? {
        guard path.hasPrefix("/"), let url = URL(string: "https://x.com" + path),
              XURLParser.isInternal(url) else { return nil }
        return URLRequest(url: url, cachePolicy: .reloadRevalidatingCacheData, timeoutInterval: 30)
    }
}
