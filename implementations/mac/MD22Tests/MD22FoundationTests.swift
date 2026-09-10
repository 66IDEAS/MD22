import Foundation
import Testing
@testable import MD22

@Suite("MD22 foundation")
struct MD22FoundationTests {
    @Test("The app test target loads")
    func testTargetLoads() {
        #expect(Bundle.main.bundleIdentifier == "com.66ideas.MD22")
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
        #expect(markdown["LSHandlerRank"] as? String == "Alternate")
        #expect(markdown["LSItemContentTypes"] as? [String] == ["net.daringfireball.markdown"])
        let imports = try #require(info?["UTImportedTypeDeclarations"] as? [[String: Any]])
        let declaration = try #require(imports.first {
            $0["UTTypeIdentifier"] as? String == "net.daringfireball.markdown"
        })
        #expect(declaration["UTTypeConformsTo"] as? [String] == ["public.utf8-plain-text"])
        let tags = try #require(declaration["UTTypeTagSpecification"] as? [String: Any])
        let extensions = try #require(tags["public.filename-extension"] as? [String])
        #expect(Set(extensions) == DocumentRouter.allowedExtensions)
        #expect(tags["public.mime-type"] as? String == "text/markdown")
        let fallback = try #require(documentTypes.first { $0["LSItemContentTypes"] == nil })
        #expect(fallback["CFBundleTypeRole"] as? String == "Viewer")
        #expect(fallback["LSHandlerRank"] as? String == "Alternate")
        #expect(fallback["CFBundleTypeExtensions"] as? [String] == ["mdown", "mkd", "mkdn"])
        #expect(Bundle.main.url(forResource: "LICENSE", withExtension: "txt") != nil)
        #expect(Bundle.main.url(forResource: "THIRD_PARTY_LICENSES", withExtension: "txt") != nil)
    }
}
