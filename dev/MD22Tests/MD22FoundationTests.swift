import Testing
@testable import MD22

@Suite("MD22 foundation")
struct MD22FoundationTests {
    @Test("The app test target loads")
    func testTargetLoads() {
        #expect(true)
    }

    @Test("The current platform meets the macOS 26 baseline")
    func platformBaseline() {
        #expect(PlatformRequirements.minimumMacOS.majorVersion == 26)
        #expect(PlatformRequirements.isSupported)
    }
}
