import XCTest

@MainActor
final class MD22LaunchTests: XCTestCase {
    func testDirectToolbarExportAndStartupSidebarWidth() throws {
        continueAfterFailure = false
        let directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let fixture = directory.appending(path: "Toolbar Export.md")
        try "# Toolbar Export\n\nA readable publication.".write(to: fixture, atomically: true, encoding: .utf8)
        let application = makeApplication(arguments: [
            "--md22-ui-test-document", fixture.path, "-exportFormat", "pdf"
        ])
        application.launch()
        ensureReaderWindow(in: application)
        let sidebar = application.descendants(matching: .any)["history.sidebar"]
        XCTAssertTrue(sidebar.waitForExistence(timeout: 5))
        XCTAssertGreaterThanOrEqual(sidebar.frame.width, 240)
        XCTAssertLessThanOrEqual(sidebar.frame.width, 360)

        let primary = application.buttons["export.primary"]
        XCTAssertTrue(primary.waitForExistence(timeout: 8))
        XCTAssertTrue(primary.isHittable)
        XCTAssertEqual(primary.label, "Export as PDF")
        primary.click()
        let output = directory.appending(path: "Toolbar Export.pdf")
        let exported = XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in
            FileManager.default.fileExists(atPath: output.path)
        }, object: nil)
        XCTAssertEqual(XCTWaiter.wait(for: [exported], timeout: 15), .completed)
        XCTAssertTrue(application.links["Reveal in Finder"].waitForExistence(timeout: 3))
        XCTAssertTrue(application.staticTexts["Exported Toolbar Export.pdf"].exists)
    }

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

        application.activate()
        documentWindow.click()
        application.typeKey("f", modifierFlags: .command)
        let searchField = application.textFields["Find in document"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 8))
        application.typeText("Needle")
        XCTAssertTrue(application.staticTexts["Match 1 of 1"].waitForExistence(timeout: 3))
        application.typeKey(.escape, modifierFlags: [])
        XCTAssertFalse(searchField.waitForExistence(timeout: 1))

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

    func testBookmarkAndExportShortcuts() throws {
        continueAfterFailure = false
        let directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let fixture = directory.appending(path: "Keyboard Shortcuts.md")
        let exportedPDF = directory.appending(path: "Keyboard Shortcuts.pdf")
        let exportedHTML = directory.appending(path: "Keyboard Shortcuts.html")
        try "# Keyboard Shortcuts\n\nA document for shortcut verification.".write(
            to: fixture,
            atomically: true,
            encoding: .utf8
        )

        let application = makeApplication(arguments: [
            "--md22-ui-test-document", fixture.path,
        ])
        application.launch()
        ensureReaderWindow(in: application)
        XCTAssertTrue(application.webViews.firstMatch.waitForExistence(timeout: 8))

        let fileMenu = application.menuBars.menuBarItems["File"]
        fileMenu.click()
        let bookmarkCommand = fileMenu.menus.menuItems["Add Bookmark"]
        XCTAssertTrue(bookmarkCommand.exists)
        XCTAssertTrue(bookmarkCommand.isEnabled)
        application.typeKey(.escape, modifierFlags: [])

        application.typeKey("d", modifierFlags: .command)
        XCTAssertTrue(application.staticTexts["Bookmark added"].waitForExistence(timeout: 3))

        application.typeKey("e", modifierFlags: .command)
        let exportCompleted = XCTNSPredicateExpectation(
            predicate: NSPredicate { _, _ in
                FileManager.default.fileExists(atPath: exportedPDF.path)
                    || FileManager.default.fileExists(atPath: exportedHTML.path)
            },
            object: nil
        )
        XCTAssertEqual(XCTWaiter.wait(for: [exportCompleted], timeout: 15), .completed)
        XCTAssertTrue(
            FileManager.default.fileExists(atPath: exportedPDF.path)
                || FileManager.default.fileExists(atPath: exportedHTML.path)
        )
    }

    func testLayoutIndependentHistoryNavigationShortcuts() throws {
        continueAfterFailure = false
        let directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let first = directory.appending(path: "First.md")
        let second = directory.appending(path: "Second.md")
        try "# First\n\n[Open second](Second.md)".write(to: first, atomically: true, encoding: .utf8)
        try "# Second\n\nDestination".write(to: second, atomically: true, encoding: .utf8)

        let application = makeApplication(arguments: [
            "--md22-ui-test-document", first.path,
        ])
        application.launch()
        ensureReaderWindow(in: application)

        let firstWindow = application.windows.matching(
            NSPredicate(format: "title BEGINSWITH 'First.md'")
        ).firstMatch
        XCTAssertTrue(firstWindow.waitForExistence(timeout: 8))
        let link = application.links["Open second"]
        XCTAssertTrue(link.waitForExistence(timeout: 5))
        link.click()

        let secondWindow = application.windows.matching(
            NSPredicate(format: "title BEGINSWITH 'Second.md'")
        ).firstMatch
        XCTAssertTrue(secondWindow.waitForExistence(timeout: 8))

        application.typeKey(.leftArrow, modifierFlags: .command)
        XCTAssertTrue(firstWindow.waitForExistence(timeout: 8))

        application.typeKey(.rightArrow, modifierFlags: .command)
        XCTAssertTrue(secondWindow.waitForExistence(timeout: 8))
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
