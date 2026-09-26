import WebKit

@MainActor
enum WebsiteDataManager {
    static func clear(in store: WKWebsiteDataStore, includingLogin: Bool) async {
        let types = includingLogin ? WKWebsiteDataStore.allWebsiteDataTypes() : Set([
            WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache
        ])
        let records = await store.dataRecords(ofTypes: types)
        let matching = records.filter { XURLParser.isXDataDomain($0.displayName) }
        await store.removeData(ofTypes: types, for: matching)
    }
}
