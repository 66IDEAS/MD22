import Observation

@MainActor
@Observable
final class AppEnvironment {
    let fileAccess: any FileAccessing
    let platform: any PlatformIntegrating
    let accessibility = AccessibilityPreferences()

    init(
        fileAccess: any FileAccessing = FileAccessService(),
        platform: any PlatformIntegrating = PlatformIntegrationService()
    ) {
        self.fileAccess = fileAccess
        self.platform = platform
    }
}
