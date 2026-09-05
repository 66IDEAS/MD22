import Foundation
import Testing
@testable import MD22

@Suite("MD22 foundation")
struct MD22FoundationTests {
    @Test("The app test target loads")
    func testTargetLoads() {
        #expect(Bundle.main.bundleIdentifier == "com.alexander-ilg.MD22")
    }

    @Test("The current platform meets the macOS 26 baseline")
    func platformBaseline() {
        #expect(PlatformRequirements.minimumMacOS.majorVersion == 26)
        #expect(PlatformRequirements.isSupported)
    }

    @Test("The bundle declares viewer-only Markdown support and legal resources")
    func bundleConformance() throws {
        let info = Bundle.main.infoDictionary
        let documentTypes = try #require(info?["CFBundleDocumentTypes"] as? [[String: Any]])
        let markdown = try #require(documentTypes.first)
        #expect(markdown["CFBundleTypeRole"] as? String == "Viewer")
        #expect((markdown["CFBundleTypeExtensions"] as? [String])?.contains("md") == true)
        #expect(Bundle.main.url(forResource: "LICENSE", withExtension: "txt") != nil)
        #expect(Bundle.main.url(forResource: "THIRD_PARTY_LICENSES", withExtension: "txt") != nil)
    }
}
