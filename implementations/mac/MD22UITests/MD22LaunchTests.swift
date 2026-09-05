import XCTest

@MainActor
final class MD22LaunchTests: XCTestCase {
    func testWelcomeScreenLaunches() throws {
        continueAfterFailure = false
        let application = makeApplication()
        application.launch()
        ensureReaderWindow(in: application)
        XCTAssertTrue(application.staticTexts["A focused Markdown reader"].waitForExistence(timeout: 5))
        XCTAssertTrue(application.descendants(matching: .any)["history.sidebar"].exists)
        XCTAssertTrue(application.descendants(matching: .any)["document.inspector"].exists)
        XCTAssertTrue(application.descendants(matching: .any)["reading.status"].exists)
        XCTAssertTrue(application.buttons["Open Markdown…"].isEnabled)

        let fileMenu = application.menuBars.menuBarItems["File"]
        fileMenu.click()
        XCTAssertTrue(fileMenu.menus.menuItems["New Window"].exists)
        XCTAssertFalse(fileMenu.menus.menuItems["New Markdown Document Window"].exists)
        fileMenu.menus.menuItems["New Window"].click()
        XCTAssertTrue(application.windows.element(boundBy: 1).waitForExistence(timeout: 3))
    }

    func testDocumentSearchAndLayoutShortcuts() throws {
        continueAfterFailure = false
        let directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let fixture = directory.appending(path: "UI Fixture.md")
        try "# UI Fixture\n\nNeedle in a searchable document.\n\n## Nested\n\n### Deep".write(to: fixture, atomically: true, encoding: .utf8)
        let application = makeApplication(arguments: [
            "--md22-ui-test-document", fixture.path,
        ])
        application.launch()
        ensureReaderWindow(in: application)

        let documentWindow = application.windows.matching(
            NSPredicate(format: "title BEGINSWITH 'UI Fixture.md'")
        ).firstMatch
        XCTAssertTrue(documentWindow.waitForExistence(timeout: 8))
        XCTAssertTrue(application.webViews.firstMatch.exists)
        XCTAssertTrue(application.buttons["Go to Deep, heading level 3"].waitForExistence(timeout: 3))

        application.typeKey("f", modifierFlags: .command)
        let searchField = application.textFields["Find in document"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 3))
        application.typeText("Needle")
        XCTAssertTrue(application.staticTexts["Match 1 of 1"].waitForExistence(timeout: 3))

        application.typeKey("1", modifierFlags: [.command, .option])
        let historySidebar = application.descendants(matching: .any)["history.sidebar"]
        XCTAssertFalse(historySidebar.waitForExistence(timeout: 1))
        application.typeKey("1", modifierFlags: [.command, .option])
        XCTAssertTrue(historySidebar.waitForExistence(timeout: 3))

        let inspector = application.descendants(matching: .any)["document.inspector"]
        let statusBar = application.descendants(matching: .any)["reading.status"]
        let distractionToggle = application.buttons["distraction.toggle"]
        XCTAssertTrue(distractionToggle.waitForExistence(timeout: 3))
        distractionToggle.click()
        XCTAssertFalse(historySidebar.waitForExistence(timeout: 1))
        XCTAssertFalse(inspector.waitForExistence(timeout: 1))
        XCTAssertFalse(statusBar.waitForExistence(timeout: 1))
        application.buttons["distraction.toggle"].click()
        XCTAssertTrue(historySidebar.waitForExistence(timeout: 3))
        XCTAssertTrue(inspector.waitForExistence(timeout: 3))
        XCTAssertTrue(statusBar.waitForExistence(timeout: 3))
    }

    func testSettingsAndAboutAreReachableFromStandardCommands() throws {
        continueAfterFailure = false
        let application = makeApplication()
        application.launch()
        ensureReaderWindow(in: application)

        let applicationMenu = application.menuBars.menuBarItems["MD22"]
        applicationMenu.click()
        applicationMenu.menus.menuItems["Settings…"].click()
        XCTAssertTrue(application.staticTexts["Appearance"].waitForExistence(timeout: 3))
        XCTAssertTrue(application.descendants(matching: .any)["settings.automaticUpdates"].exists)
        application.typeKey("w", modifierFlags: .command)

        applicationMenu.click()
        applicationMenu.menus.menuItems["About MD22"].click()
        XCTAssertTrue(application.descendants(matching: .any)["about.github"].waitForExistence(timeout: 3))
        XCTAssertTrue(application.descendants(matching: .any)["about.version"].exists)
    }

    func testLaunchPerformance() throws {
        let application = makeApplication()
        let options = XCTMeasureOptions()
        options.iterationCount = 3
        measure(metrics: [XCTApplicationLaunchMetric()], options: options) {
            application.launch()
            application.terminate()
        }
    }

    private func makeApplication(arguments: [String] = ["--md22-ui-test-fresh"]) -> XCUIApplication {
        let application = XCUIApplication()
        application.launchArguments = arguments + [
            "-showsHistory", "YES",
            "-showsInspector", "YES"
        ]
        return application
    }

    private func ensureReaderWindow(in application: XCUIApplication) {
        guard application.windows.firstMatch.waitForExistence(timeout: 1) == false else { return }
        application.typeKey("n", modifierFlags: .command)
        XCTAssertTrue(application.windows.firstMatch.waitForExistence(timeout: 3))
    }
}
