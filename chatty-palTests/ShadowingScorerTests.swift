import XCTest
@testable import chatty_pal

final class ShadowingScorerTests: XCTestCase {
    func testExactMatchScoresHundred() {
        let result = ShadowingScorer.score(reference: "Ich möchte ein Wasser", spoken: "ich möchte ein Wasser")
        XCTAssertEqual(result.percent, 100)
        XCTAssertTrue(result.words.allSatisfy(\.matched))
    }

    func testMissingWordIsUnmatchedAndLowersPercent() {
        let result = ShadowingScorer.score(reference: "Ich möchte ein Wasser", spoken: "ich ein Wasser")
        XCTAssertEqual(result.percent, 75)
        XCTAssertEqual(result.words.first?.matched, true)
        XCTAssertEqual(result.words[1].matched, false)
        XCTAssertEqual(result.words[2].matched, true)
        XCTAssertEqual(result.words[3].matched, true)
    }

    func testExtraFillerWordsStillMatchAll() {
        let result = ShadowingScorer.score(reference: "Danke schön", spoken: "ja danke, äh, schön")
        XCTAssertEqual(result.percent, 100)
        XCTAssertTrue(result.words.allSatisfy(\.matched))
    }

    func testSimilarWordWithinThresholdMatches() {
        // "wassser" is a plausible recognizer slip for "wasser"
        let result = ShadowingScorer.score(reference: "ein Wasser", spoken: "ein wassser")
        XCTAssertEqual(result.percent, 100)
    }

    func testVeryDifferentWordDoesNotMatch() {
        let result = ShadowingScorer.score(reference: "Ich möchte Brot", spoken: "Ich möchte Auto")
        XCTAssertEqual(result.words.last?.matched, false)
        XCTAssertEqual(result.percent, 67)
    }

    func testEmptySpokenScoresZero() {
        let result = ShadowingScorer.score(reference: "Hallo", spoken: "")
        XCTAssertEqual(result.percent, 0)
        XCTAssertFalse(result.words.first?.matched ?? true)
    }

    func testEmptyReferenceScoresZeroWithNoWords() {
        let result = ShadowingScorer.score(reference: "", spoken: "hallo")
        XCTAssertEqual(result.percent, 0)
        XCTAssertTrue(result.words.isEmpty)
    }

    func testCleanWordsLowercasesAndStripsPunctuation() {
        XCTAssertEqual(ShadowingScorer.cleanWords("  Hallo,  wie   geht's? "), ["hallo", "wie", "geht's"])
    }

    func testLetterCaseDoesNotAffectScoreOrWordMatches() {
        let reference = "Ich möchte ein Wasser"
        for spoken in ["ich möchte ein wasser", "ICH MÖCHTE EIN WASSER", "iCh MöChTe EiN wAsSeR"] {
            for (expected, recognized) in [(reference, spoken), (spoken, reference)] {
                XCTAssertEqual(ShadowingScorer.cleanWords(expected), ShadowingScorer.cleanWords(recognized))
                let result = ShadowingScorer.score(reference: expected, spoken: recognized)
                XCTAssertEqual(result.percent, 100)
                XCTAssertTrue(result.words.allSatisfy(\.matched))
            }
        }
    }

    func testGermanSharpSCaseExpansionsMatchInBothDirections() {
        for (reference, spoken) in [("Wie heißt die Straße", "WIE HEISST DIE STRASSE"),
                                    ("WIE HEISST DIE STRASSE", "Wie heißt die Straße"),
                                    ("ß", "SS"), ("ẞ", "ß")] {
            XCTAssertEqual(ShadowingScorer.cleanWords(reference), ShadowingScorer.cleanWords(spoken))
            let result = ShadowingScorer.score(reference: reference, spoken: spoken)
            XCTAssertEqual(result.percent, 100)
            XCTAssertTrue(result.words.allSatisfy(\.matched))
        }
    }

    func testCaseFoldingPreservesUmlautsAndMeaningfulDifferences() {
        XCTAssertEqual(ShadowingScorer.cleanWords("Ä Ö Ü"), ["ä", "ö", "ü"])
        XCTAssertNotEqual(ShadowingScorer.cleanWords("schön"), ShadowingScorer.cleanWords("schon"))
        let result = ShadowingScorer.score(reference: "BROT", spoken: "auto")
        XCTAssertEqual(result.percent, 0)
        XCTAssertFalse(result.words[0].matched)
    }
}
