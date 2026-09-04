import Observation

@MainActor
@Observable
final class AppEnvironment {
    let fileAccess: any FileAccessing
    let platform: any PlatformIntegrating
    let router: DocumentRouter
    let accessibility = AccessibilityPreferences()
    let preferences = PreferencesStore()

    init(
        fileAccess: any FileAccessing = FileAccessService(),
        platform: any PlatformIntegrating = PlatformIntegrationService()
    ) {
        self.fileAccess = fileAccess
        self.platform = platform
        router = DocumentRouter(platform: platform)
    }
}
