import Foundation

actor FileAccessService: FileAccessing {
    func read(_ url: URL) async throws -> DocumentSnapshot {
        let values = try url.resourceValues(forKeys: [.contentModificationDateKey, .fileResourceIdentifierKey])
        let data = try Data(contentsOf: url, options: [.mappedIfSafe])
        guard let markdown = String(data: data, encoding: .utf8) else {
            throw MD22Error.invalidEncoding
        }
        return DocumentSnapshot(
            url: url,
            markdown: markdown,
            modificationDate: values.contentModificationDate,
            fileIdentifier: values.fileResourceIdentifier.map { String(describing: $0) }
        )
    }

    func isAvailable(_ url: URL) async -> Bool {
        FileManager.default.isReadableFile(atPath: url.path)
    }
}

