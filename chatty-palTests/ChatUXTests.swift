import XCTest
@testable import chatty_pal

final class ChatUXTests: XCTestCase {
    // MARK: - TextDiffer

    func testDiffDetectsChangedWord() {
        let segments = TextDiffer.diff(original: "I goed to the shop", corrected: "I went to the shop")
        XCTAssertEqual(segments.map { $0.text }, ["I", "goed", "went", "to the shop"])
        XCTAssertEqual(segments.map { $0.kind }, [.same, .removed, .added, .same])
    }

    func testDiffIgnoresCaseAndPunctuation() {
        let segments = TextDiffer.diff(original: "Hello, world", corrected: "hello world!")
        XCTAssertEqual(segments.count, 1)
        XCTAssertEqual(segments[0].kind, .same)
    }

    func testDiffEntireRewrite() {
        let segments = TextDiffer.diff(original: "cat", corrected: "dog")
        XCTAssertEqual(segments.map { $0.text }, ["cat", "dog"])
        XCTAssertEqual(segments.map { $0.kind }, [.removed, .added])
    }

    func testDiffIdenticalText() {
        let segments = TextDiffer.diff(original: "same words", corrected: "same words")
        XCTAssertEqual(segments.count, 1)
        XCTAssertEqual(segments[0].text, "same words")
        XCTAssertEqual(segments[0].kind, .same)
    }

    func testDiffAppendedWord() {
        let segments = TextDiffer.diff(original: "I like", corrected: "I like coffee")
        XCTAssertEqual(segments.map { $0.text }, ["I like", "coffee"])
        XCTAssertEqual(segments.map { $0.kind }, [.same, .added])
    }

    // MARK: - Suggestion parsing

    @MainActor
    func testParseSuggestionArrayPlain() {
        XCTAssertEqual(ChatEngine.parseSuggestionArray("[\"Hi!\",\"How are you?\",\"Bye\"]"), ["Hi!", "How are you?", "Bye"])
    }

    @MainActor
    func testParseSuggestionArrayWithFenceAndProse() {
        let raw = "```json\n[\"Hello\", \"Nice\", \"Cool\"]\n```\nHope this helps!"
        XCTAssertEqual(ChatEngine.parseSuggestionArray(raw), ["Hello", "Nice", "Cool"])
    }

    @MainActor
    func testParseSuggestionArrayCapsAtThree() {
        XCTAssertEqual(ChatEngine.parseSuggestionArray("[\"a\",\"b\",\"c\",\"d\"]"), ["a", "b", "c"])
    }

    @MainActor
    func testParseSuggestionArrayInvalidReturnsEmpty() {
        XCTAssertTrue(ChatEngine.parseSuggestionArray("no suggestions here").isEmpty)
        XCTAssertTrue(ChatEngine.parseSuggestionArray("[oops").isEmpty)
        XCTAssertTrue(ChatEngine.parseSuggestionArray("").isEmpty)
    }

    // MARK: - Persona prompt

    func testMainPersonaPromptRules() {
        let prompt = ChatPersona.main(language: LanguageConfig.default, level: "B1").systemInstruction
        XCTAssertTrue(prompt.contains("at most 2 short sentences"))
        XCTAssertTrue(prompt.contains("If you do not know the answer"))
        XCTAssertFalse(prompt.lowercased().contains("invent"))
    }

    func testFullInstructionInjectsMemory() {
        var persona = ChatPersona.main(language: LanguageConfig.default, level: "B1")
        persona.memory = "Likes football."
        XCTAssertTrue(persona.fullInstruction.hasSuffix("ABOUT YOUR FRIEND:\nLikes football."))

        persona.memory = ""
        XCTAssertEqual(persona.fullInstruction, persona.systemInstruction)
    }

    // MARK: - Role play HTML stripping

    func testStrippingHTML() {
        XCTAssertEqual(
            RolePlayService.strippingHTML("<p>Hello&nbsp;<b>world</b> &amp; friends</p>"),
            "Hello world & friends"
        )
    }

    func testStrippingHTMLMultiBlock() {
        // Block tags become spaces, so `</i>.` yields "shopkeeper ." — harmless for the LLM prompt.
        XCTAssertEqual(
            RolePlayService.strippingHTML("<h1>Store</h1>\n<p>You are a <i>shopkeeper</i>.</p>\n<p>The customer buys bread.</p>"),
            "Store You are a shopkeeper . The customer buys bread."
        )
    }

    // MARK: - Menu destinations (store-ready: no placeholder pages)

    func testMenuDestinationsAllCarryRealContentMetadata() {
        // Metadata/inventory regression test. Routing completeness comes from the
        // exhaustive ChatView navigationDestination switch (no default) after
        // PlaceholderView was deleted — an unhandled case would not compile, though
        // rendering correctness of each destination view is validated by the app-wide
        // smoke pass (tasks Phase H) rather than by this unit test.
        XCTAssertFalse(MenuDestination.allCases.isEmpty)
        for destination in MenuDestination.allCases {
            XCTAssertFalse(destination.title.isEmpty, "destination \(destination) has empty title")
            XCTAssertFalse(destination.systemImage.isEmpty, "destination \(destination) has empty icon")
        }
        // Exact set of shipped destinations (adds/removes must be an explicit, reviewed change).
        let titles = Set(MenuDestination.allCases.map(\.title))
        XCTAssertEqual(titles, [
            "Info", "Policy", "Homework", "Learning Materials", "Exam Prep A1",
            "Word Review", "My chats", "Role Play", "About Us",
        ])
    }
}
