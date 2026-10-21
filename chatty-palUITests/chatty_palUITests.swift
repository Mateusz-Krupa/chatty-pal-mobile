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

/// Opt-in real iOS → isolated local Strapi journey. Start the CMS fixture with --serve.
/// Run with TEST_RUNNER_LEARNING_PROGRESS_E2E=1 and select this class only.
final class LearningProgressLocalUITests: XCTestCase {
    @MainActor
    func testSavedPhraseManualCompletionReopenAndResetConfirmation() async throws {
        guard ProcessInfo.processInfo.environment["LEARNING_PROGRESS_E2E"] == "1" else {
            throw XCTSkip("Requires the isolated local CMS UI-test fixture on port 13491")
        }
        continueAfterFailure = false
        let port = ProcessInfo.processInfo.environment["LEARNING_PROGRESS_TEST_PORT"] ?? "13491"
        let base = "http://127.0.0.1:\(port)/api"
        func api(_ path: String, method: String = "GET", body: [String: Any]? = nil, jwt: String? = nil) async throws -> [String: Any] {
            var request = URLRequest(url: URL(string: base + path)!)
            request.httpMethod = method
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            if let jwt { request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization") }
            if let body { request.httpBody = try JSONSerialization.data(withJSONObject: body) }
            let (data, response) = try await URLSession.shared.data(for: request)
            XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 200)
            return try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        }
        let auth = try await api("/auth/local", method: "POST", body: [
            "identifier": "learning-test@example.invalid", "password": "public-test-only-password"
        ])
        let jwt = try XCTUnwrap(auth["jwt"] as? String)
        let revision = "de-2026-10-v1", lesson = "de-s-01", phrase = "p-237b227c309d20a3"
        let list = try await api("/learning-progress?catalogRevision=\(revision)", jwt: jwt)
        let existing = (list["progress"] as? [[String: Any]])?.first { $0["lessonId"] as? String == lesson }
        let reset = try await api("/learning-progress/\(lesson)/reset", method: "POST", body: [
            "catalogRevision": revision, "generation": existing?["generation"] as? Int ?? 0
        ], jwt: jwt)
        let generation = try XCTUnwrap(reset["generation"] as? Int)
        _ = try await api("/learning-progress/\(lesson)/attempts", method: "POST", body: [
            "catalogRevision": revision, "generation": generation, "phraseId": phrase,
            "clientAttemptId": UUID().uuidString, "transcript": "Persisted UI test speech", "score": 95,
            "scoringVersion": "word-match-v1"
        ], jwt: jwt)

        let app = XCUIApplication()
        app.launchEnvironment["CMS_API_BASE_URL"] = base
        app.launchEnvironment["BOT_BASE_URL"] = "http://127.0.0.1:\(port)"
        app.launch()
        defer { app.terminate() }
        func menu() {
            XCTAssertTrue(app.buttons["menuButton"].waitForExistence(timeout: 15))
            app.buttons["menuButton"].tap()
        }
        menu()
        if app.buttons["Logout"].exists {
            app.buttons["Logout"].tap()
            menu()
        }
        func signIn() throws {
            app.buttons["Login"].tap()
            let identifier = app.textFields["Username or email"]
            XCTAssertTrue(identifier.waitForExistence(timeout: 5))
            identifier.tap(); identifier.typeText("learning-test@example.invalid")
            let password = app.secureTextFields["Password"]
            password.tap(); password.typeText("public-test-only-password")
            try XCTUnwrap(app.buttons.matching(identifier: "Login").allElementsBoundByIndex.last).tap()
            XCTAssertTrue(identifier.waitForNonExistence(timeout: 15))
        }
        try signIn()

        func openLesson() throws {
            menu()
            // Unsigned simulator builds need not retain Keychain entries across launch.
            if app.buttons["Login"].exists { try signIn(); menu() }
            app.buttons["Learning Materials"].tap()
            let german = app.buttons["View German Lessons"]
            for _ in 0..<5 where !german.isHittable { app.swipeUp() }
            german.tap()
            let card = app.buttons["learning.lesson.\(lesson)"]
            XCTAssertTrue(card.waitForExistence(timeout: 5))
            card.tap()
        }
        try openLesson()
        let mark = app.buttons["learning.complete"]
        XCTAssertTrue(mark.waitForExistence(timeout: 10))
        for _ in 0..<3 where !mark.isHittable { app.swipeUp() }
        XCTAssertTrue(app.staticTexts["1/7 shadowing phrases passed"].exists)
        mark.tap()
        let resetButton = app.buttons["learning.reset"]
        XCTAssertTrue(resetButton.waitForExistence(timeout: 10))
        app.terminate(); app.launch()
        try openLesson()
        XCTAssertTrue(resetButton.waitForExistence(timeout: 10), "Completion must survive app restart: \(app.debugDescription)")
        for _ in 0..<3 where !resetButton.isHittable { app.swipeUp() }
        resetButton.tap()
        app.buttons["Cancel"].tap()
        XCTAssertTrue(resetButton.exists, "Cancel must preserve completion")
        resetButton.tap()
        let confirm = app.buttons["learning.confirmReset"]
        XCTAssertTrue(confirm.waitForExistence(timeout: 5), app.debugDescription)
        confirm.tap()
        XCTAssertTrue(mark.waitForExistence(timeout: 10), "Reset must clear completion: \(app.debugDescription)")
        let finalList = try await api("/learning-progress?catalogRevision=\(revision)", jwt: jwt)
        let final = try XCTUnwrap((finalList["progress"] as? [[String: Any]])?.first { $0["lessonId"] as? String == lesson })
        XCTAssertTrue(final["completedAt"] is NSNull)
        XCTAssertEqual((final["phrases"] as? [Any])?.count, 0)
        let history = try await api("/learning-progress/\(lesson)/attempts?catalogRevision=\(revision)", jwt: jwt)
        XCTAssertFalse((history["attempts"] as? [Any] ?? []).isEmpty, "Reset must retain attempt history")
    }
}
