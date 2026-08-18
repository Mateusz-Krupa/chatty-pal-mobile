import XCTest
@testable import chatty_pal

final class BotStreamTests: XCTestCase {
    func testParsesContentDelta() {
        let line = #"data: {"id":"1","choices":[{"index":0,"delta":{"role":"assistant","content":"Hallo "}}]}"#
        XCTAssertEqual(BotStreamParser.delta(fromLine: line), "Hallo ")
    }

    func testRoleOnlyChunkYieldsNil() {
        let line = #"data: {"id":"1","choices":[{"index":0,"delta":{"role":"assistant"}}]}"#
        XCTAssertNil(BotStreamParser.delta(fromLine: line))
    }

    func testEmptyContentYieldsNil() {
        let line = #"data: {"id":"1","choices":[{"index":0,"delta":{"content":""}}]}"#
        XCTAssertEqual(BotStreamParser.delta(fromLine: line), "")
    }

    func testCommentAndBlankLinesYieldNil() {
        XCTAssertNil(BotStreamParser.delta(fromLine: ": keep-alive"))
        XCTAssertNil(BotStreamParser.delta(fromLine: ""))
        XCTAssertNil(BotStreamParser.delta(fromLine: "event: message"))
    }

    func testMalformedJSONYieldsNil() {
        XCTAssertNil(BotStreamParser.delta(fromLine: "data: {broken"))
    }

    func testDoneDetection() {
        XCTAssertTrue(BotStreamParser.isDone("data: [DONE]"))
        XCTAssertFalse(BotStreamParser.isDone("data: [done]"))
        XCTAssertFalse(BotStreamParser.isDone("data: {\"choices\":[]}"))
    }

    // MARK: - UtteranceSplitter

    func testEmitsSentenceWhenPunctuationFollowedBySpace() {
        var splitter = UtteranceSplitter()
        XCTAssertEqual(splitter.feed("Ich heiße Anna. "), ["Ich heiße Anna."])
        XCTAssertNil(splitter.finish())
    }

    func testSplitsAcrossDeltas() {
        var splitter = UtteranceSplitter()
        XCTAssertEqual(splitter.feed("Erste Sätze "), [])
        // "kommen." ends without trailing whitespace — not final yet
        XCTAssertEqual(splitter.feed("kommen."), [])
        let out = splitter.feed(" Zweite folgt! ")
        XCTAssertEqual(out, ["Erste Sätze kommen.", "Zweite folgt!"])
        XCTAssertEqual(splitter.feed("Dritte bleibt"), [])
        XCTAssertEqual(splitter.finish(), "Dritte bleibt")
    }

    func testHandlesClosingQuotes() {
        var splitter = UtteranceSplitter()
        let out = splitter.feed("\"Na klar.\" Sagte er. ")
        XCTAssertEqual(out, ["\"Na klar.\"", "Sagte er."])
    }

    func testNoPunctuationEmittedOnlyOnFinish() {
        var splitter = UtteranceSplitter()
        XCTAssertEqual(splitter.feed("Kein Punkt hier "), [])
        XCTAssertEqual(splitter.finish(), "Kein Punkt hier")
    }

    func testForceSplitsLongBufferWithoutBoundary() {
        var splitter = UtteranceSplitter()
        let long = String(repeating: "abc ", count: 60) // 240 chars, no punctuation
        let out = splitter.feed(long)
        XCTAssertEqual(out.count, 1)
        XCTAssertEqual(out.first?.count, 199) // cut at the whitespace at index 199
        XCTAssertEqual(splitter.finish()?.count, 39) // the remaining 40 chars minus trailing space
    }

    func testWhitespaceOnlyNeverEmitted() {
        var splitter = UtteranceSplitter()
        XCTAssertEqual(splitter.feed("   \n  "), [])
        XCTAssertNil(splitter.finish())
    }
}
