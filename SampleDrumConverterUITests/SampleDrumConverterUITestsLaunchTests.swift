//
//  SampleDrumConverterUITestsLaunchTests.swift
//  It's mono, yo!UITests
//
//  Created by IAMJARL on 27/12/2024.
//

import XCTest

final class ItsMonoYoUITestsLaunchTests: XCTestCase {

    // Running once per appearance switches the whole Mac between light and dark
    // and waits for every running app to follow. One app that never answers
    // (a background daemon was enough) fails the run before this app launches.
    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        false
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-ApplePersistenceIgnoreState", "YES"]
        app.launch()

        XCTAssertTrue(app.windows["It's mono, yo!"].waitForExistence(timeout: 10), "The main window did not open")

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
