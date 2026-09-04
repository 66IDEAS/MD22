import Foundation
import SwiftData

@MainActor
final class PersistenceController {
    let container: ModelContainer
    let storeURL: URL?

    init(isStoredInMemoryOnly: Bool = false, storeDirectory: URL? = nil) throws {
        MD22Log.persistence.debug("Persistence initialization started; inMemory=\(isStoredInMemoryOnly, privacy: .public)")
        MD22Log.record(category: "persistence", code: "store.open.started")
        let schema = Schema(versionedSchema: MD22SchemaV1.self)

        if isStoredInMemoryOnly {
            storeURL = nil
            let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            container = try ModelContainer(for: schema, configurations: [configuration])
            MD22Log.persistence.debug("In-memory persistence ready")
            MD22Log.record(category: "persistence", code: "store.memory.ready")
            return
        }

        let directory = try storeDirectory ?? Self.applicationSupportDirectory()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        _ = try StoreRecovery.prepareBackupIfNeeded(in: directory)
        let url = directory.appending(path: StoreRecovery.storeName)
        storeURL = url
        let configuration = ModelConfiguration(
            "MD22Metadata",
            schema: schema,
            url: url,
            allowsSave: true,
            cloudKitDatabase: .none
        )
        container = try ModelContainer(
            for: schema,
            migrationPlan: MD22MigrationPlan.self,
            configurations: [configuration]
        )
        try StoreRecovery.writeCurrentVersion(in: directory)
        MD22Log.persistence.notice("Persistent metadata store ready")
        MD22Log.record(category: "persistence", code: "store.disk.ready")
    }

    static func openRecovering(storeDirectory: URL? = nil) -> PersistenceController {
        let directory = try? storeDirectory ?? applicationSupportDirectory()
        do {
            return try PersistenceController(storeDirectory: directory)
        } catch {
            MD22Log.persistence.error("Persistent metadata store failed: \(MD22Log.identifier(for: error), privacy: .public)")
            MD22Log.record(category: "persistence", code: "store.disk.failed")
            if let directory {
                _ = try? StoreRecovery.preserveDamagedStore(in: directory)
                if let recovered = try? PersistenceController(storeDirectory: directory) {
                    MD22Log.persistence.notice("Persistent metadata store recovered")
                    MD22Log.record(category: "persistence", code: "store.disk.recovered")
                    return recovered
                }
            }
            return try! PersistenceController(isStoredInMemoryOnly: true)
        }
    }

    static func applicationSupportDirectory() throws -> URL {
        let root = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        return root.appending(path: "MD22", directoryHint: .isDirectory)
    }
}
