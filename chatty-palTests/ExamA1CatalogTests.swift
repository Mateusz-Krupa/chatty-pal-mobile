import XCTest
@testable import chatty_pal

final class ExamA1CatalogTests: XCTestCase {
    func testUnitIDsAreUnique() {
        let ids = ExamA1Catalog.units.map(\.id)
        XCTAssertEqual(ids.count, Set(ids).count, "Unit IDs must be unique")
    }

    func testItemIDsAreUniqueAcrossAllUnits() {
        var ids: [String] = []
        for unit in ExamA1Catalog.units {
            ids.append(contentsOf: unit.vocabulary.map(\.id))
            ids.append(contentsOf: unit.phrases.map(\.id))
            ids.append(contentsOf: unit.dialogue.map(\.id))
            ids.append(contentsOf: unit.exercises.map(\.id))
        }
        XCTAssertEqual(ids.count, Set(ids).count, "Vocabulary, phrase, dialogue and exercise IDs must be unique")
    }

    func testEveryUnitBelongsToAnExamSection() {
        for unit in ExamA1Catalog.units {
            XCTAssertTrue(ExamSection.allCases.contains(unit.section), "Unit \(unit.id) has an invalid section")
        }
    }

    func testExercisesHaveValidCorrectIndex() {
        for unit in ExamA1Catalog.units {
            for exercise in unit.exercises {
                XCTAssertFalse(exercise.options.isEmpty, "Exercise \(exercise.id) has no options")
                XCTAssertTrue(
                    exercise.correctIndex >= 0 && exercise.correctIndex < exercise.options.count,
                    "Exercise \(exercise.id) has an invalid correctIndex"
                )
            }
        }
    }

    func testAtLeastTwelveVocabularyUnits() {
        let vocab = ExamA1Catalog.units.filter { $0.id.hasPrefix("a1-voc-") }
        XCTAssertGreaterThanOrEqual(vocab.count, 12, "Expected at least 12 vocabulary units")
    }

    func testAtLeastTenGrammarUnits() {
        let grammar = ExamA1Catalog.units.filter { $0.id.hasPrefix("a1-gram-") }
        XCTAssertGreaterThanOrEqual(grammar.count, 10, "Expected at least 10 grammar units")
    }

    func testAtLeastOneUnitPerExamSection() {
        for section in ExamSection.allCases {
            XCTAssertFalse(ExamA1Catalog.units(in: section).isEmpty, "Section \(section.rawValue) has no units")
        }
    }

    func testMiniExamHasAtLeastOneQuestionPerSectionWithExercises() {
        let sectionsWithExercises = Set(
            ExamA1Catalog.units
                .filter { !$0.exercises.isEmpty }
                .map(\.section)
        )
        let questions = ExamA1Catalog.buildMiniExamQuestions()
        XCTAssertFalse(questions.isEmpty, "Mini exam must have questions")
        let questionIDs = Set(questions.map(\.id))
        XCTAssertEqual(questions.count, questionIDs.count, "Mini exam questions must be unique")
        for section in sectionsWithExercises {
            let hasQuestion = ExamA1Catalog.units(in: section).contains { unit in
                unit.exercises.contains { questionIDs.contains($0.id) }
            }
            XCTAssertTrue(hasQuestion, "Mini exam must include at least one question from \(section.rawValue)")
        }
    }

    func testSpeakingUnitsHaveScenarios() {
        for unit in ExamA1Catalog.units(in: .speaking) {
            XCTAssertNotNil(unit.speakingScenario, "Speaking unit \(unit.id) must have a scenario")
        }
    }

    func testWritingUnitsHavePrompts() {
        for unit in ExamA1Catalog.units(in: .writing) {
            XCTAssertNotNil(unit.writingPrompt, "Writing unit \(unit.id) must have a prompt")
        }
    }
}
