import XCTest

final class MD22LaunchTests: XCTestCase {
    @MainActor
    func testWelcomeScreenLaunches() throws {
        let application = XCUIApplication()
        application.launch()
        XCTAssertTrue(application.staticTexts["MD22"].waitForExistence(timeout: 5))
    }
}
