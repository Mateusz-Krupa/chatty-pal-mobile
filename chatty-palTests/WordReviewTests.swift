import XCTest
@testable import chatty_pal

final class WordReviewTests: XCTestCase {
    private let day: TimeInterval = 24 * 60 * 60
    private let now = Date(timeIntervalSince1970: 1_700_000_000)

    private func word(box: Int, due: Date) -> ReviewWord {
        ReviewWord(id: "test", german: "Test", english: "test", example: nil, source: "test", box: box, due: due)
    }

    private func makeDefaults() -> UserDefaults {
        UserDefaults(suiteName: "WordReviewTests-\(UUID().uuidString)")!
    }

    // MARK: - Scheduler

    func testNewWordIsDueNowInBoxOne() {
        let w = word(box: 1, due: now)
        XCTAssertEqual(WordReviewScheduler.dueWords([w], now: now).count, 1)
        XCTAssertEqual(WordReviewScheduler.dueWords([w], now: now.addingTimeInterval(-1)).count, 0)
    }

    func testGoodAdvancesOneBoxAndSchedulesInterval() {
        let w = word(box: 1, due: now)
        let result = WordReviewScheduler.schedule(for: w, grade: .good, now: now)
        XCTAssertEqual(result.box, 2)
        XCTAssertEqual(result.due, now.addingTimeInterval(day))
    }

    func testEasyAdvancesTwoBoxes() {
        let w = word(box: 2, due: now)
        let result = WordReviewScheduler.schedule(for: w, grade: .easy, now: now)
        XCTAssertEqual(result.box, 4)
        XCTAssertEqual(result.due, now.addingTimeInterval(7 * day))
    }

    func testAgainResetsToBoxOneInTenMinutes() {
        let w = word(box: 4, due: now)
        let result = WordReviewScheduler.schedule(for: w, grade: .again, now: now)
        XCTAssertEqual(result.box, 1)
        XCTAssertEqual(result.due, now.addingTimeInterval(10 * 60))
    }

    func testBoxCapsAtFive() {
        let w = word(box: 5, due: now)
        let good = WordReviewScheduler.schedule(for: w, grade: .good, now: now)
        let easy = WordReviewScheduler.schedule(for: w, grade: .easy, now: now)
        XCTAssertEqual(good.box, 5)
        XCTAssertEqual(easy.box, 5)
        XCTAssertEqual(good.due, now.addingTimeInterval(14 * day))
    }

    func testDueWordsSortedMostOverdueFirst() {
        let a = ReviewWord(id: "a", german: "A", english: "a", example: nil, source: "t", box: 1, due: now.addingTimeInterval(-10))
        let b = ReviewWord(id: "b", german: "B", english: "b", example: nil, source: "t", box: 1, due: now.addingTimeInterval(-30))
        let future = ReviewWord(id: "c", german: "C", english: "c", example: nil, source: "t", box: 1, due: now.addingTimeInterval(10))
        let due = WordReviewScheduler.dueWords([a, future, b], now: now)
        XCTAssertEqual(due.map(\.id), ["b", "a"])
    }

    func testNormalizedIDLowercasesAndCollapsesWhitespace() {
        XCTAssertEqual(WordReviewScheduler.normalizedID("  Der   Einkauf "), "der einkauf")
    }

    // MARK: - Store

    @MainActor
    func testAddDedupesByNormalizedGerman() {
        let store = WordReviewStore(defaults: makeDefaults())
        store.add(german: "Der Einkauf", english: "the shopping trip", source: "t1")
        store.add(german: "der  einkauf", english: "other", source: "t2")
        XCTAssertEqual(store.words.count, 1)
        XCTAssertEqual(store.words.first?.english, "the shopping trip")
        XCTAssertEqual(store.words.first?.source, "t1")
    }

    @MainActor
    func testGradeUpdatesBoxAndDue() {
        let store = WordReviewStore(defaults: makeDefaults())
        store.add(german: "Haus", english: "house", source: "t")
        let now = Date()
        store.grade(wordID: "haus", grade: .good, now: now)

        let w = store.words.first!
        XCTAssertEqual(w.box, 2)
        XCTAssertEqual(w.due.timeIntervalSince(now), day, accuracy: 1)
        XCTAssertEqual(store.dueCount, 0)
    }

    @MainActor
    func testAgainMakesWordDueAgainInTenMinutes() {
        let store = WordReviewStore(defaults: makeDefaults())
        store.add(german: "Haus", english: "house", source: "t")
        let now = Date()
        store.grade(wordID: "haus", grade: .again, now: now)

        let w = store.words.first!
        XCTAssertEqual(w.box, 1)
        XCTAssertEqual(w.due.timeIntervalSince(now), 10 * 60, accuracy: 1)
        XCTAssertEqual(store.dueCount, 0)
        // 11 minutes later it is due again
        XCTAssertEqual(store.dueSession(now: now.addingTimeInterval(11 * 60)).count, 1)
    }

    @MainActor
    func testSessionCapsAtLimit() {
        let store = WordReviewStore(defaults: makeDefaults())
        for i in 0..<25 {
            store.add(german: "Word \(i)", english: "word", source: "t")
        }
        XCTAssertEqual(store.dueSession(now: Date()).count, 20)
        XCTAssertEqual(store.dueCount, 25)
    }

    @MainActor
    func testPersistenceRoundTrip() {
        let defaults = makeDefaults()
        let store = WordReviewStore(defaults: defaults)
        store.add(german: "Brot", english: "bread", example: "Ich esse Brot.", source: "t")
        store.grade(wordID: "brot", grade: .easy, now: now)

        let reloaded = WordReviewStore(defaults: defaults)
        XCTAssertEqual(reloaded.words.count, 1)
        XCTAssertEqual(reloaded.words.first?.box, 3)
        XCTAssertEqual(reloaded.words.first?.english, "bread")
    }

    @MainActor
    func testAddLessonCollectsVocabularyAndPhrases() {
        let store = WordReviewStore(defaults: makeDefaults())
        let lesson = MobileLearningCatalog.germanLessons[0]
        store.addLesson(lesson)

        let expected = lesson.vocabulary.count + lesson.phrases.count
        XCTAssertEqual(store.words.count, expected)
        XCTAssertTrue(store.words.allSatisfy { $0.source == "lesson:\(lesson.id)" })
    }

    @MainActor
    func testAddExamUnitCollectsUnitVocabulary() {
        let store = WordReviewStore(defaults: makeDefaults())
        let unit = ExamA1Content.units.first { $0.id == "a1-voc-zahlen" }!
        store.addExamUnit(unit)
        XCTAssertEqual(store.words.count, unit.vocabulary.count)
        XCTAssertTrue(store.words.allSatisfy { $0.source == "exam:\(unit.id)" })
    }

    // MARK: - Scoping and migration

    private func withAuthUsername(_ username: String?, _ body: () -> Void) {
        let standard = UserDefaults.standard
        let original = standard.string(forKey: "authUsername")
        if let username {
            standard.set(username, forKey: "authUsername")
        } else {
            standard.removeObject(forKey: "authUsername")
        }
        defer {
            if let original {
                standard.set(original, forKey: "authUsername")
            } else {
                standard.removeObject(forKey: "authUsername")
            }
        }
        body()
    }

    @MainActor
    func testLegacyWordsMigratedToScopedKey() {
        let defaults = makeDefaults()
        let legacy = [word(box: 1, due: now)]
        defaults.set(try! JSONEncoder().encode(legacy), forKey: "learning.wordReview")

        // Legacy data migrates to the signed-in user on first load.
        withAuthUsername("alice") {
            let store = WordReviewStore(defaults: defaults)
            XCTAssertEqual(store.words.count, 1)
            XCTAssertNil(defaults.data(forKey: "learning.wordReview"))
        }
    }

    @MainActor
    func testAccountsAreIsolated() {
        let defaults = makeDefaults()
        withAuthUsername("alice") {
            WordReviewStore(defaults: defaults).add(german: "Haus", english: "house", source: "t")
        }
        withAuthUsername("bob") {
            XCTAssertEqual(WordReviewStore(defaults: defaults).words.count, 0)
        }
        withAuthUsername("alice") {
            XCTAssertEqual(WordReviewStore(defaults: defaults).words.count, 1)
        }
    }

    @MainActor
    func testGuestWordsCarriedToUserOnLogin() {
        let defaults = makeDefaults()
        withAuthUsername(nil) {
            WordReviewStore(defaults: defaults).add(german: "Brot", english: "bread", source: "t")
        }
        withAuthUsername("alice") {
            XCTAssertEqual(WordReviewStore(defaults: defaults).words.count, 1)
        }
        withAuthUsername("bob") {
            XCTAssertEqual(WordReviewStore(defaults: defaults).words.count, 0)
        }
    }
}
