//
//  chatty_palUITests.swift
//  chatty-palUITests
//
//  Created by Mateusz Krupa on 09/05/2023.
//

import XCTest

/// Store-ready Phase B guarantees, verified against the real UI:
/// - the slide-over menu lists only implemented destinations (no placeholder pages),
/// - dead teacher/panel destinations are gone,
/// - About Us navigates to the real Info screen,
/// - the Settings server-environment section exists only in Debug builds.
final class chatty_palUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    private func openMenu() {
        let menuButton = app.buttons["menuButton"]
        XCTAssertTrue(menuButton.waitForExistence(timeout: 15), "chat header not loaded")
        menuButton.tap()
        XCTAssertTrue(app.staticTexts["Menu"].waitForExistence(timeout: 5), "menu overlay did not open")
    }

    func testMenuShowsOnlyImplementedDestinations() throws {
        openMenu()

        // Enabled navigation rows (NavigationLink => buttons labelled by row title).
        for title in ["Info", "Policy", "My chats", "Learning Materials",
                      "Exam Prep A1", "Word Review", "About Us"] {
            let row = app.buttons[title]
            XCTAssertTrue(row.exists, "menu is missing enabled row '\(title)'")
            XCTAssertTrue(row.isEnabled, "row '\(title)' is present but not enabled")
        }
        // Sign-out-state rows.
        XCTAssertTrue(app.buttons["Chat"].exists, "menu is missing the Chat action row")
        XCTAssertTrue(app.buttons["Login"].exists, "menu is missing the Login row")
        // Login-gated rows exist as locked (non-button) rows when signed out.
        XCTAssertTrue(app.staticTexts["Homework"].exists, "menu is missing locked row 'Homework'")
        XCTAssertTrue(app.staticTexts["Role Play"].exists, "menu is missing locked row 'Role Play'")
        XCTAssertFalse(app.buttons["Homework"].exists, "locked 'Homework' row must not be a button while signed out")
        XCTAssertFalse(app.buttons["Role Play"].exists, "locked 'Role Play' row must not be a button while signed out")

        // Dead destinations removed with the store-ready cleanup.
        for gone in ["Teacher Help", "Classroom", "My Stories List", "Lesson Planner"] {
            XCTAssertFalse(app.buttons[gone].exists, "dead row '\(gone)' still tappable")
            XCTAssertFalse(app.staticTexts[gone].exists, "dead row '\(gone)' still listed")
        }
    }

    func testAboutUsOpensRealInfoScreen() throws {
        openMenu()
        app.buttons["About Us"].tap()

        let infoHeading = app.staticTexts["Practice languages through natural AI conversations"]
        XCTAssertTrue(infoHeading.waitForExistence(timeout: 5), "About Us did not open the Info screen")
        XCTAssertFalse(app.staticTexts["Placeholder page"].exists, "placeholder content still reachable")
    }

    func testServerEnvironmentSectionVisibilityMatchesBuildConfiguration() throws {
        let settingsButton = app.buttons["settingsButton"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 10), "settings button not found")
        settingsButton.tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 5), "settings sheet did not open")

        // Form section headers carry an uppercased text transform ("SERVER"), so match case-insensitively.
        let serverSection = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", "server")).firstMatch
        #if DEBUG
        XCTAssertTrue(serverSection.exists,
                      "Debug builds must keep the server-environment switcher")
        #else
        XCTAssertFalse(serverSection.exists,
                       "Release builds must not expose the server-environment switcher")
        #endif
    }
}
