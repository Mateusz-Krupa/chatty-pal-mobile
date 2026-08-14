import XCTest
@testable import chatty_pal

final class TranscriptTrackerTests: XCTestCase {

    func testFirstUtteranceReturnsTrimmedText() {
        var tracker = TranscriptTracker()
        XCTAssertEqual(tracker.nextDelta(from: "  Hallo Welt  "), "Hallo Welt")
    }

    func testEmptyAndWhitespaceInputReturnsNil() {
        var tracker = TranscriptTracker()
        XCTAssertNil(tracker.nextDelta(from: ""))
        XCTAssertNil(tracker.nextDelta(from: "   "))
    }

    func testUnchangedTextReturnsNil() {
        var tracker = TranscriptTracker()
        _ = tracker.nextDelta(from: "Hallo")
        XCTAssertNil(tracker.nextDelta(from: "Hallo"))
    }

    func testUnchangedTextWithDifferentCaseReturnsNil() {
        var tracker = TranscriptTracker()
        _ = tracker.nextDelta(from: "hallo")
        XCTAssertNil(tracker.nextDelta(from: "  HALLO "))
    }

    func testCumulativeContinuationReturnsOnlyNewTail() {
        var tracker = TranscriptTracker()
        _ = tracker.nextDelta(from: "hallo")
        XCTAssertEqual(tracker.nextDelta(from: "hallo gut"), "gut")
    }

    func testDeltaPreservesOriginalCapitalization() {
        var tracker = TranscriptTracker()
        _ = tracker.nextDelta(from: "Hallo")
        XCTAssertEqual(tracker.nextDelta(from: "Hallo Gut Danke"), "Gut Danke")
    }

    func testCorrectionWithNewWordsReturnsOnlyNewWords() {
        var tracker = TranscriptTracker()
        _ = tracker.nextDelta(from: "halo")
        XCTAssertEqual(tracker.nextDelta(from: "hallo gut"), "gut")
    }

    func testCorrectionWithSameWordCountReturnsNil() {
        var tracker = TranscriptTracker()
        _ = tracker.nextDelta(from: "halo")
        XCTAssertNil(tracker.nextDelta(from: "hallo"))
    }

    func testMultiWordCorrectionReturnsOnlyNewTail() {
        var tracker = TranscriptTracker()
        _ = tracker.nextDelta(from: "hallo gut")
        XCTAssertEqual(tracker.nextDelta(from: "hallo gute danke"), "danke")
    }

    func testShortenedTranscriptReturnsNil() {
        var tracker = TranscriptTracker()
        _ = tracker.nextDelta(from: "hallo gut")
        XCTAssertNil(tracker.nextDelta(from: "hallo"))
    }

    func testNewUtteranceReturnsWholeText() {
        var tracker = TranscriptTracker()
        _ = tracker.nextDelta(from: "gut")
        XCTAssertEqual(tracker.nextDelta(from: "guten tag"), "guten tag")
    }

    func testNewUtteranceNotTreatedAsCorrection() {
        var tracker = TranscriptTracker()
        _ = tracker.nextDelta(from: "ja")
        XCTAssertEqual(tracker.nextDelta(from: "nein danke"), "nein danke")
    }

    func testResetStartsFresh() {
        var tracker = TranscriptTracker()
        _ = tracker.nextDelta(from: "hallo")
        tracker.reset()
        XCTAssertEqual(tracker.nextDelta(from: "hallo"), "hallo")
    }

    func testSimulatedHandsFreeSession() {
        var tracker = TranscriptTracker()
        XCTAssertEqual(tracker.nextDelta(from: "hallo"), "hallo")
        XCTAssertEqual(tracker.nextDelta(from: "hallo gut"), "gut")
        XCTAssertEqual(tracker.nextDelta(from: "hallo gut wie"), "wie")
        XCTAssertEqual(tracker.nextDelta(from: "hallo gut wie geht"), "geht")
        XCTAssertEqual(tracker.nextDelta(from: "danke"), "danke")
        XCTAssertNil(tracker.nextDelta(from: "danke"))
    }

    func testIsSimilar() {
        XCTAssertTrue(TranscriptTracker.isSimilar("halo", to: "hallo"))
        XCTAssertTrue(TranscriptTracker.isSimilar("müde", to: "müder"))
        XCTAssertTrue(TranscriptTracker.isSimilar("gut", to: "gut"))
        XCTAssertFalse(TranscriptTracker.isSimilar("gut", to: "guten"))
        XCTAssertFalse(TranscriptTracker.isSimilar("hallo", to: "tschüss"))
        XCTAssertTrue(TranscriptTracker.isSimilar("", to: ""))
    }

    func testNormalizeLowercasesAndCollapsesWhitespace() {
        XCTAssertEqual(TranscriptTracker.normalize("  Hallo   WELT \n tab"), "hallo welt tab")
    }
}
