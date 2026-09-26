import SwiftUI

@main
struct PikoIOSApp: App {
    @StateObject private var state = AppState()
    var body: some Scene {
        WindowGroup { BrowserView(state: state) }
    }
}
