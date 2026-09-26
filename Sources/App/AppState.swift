import Combine

@MainActor
final class AppState: ObservableObject {
    let settings = SettingsStore()
    let browser = BrowserViewModel()
}
