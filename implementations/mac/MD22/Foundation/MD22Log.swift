import Foundation
import OSLog

/// Privacy boundary for diagnostics. User content and filesystem paths must never be
/// interpolated into these logs. Error identifiers contain only stable type/domain/code data.
enum MD22Log {
    static let subsystem = "com.66ideas.MD22"
    static let lifecycle = Logger(subsystem: subsystem, category: "lifecycle")
    static let fileAccess = Logger(subsystem: subsystem, category: "file-access")
    static let renderer = Logger(subsystem: subsystem, category: "renderer")
    static let persistence = Logger(subsystem: subsystem, category: "persistence")
    static let export = Logger(subsystem: subsystem, category: "export")
    static let updates = Logger(subsystem: subsystem, category: "updates")
    static let diagnostics = Logger(subsystem: subsystem, category: "diagnostics")
    private static let journal = DiagnosticEventJournal()

    static func identifier(for error: Error) -> String {
        let nsError = error as NSError
        return "\(String(reflecting: type(of: error))):\(nsError.domain):\(nsError.code)"
    }

    static func record(category: String, code: String) {
        journal.record(category: category, code: code)
    }

    static func recentEvents() -> [DiagnosticEvent] {
        journal.snapshot()
    }
}

struct DiagnosticEvent: Sendable {
    let date: Date
    let category: String
    let code: String
}

private final class DiagnosticEventJournal: @unchecked Sendable {
    private let lock = NSLock()
    private var events: [DiagnosticEvent] = []
    private let limit = 500

    func record(category: String, code: String) {
        lock.withLock {
            events.append(DiagnosticEvent(date: .now, category: category, code: code))
            if events.count > limit {
                events.removeFirst(events.count - limit)
            }
        }
    }

    func snapshot() -> [DiagnosticEvent] {
        lock.withLock { events }
    }
}
