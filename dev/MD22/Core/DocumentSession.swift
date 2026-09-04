import Foundation
import Observation

@MainActor
@Observable
final class DocumentSession {
    private let fileAccess: any FileAccessing
    private let history: HistoryRepository
    private let bookmarks: BookmarkRepository
    private var loadTask: Task<Void, Never>?
    private var loadingIndicatorTask: Task<Void, Never>?
    private var refreshTask: Task<Void, Never>?
    private var readingLocationSaveTask: Task<Void, Never>?
    private var filePresenter: DocumentFilePresenter?
    private var generation = 0

    private(set) var snapshot: DocumentSnapshot?
    private(set) var analysis: DocumentAnalysis?
    private(set) var isLoading = false
    private(set) var showsLoadingIndicator = false
    private(set) var errorMessage: String?
    private(set) var transientMessage: String?
    private(set) var transientActionURL: URL?
    private(set) var isExporting = false
    private(set) var navigationBackStack: [NavigationEntry] = []
    private(set) var navigationForwardStack: [NavigationEntry] = []
    private(set) var readingLocation = ReadingLocation.beginning
    private(set) var navigationTargetHeadingID: String?
    private(set) var navigationEmphasizesArrival = false
    private(set) var hoveredLinkDestination: String?
    private(set) var selectedText = ""

    init(environment: AppEnvironment) {
        fileAccess = environment.fileAccess
        history = environment.history
        bookmarks = environment.bookmarks
    }

    var title: String? { snapshot?.url.lastPathComponent }
    var windowTitle: String {
        guard let url = snapshot?.url else { return "MD22" }
        let parent = url.deletingLastPathComponent().lastPathComponent
        return parent.isEmpty ? url.lastPathComponent : "\(url.lastPathComponent) — \(parent)"
    }
    var canNavigateBack: Bool { !navigationBackStack.isEmpty }
    var canNavigateForward: Bool { !navigationForwardStack.isEmpty }
    var currentSection: String? {
        guard let headingID = readingLocation.headingID else { return nil }
        return analysis?.headings.first { $0.id == headingID }?.title
    }
    var progressPercentage: Int {
        Int((min(max(readingLocation.progress, 0), 1) * 100).rounded())
    }

    func open(
        _ url: URL,
        recordsNavigation: Bool = true,
        targetHeadingID: String? = nil,
        targetLocation: ReadingLocation? = nil,
        emphasizesArrival: Bool = false
    ) {
        MD22Log.lifecycle.notice("Document open requested")
        MD22Log.record(category: "lifecycle", code: "document.open.requested")
        loadTask?.cancel()
        generation += 1
        let requestedGeneration = generation
        let previousURL = snapshot?.url
        errorMessage = nil
        isLoading = true
        navigationTargetHeadingID = targetHeadingID
        navigationEmphasizesArrival = emphasizesArrival
        showsLoadingIndicator = false
        loadingIndicatorTask?.cancel()
        loadingIndicatorTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(180))
            guard !Task.isCancelled, self?.isLoading == true else { return }
            self?.showsLoadingIndicator = true
        }

        loadTask = Task { [weak self, fileAccess] in
            do {
                let loaded = try await fileAccess.read(url)
                let loadedAnalysis = try await MarkdownAnalysis.analyzeAsync(loaded.markdown)
                try Task.checkCancellation()
                guard let self, requestedGeneration == self.generation else { return }
                if recordsNavigation, let previousURL, previousURL != loaded.url {
                    self.navigationBackStack.append(NavigationEntry(url: previousURL, location: self.readingLocation))
                    self.navigationForwardStack.removeAll()
                }
                self.snapshot = loaded
                self.analysis = loadedAnalysis
                MD22Log.lifecycle.notice("Document open completed; bytes=\(loaded.markdown.utf8.count, privacy: .public)")
                MD22Log.record(category: "lifecycle", code: "document.open.completed")
                _ = try self.history.recordOpen(loaded)
                self.readingLocation = try targetLocation ?? self.history.readingLocation(for: loaded.url)
                try self.bookmarks.reconcile(snapshot: loaded, analysis: self.analysis ?? DocumentAnalysis(headings: [], wordCount: 0, estimatedReadingMinutes: 1))
                self.isLoading = false
                self.showsLoadingIndicator = false
                self.loadingIndicatorTask?.cancel()
                self.monitor(loaded.url)
            } catch is CancellationError {
                return
            } catch {
                MD22Log.lifecycle.error("Document open failed: \(MD22Log.identifier(for: error), privacy: .public)")
                MD22Log.record(category: "lifecycle", code: "document.open.failed")
                guard let self, requestedGeneration == self.generation else { return }
                self.isLoading = false
                self.showsLoadingIndicator = false
                self.loadingIndicatorTask?.cancel()
                if self.snapshot == nil {
                    self.errorMessage = error.localizedDescription
                } else {
                    self.showTransientMessage(error.localizedDescription)
                }
            }
        }
    }

    func navigateBack() {
        guard let destination = navigationBackStack.popLast() else { return }
        if let current = snapshot?.url {
            navigationForwardStack.append(NavigationEntry(url: current, location: readingLocation))
        }
        open(destination.url, recordsNavigation: false, targetLocation: destination.location)
    }

    func navigateForward() {
        guard let destination = navigationForwardStack.popLast() else { return }
        if let current = snapshot?.url {
            navigationBackStack.append(NavigationEntry(url: current, location: readingLocation))
        }
        open(destination.url, recordsNavigation: false, targetLocation: destination.location)
    }

    func cancel() {
        generation += 1
        loadTask?.cancel()
        loadTask = nil
        loadingIndicatorTask?.cancel()
        loadingIndicatorTask = nil
        showsLoadingIndicator = false
        refreshTask?.cancel()
        refreshTask = nil
        readingLocationSaveTask?.cancel()
        readingLocationSaveTask = nil
        filePresenter?.invalidate()
        filePresenter = nil
    }

    func refreshAfterExternalChange(debounce: Duration = .milliseconds(280)) {
        guard snapshot != nil else { return }
        refreshTask?.cancel()
        refreshTask = Task { [weak self] in
            try? await Task.sleep(for: debounce)
            guard !Task.isCancelled else { return }
            await self?.reloadCurrentSnapshot()
        }
    }

    func updateReadingLocation(_ location: ReadingLocation) {
        guard readingLocation != location else { return }
        readingLocation = location
        guard let url = snapshot?.url else { return }
        readingLocationSaveTask?.cancel()
        readingLocationSaveTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(350))
            guard !Task.isCancelled else { return }
            try? self?.history.saveReadingLocation(location, for: url)
        }
    }

    func updateRendererState(_ state: RendererViewState) {
        hoveredLinkDestination = state.linkDestination
        selectedText = state.selectedText
        updateReadingLocation(state.location)
    }

    func showTransientMessage(_ message: String, actionURL: URL? = nil) {
        transientMessage = message
        transientActionURL = actionURL
        Task { [weak self] in
            try? await Task.sleep(for: .seconds(3))
            guard self?.transientMessage == message else { return }
            self?.transientMessage = nil
            self?.transientActionURL = nil
        }
    }

    func beginExport() {
        isExporting = true
        transientMessage = nil
        transientActionURL = nil
    }

    func finishExport(at url: URL) {
        isExporting = false
        showTransientMessage("Exported \(url.lastPathComponent)", actionURL: url)
    }

    func failExport() {
        isExporting = false
    }

    private func monitor(_ url: URL) {
        guard filePresenter?.presentedItemURL != url.standardizedFileURL else { return }
        filePresenter?.invalidate()
        filePresenter = DocumentFilePresenter(
            url: url,
            changeHandler: { [weak self] in
                Task { @MainActor in self?.refreshAfterExternalChange() }
            },
            moveHandler: { [weak self] newURL in
                Task { @MainActor in self?.handleMove(to: newURL) }
            }
        )
    }

    private func reloadCurrentSnapshot() async {
        guard let url = snapshot?.url else { return }
        generation += 1
        let requestedGeneration = generation
        do {
            guard await fileAccess.isAvailable(url) else { throw MD22Error.unavailableFile }
            let loaded = try await fileAccess.read(url)
            let loadedAnalysis = try await MarkdownAnalysis.analyzeAsync(loaded.markdown)
            try Task.checkCancellation()
            guard requestedGeneration == generation else { return }
            guard loaded != snapshot else { return }
            snapshot = loaded
            analysis = loadedAnalysis
            MD22Log.lifecycle.notice("External document refresh completed")
            MD22Log.record(category: "lifecycle", code: "document.refresh.completed")
            _ = try history.recordOpen(loaded)
            try bookmarks.reconcile(snapshot: loaded, analysis: analysis ?? DocumentAnalysis(headings: [], wordCount: 0, estimatedReadingMinutes: 1))
            showTransientMessage(String(localized: "Refreshed"))
        } catch is CancellationError {
            return
        } catch {
            MD22Log.lifecycle.error("External document refresh failed: \(MD22Log.identifier(for: error), privacy: .public)")
            MD22Log.record(category: "lifecycle", code: "document.refresh.failed")
            guard requestedGeneration == generation else { return }
            try? history.markUnavailable(path: url.standardizedFileURL.path)
            showTransientMessage(MD22Error.unavailableFile.localizedDescription)
        }
    }

    private func handleMove(to newURL: URL) {
        guard let oldURL = snapshot?.url else { return }
        try? history.markUnavailable(path: oldURL.standardizedFileURL.path)
        open(newURL, recordsNavigation: false)
        showTransientMessage(String(localized: "The file moved. Its new location is open."))
    }

    @discardableResult
    func bookmarkCurrentHeading() throws -> BookmarkRecord {
        guard let snapshot,
              let headingID = readingLocation.headingID,
              let heading = analysis?.headings.first(where: { $0.id == headingID }) else {
            return try bookmarkCurrentPosition()
        }
        return try bookmarks.add(
            url: snapshot.url,
            kind: .heading,
            headingID: headingID,
            title: heading.title,
            excerpt: nil,
            location: readingLocation
        )
    }

    @discardableResult
    func bookmarkHeading(_ headingID: String) throws -> BookmarkRecord {
        guard let snapshot,
              let heading = analysis?.headings.first(where: { $0.id == headingID }) else {
            throw MD22Error.unavailableFile
        }
        let location = ReadingLocation(
            headingID: headingID,
            progress: readingLocation.progress,
            verticalOffset: readingLocation.verticalOffset
        )
        return try bookmarks.add(
            url: snapshot.url,
            kind: .heading,
            headingID: headingID,
            title: heading.title,
            excerpt: nil,
            location: location
        )
    }

    @discardableResult
    func bookmarkSelection() throws -> BookmarkRecord {
        let excerpt = selectedText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let snapshot, !excerpt.isEmpty else { return try bookmarkCurrentPosition() }
        return try bookmarks.add(
            url: snapshot.url,
            kind: .passage,
            headingID: readingLocation.headingID,
            title: excerpt,
            excerpt: excerpt,
            location: readingLocation
        )
    }

    @discardableResult
    func bookmarkCurrentPosition() throws -> BookmarkRecord {
        guard let snapshot else { throw MD22Error.unavailableFile }
        let heading = readingLocation.headingID.flatMap { id in analysis?.headings.first { $0.id == id }?.title }
        return try bookmarks.add(
            url: snapshot.url,
            kind: .position,
            headingID: readingLocation.headingID,
            title: heading ?? "Position \(Int(readingLocation.progress * 100))%",
            excerpt: nil,
            location: readingLocation
        )
    }
}
