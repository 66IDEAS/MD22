import Foundation
import Testing
@testable import MD22

@Suite("Secure update configuration")
struct UpdateConfigurationTests {
    @Test("release feed and update verification are configured")
    func secureUpdateMetadata() throws {
        let info = Bundle.main.infoDictionary
        let feed = try #require(info?["SUFeedURL"] as? String)
        let publicKey = try #require(info?["SUPublicEDKey"] as? String)

        #expect(feed.hasPrefix("https://"))
        #expect(URL(string: feed)?.host == "github.com")
        #expect(Data(base64Encoded: publicKey)?.count == 32)
        #expect(info?["SUVerifyUpdateBeforeExtraction"] as? Bool == true)
        #expect(info?["SURequireSignedFeed"] as? Bool == true)
        #expect(info?["SUEnableAutomaticChecks"] as? Bool == true)
    }
}
