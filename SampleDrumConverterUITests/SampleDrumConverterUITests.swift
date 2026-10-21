//
//  SampleDrumConverterUITests.swift
//  It's mono, yo!UITests
//
//  Created by IAMJARL on 27/12/2024.
//
//  These tests stay on the first screen and in the menus. They never open the
//  file picker (NSOpenPanel), which XCUITest cannot drive reliably.
//

import XCTest

final class ItsMonoYoUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false

        app = XCUIApplication()
        // Dev builds share the App Store app's container, saved window state
        // included. Without this a run can start with no window at all.
        app.launchArguments += ["-ApplePersistenceIgnoreState", "YES"]
        app.launch()

        XCTAssertTrue(mainWindow.waitForExistence(timeout: 10), "The main window did not open")
    }

    override func tearDownWithError() throws {
        if app.state != .notRunning {
            app.terminate()
        }
    }

    private var mainWindow: XCUIElement {
        app.windows["It's mono, yo!"]
    }

    func testFirstScreenShowsTheDropZone() throws {
        let prompt = mainWindow.staticTexts.containing(
            NSPredicate(format: "value BEGINSWITH 'Click to select WAV/AIFF files or folders'")
        ).firstMatch
        XCTAssertTrue(prompt.exists)
    }

    func testNextIsDisabledWithoutFiles() throws {
        let nextButton = mainWindow.buttons["Next"]
        XCTAssertTrue(nextButton.exists)
        XCTAssertFalse(nextButton.isEnabled)
    }

    func testFileMenuHasOpenFiles() throws {
        app.menuBars.menuBarItems["File"].click()
        let openFiles = app.menuBars.menuItems["Open Files..."]
        XCTAssertTrue(openFiles.waitForExistence(timeout: 2))
        XCTAssertTrue(openFiles.isEnabled)
        // Close the menu without choosing anything, so no file picker opens.
        app.typeKey(.escape, modifierFlags: [])
    }

    func testClosingTheWindowQuitsTheApp() throws {
        // Since #101 the app quits when its only window closes.
        mainWindow.buttons[XCUIIdentifierCloseWindow].click()
        XCTAssertTrue(app.wait(for: .notRunning, timeout: 10), "The app kept running after its window closed")
    }
}
