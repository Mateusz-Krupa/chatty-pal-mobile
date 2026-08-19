//
//  chatty_palTests.swift
//  chatty-palTests
//
//  Created by Mateusz Krupa on 09/05/2023.
//

import XCTest
@testable import chatty_pal

final class chatty_palTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

final class StrapiErrorMessagesTests: XCTestCase {

    func testExtractsMessageFromStrapiArrayShape() {
        let body = #"{"data":null,"error":{"status":400,"name":"AuthError","message":[{"id":"invalid","messages":[{"message":"Invalid identifier or password"}]}]}}"#
        XCTAssertEqual(StrapiErrorMessages.first(in: body), "Invalid identifier or password")
    }

    func testExtractsPlainMessage() {
        let body = #"{"message":"Please enter valid credentials."}"#
        XCTAssertEqual(StrapiErrorMessages.first(in: body), "Please enter valid credentials.")
    }

    func testExtractsNestedErrorMessage() {
        let body = #"{"error":{"message":"User not found"}}"#
        XCTAssertEqual(StrapiErrorMessages.first(in: body), "User not found")
    }

    func testTopLevelArrayShape() {
        let body = #"[{"messages":[{"message":"Something went wrong"}]}]"#
        XCTAssertEqual(StrapiErrorMessages.first(in: body), "Something went wrong")
    }

    func testUnparseableBodyReturnsNil() {
        XCTAssertNil(StrapiErrorMessages.first(in: "not json"))
        XCTAssertNil(StrapiErrorMessages.first(in: "{}"))
        XCTAssertNil(StrapiErrorMessages.first(in: ""))
    }

    func testAuthErrorDescriptionUsesStrapiMessage() {
        let body = #"{"message":[{"messages":[{"message":"Invalid identifier or password"}]}]}"#
        let error = AuthError.badRequest(status: 400, body: body)
        XCTAssertEqual(error.errorDescription, "Invalid identifier or password")
    }

    func testAuthErrorDescriptionFallsBackToStatus() {
        let error = AuthError.badRequest(status: 401, body: "no message here")
        XCTAssertEqual(error.errorDescription, "Login failed (401)")
    }
}
