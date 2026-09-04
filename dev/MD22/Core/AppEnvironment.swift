import Observation
import Foundation

@MainActor
@Observable
final class AppEnvironment {
    let fileAccess: any FileAccessing
    let platform: any PlatformIntegrating
    let router: DocumentRouter
    let persistence: PersistenceController
    let history: HistoryRepository
    let bookmarks: BookmarkRepository
    let exportService = DocumentExportService()
    let updateService = UpdateService()
    let accessibility = AccessibilityPreferences()
    let preferences = PreferencesStore()

    init(
        fileAccess: any FileAccessing = FileAccessService(),
        platform: any PlatformIntegrating = PlatformIntegrationService(),
        persistence: PersistenceController? = nil,
        defaults: UserDefaults = .standard
    ) {
        self.fileAccess = fileAccess
        self.platform = platform
        router = DocumentRouter(platform: platform)
        self.persistence = persistence ?? PersistenceController.openRecovering()
        history = HistoryRepository(container: self.persistence.container, defaults: defaults)
        bookmarks = BookmarkRepository(container: self.persistence.container)
    }
}
