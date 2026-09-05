import Foundation

enum PlatformRequirements {
    static let minimumMacOS = OperatingSystemVersion(majorVersion: 26, minorVersion: 0, patchVersion: 0)

    static var isSupported: Bool {
        ProcessInfo.processInfo.isOperatingSystemAtLeast(minimumMacOS)
    }
}
