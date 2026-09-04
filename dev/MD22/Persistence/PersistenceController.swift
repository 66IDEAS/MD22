import Foundation
import SwiftData

@MainActor
final class PersistenceController {
    let container: ModelContainer
    let storeURL: URL?

    init(isStoredInMemoryOnly: Bool = false, storeDirectory: URL? = nil) throws {
        let schema = Schema([
            HistoryRecord.self,
            ReadingStateRecord.self,
            BookmarkRecord.self
        ])

        if isStoredInMemoryOnly {
            storeURL = nil
            let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            container = try ModelContainer(for: schema, configurations: [configuration])
            return
        }

        let directory = try storeDirectory ?? Self.applicationSupportDirectory()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let url = directory.appending(path: "Metadata.store")
        storeURL = url
        let configuration = ModelConfiguration(
            "MD22Metadata",
            schema: schema,
            url: url,
            allowsSave: true,
            cloudKitDatabase: .none
        )
        container = try ModelContainer(for: schema, configurations: [configuration])
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

