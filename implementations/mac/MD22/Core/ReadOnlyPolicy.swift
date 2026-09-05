import Foundation

enum ReadOnlyPolicy {
    static let supportsSourceEditing = false
    static let supportsSourceSaving = false
    static let requiresAccount = false
    static let indexesContainingFolders = false

    static func sourceFingerprint(at url: URL) throws -> Data {
        try Data(contentsOf: url, options: [.mappedIfSafe])
    }
}

