import Observation

@MainActor
@Observable
final class AppEnvironment {
    let fileAccess: any FileAccessing
    let platform: any PlatformIntegrating
    let router: DocumentRouter
    let persistence: PersistenceController
    let accessibility = AccessibilityPreferences()
    let preferences = PreferencesStore()

    init(
        fileAccess: any FileAccessing = FileAccessService(),
        platform: any PlatformIntegrating = PlatformIntegrationService(),
        persistence: PersistenceController? = nil
    ) {
        self.fileAccess = fileAccess
        self.platform = platform
        router = DocumentRouter(platform: platform)
        self.persistence = persistence ?? (try! PersistenceController())
    }
}
