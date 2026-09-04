import Foundation
import SwiftData

@MainActor
final class PersistenceController {
    let container: ModelContainer
    let storeURL: URL?

    init(isStoredInMemoryOnly: Bool = false, storeDirectory: URL? = nil) throws {
        let schema = Schema(versionedSchema: MD22SchemaV1.self)

        if isStoredInMemoryOnly {
            storeURL = nil
            let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            container = try ModelContainer(for: schema, configurations: [configuration])
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
    }

    static func openRecovering(storeDirectory: URL? = nil) -> PersistenceController {
        let directory = try? storeDirectory ?? applicationSupportDirectory()
        do {
            return try PersistenceController(storeDirectory: directory)
        } catch {
            if let directory {
                _ = try? StoreRecovery.preserveDamagedStore(in: directory)
                if let recovered = try? PersistenceController(storeDirectory: directory) {
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
