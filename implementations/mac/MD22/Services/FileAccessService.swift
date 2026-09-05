import Foundation

actor FileAccessService: FileAccessing {
    func read(_ url: URL) async throws -> DocumentSnapshot {
        MD22Log.fileAccess.debug("Coordinated file read started")
        MD22Log.record(category: "file-access", code: "read.started")
        return try await Task.detached(priority: .userInitiated) {
            var coordinationError: NSError?
            var result: Result<DocumentSnapshot, Error>?
            let coordinator = NSFileCoordinator(filePresenter: nil)
            coordinator.coordinate(readingItemAt: url, options: [.withoutChanges], error: &coordinationError) { coordinatedURL in
                result = Result {
                    let values = try coordinatedURL.resourceValues(
                        forKeys: [.contentModificationDateKey, .fileResourceIdentifierKey]
                    )
                    let data = try Data(contentsOf: coordinatedURL, options: [.mappedIfSafe, .uncached])
                    guard let markdown = String(data: data, encoding: .utf8) else {
                        throw MD22Error.invalidEncoding
                    }
                    return DocumentSnapshot(
                        url: url.standardizedFileURL,
                        markdown: markdown,
                        modificationDate: values.contentModificationDate,
                        fileIdentifier: values.fileResourceIdentifier.map { String(describing: $0) }
                    )
                }
            }
            if let coordinationError { throw coordinationError }
            guard let result else { throw MD22Error.unreadableFile }
            let snapshot = try result.get()
            MD22Log.fileAccess.debug("Coordinated file read completed; bytes=\(snapshot.markdown.utf8.count, privacy: .public)")
            MD22Log.record(category: "file-access", code: "read.completed")
            return snapshot
        }.value
    }

    func isAvailable(_ url: URL) async -> Bool {
        await Task.detached(priority: .utility) {
            var isReachable = false
            var coordinationError: NSError?
            NSFileCoordinator(filePresenter: nil).coordinate(
                readingItemAt: url,
                options: [.withoutChanges],
                error: &coordinationError
            ) { coordinatedURL in
                isReachable = (try? coordinatedURL.checkResourceIsReachable()) == true
            }
            return coordinationError == nil && isReachable
        }.value
    }
}

/// Bridges coordinated filesystem notifications into the window's document session.
/// Each session owns exactly one presenter, and replacing it atomically unregisters
/// the previous file before presenting the next one.
final class DocumentFilePresenter: NSObject, NSFilePresenter, @unchecked Sendable {
    let presentedItemOperationQueue: OperationQueue
    private(set) var presentedItemURL: URL?
    private let changeHandler: @Sendable () -> Void
    private let moveHandler: @Sendable (URL) -> Void

    init(
        url: URL,
        changeHandler: @escaping @Sendable () -> Void,
        moveHandler: @escaping @Sendable (URL) -> Void
    ) {
        presentedItemURL = url.standardizedFileURL
        self.changeHandler = changeHandler
        self.moveHandler = moveHandler
        let queue = OperationQueue()
        queue.name = "MD22.DocumentFilePresenter"
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1
        presentedItemOperationQueue = queue
        super.init()
        NSFileCoordinator.addFilePresenter(self)
    }

    func presentedItemDidChange() {
        changeHandler()
    }

    func presentedItemDidMove(to newURL: URL) {
        presentedItemURL = newURL.standardizedFileURL
        moveHandler(newURL.standardizedFileURL)
    }

    func presentedItemDidDisappear() {
        changeHandler()
    }

    func invalidate() {
        NSFileCoordinator.removeFilePresenter(self)
        presentedItemOperationQueue.cancelAllOperations()
    }

    deinit {
        NSFileCoordinator.removeFilePresenter(self)
    }
}
