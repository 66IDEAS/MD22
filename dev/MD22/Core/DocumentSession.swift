import Foundation
import Observation

@MainActor
@Observable
final class DocumentSession {
    private let fileAccess: any FileAccessing
    private let history: HistoryRepository
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
    private(set) var navigationBackStack: [URL] = []
    private(set) var navigationForwardStack: [URL] = []
    private(set) var readingLocation = ReadingLocation.beginning

    init(environment: AppEnvironment) {
        fileAccess = environment.fileAccess
        history = environment.history
    }

    var title: String? { snapshot?.url.lastPathComponent }
    var canNavigateBack: Bool { !navigationBackStack.isEmpty }
    var canNavigateForward: Bool { !navigationForwardStack.isEmpty }

    func open(_ url: URL, recordsNavigation: Bool = true) {
        loadTask?.cancel()
        generation += 1
        let requestedGeneration = generation
        let previousURL = snapshot?.url
        errorMessage = nil
        isLoading = true
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
                try Task.checkCancellation()
                guard let self, requestedGeneration == self.generation else { return }
                if recordsNavigation, let previousURL, previousURL != loaded.url {
                    self.navigationBackStack.append(previousURL)
                    self.navigationForwardStack.removeAll()
                }
                self.snapshot = loaded
                self.analysis = MarkdownAnalysis.analyze(loaded.markdown)
                _ = try self.history.recordOpen(loaded)
                self.readingLocation = try self.history.readingLocation(for: loaded.url)
                self.isLoading = false
                self.showsLoadingIndicator = false
                self.loadingIndicatorTask?.cancel()
                self.monitor(loaded.url)
            } catch is CancellationError {
                return
            } catch {
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
        if let current = snapshot?.url { navigationForwardStack.append(current) }
        open(destination, recordsNavigation: false)
    }

    func navigateForward() {
        guard let destination = navigationForwardStack.popLast() else { return }
        if let current = snapshot?.url { navigationBackStack.append(current) }
        open(destination, recordsNavigation: false)
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
        readingLocation = location
        guard let url = snapshot?.url else { return }
        readingLocationSaveTask?.cancel()
        readingLocationSaveTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(350))
            guard !Task.isCancelled else { return }
            try? self?.history.saveReadingLocation(location, for: url)
        }
    }

    func showTransientMessage(_ message: String) {
        transientMessage = message
        Task { [weak self] in
            try? await Task.sleep(for: .seconds(3))
            guard self?.transientMessage == message else { return }
            self?.transientMessage = nil
        }
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
            try Task.checkCancellation()
            guard requestedGeneration == generation else { return }
            guard loaded != snapshot else { return }
            snapshot = loaded
            analysis = MarkdownAnalysis.analyze(loaded.markdown)
            _ = try history.recordOpen(loaded)
            showTransientMessage(String(localized: "Refreshed"))
        } catch is CancellationError {
            return
        } catch {
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
}
