import XCTest
@testable import chatty_pal

@MainActor
private final class ProgressAPIFake: LearningProgressAPI {
    var records: [LessonProgress] = []
    var saves: [ShadowingAttempt] = []
    var failSave = false
    var failFetch = false
    var fetchGate: CheckedContinuation<[LessonProgress], Error>?
    var suspendFetch = false
    var commandCount = 0

    func userID(jwt: String) async throws -> Int { jwt == "account-a" ? 1 : 2 }
    func fetch(jwt: String) async throws -> [LessonProgress] {
        if failFetch { throw ProgressAPIError.request(503) }
        if suspendFetch {
            return try await withCheckedThrowingContinuation { fetchGate = $0 }
        }
        return records
    }
    func save(_ attempt: ShadowingAttempt, jwt: String) async throws -> LessonProgress {
        saves.append(attempt)
        if failSave { throw ProgressAPIError.request(503) }
        let result = LessonProgress(lessonId: attempt.lessonId, catalogRevision: attempt.catalogRevision,
            generation: attempt.generation, completedAt: nil, completionSource: nil,
            phrases: [PhraseProgress(phraseId: attempt.phraseId, bestScore: attempt.score,
                                     latestScore: attempt.score, transcript: attempt.transcript)])
        records = [result]
        return result
    }
    func command(lessonID: String, generation: Int, reset: Bool, jwt: String) async throws -> LessonProgress {
        commandCount += 1
        let result = LessonProgress(lessonId: lessonID, catalogRevision: MobileLearningCatalog.progressRevision,
            generation: reset ? generation + 1 : generation,
            completedAt: reset ? nil : "2026-10-21T10:00:00Z", completionSource: reset ? nil : "manual", phrases: [])
        records = [result]
        return result
    }
}

final class LearningProgressTests: XCTestCase {
    @MainActor private func defaults(_ name: String) -> UserDefaults {
        let name = "LearningProgressTests.\(name)"
        let defaults = UserDefaults(suiteName: name)!
        defaults.removePersistentDomain(forName: name)
        return defaults
    }

    @MainActor
    func testSaveRestoreAndRetryKeepsOriginalAttemptID() async {
        let api = ProgressAPIFake(), defaults = defaults(#function)
        let store = LearningProgressStore(api: api, defaults: defaults)
        store.configure(jwt: "account-a")
        await store.refresh()
        api.failSave = true
        store.enqueue(lessonID: "de-s-01", phraseID: "phrase", transcript: "Hallo", score: 90)
        let id = store.pending[0].id
        await store.refresh()
        XCTAssertEqual(store.pending.count, 1)
        XCTAssertNil(store.phrase(lessonID: "de-s-01", phraseID: "phrase"))
        XCTAssertNotNil(store.errors["de-s-01"])

        let reopened = LearningProgressStore(api: api, defaults: defaults)
        reopened.configure(jwt: "account-a")
        api.failSave = false
        await reopened.refresh()
        XCTAssertTrue(reopened.pending.isEmpty)
        XCTAssertEqual(api.saves.map(\.id), [id, id])
        XCTAssertTrue(reopened.phrase(lessonID: "de-s-01", phraseID: "phrase")?.passed == true)
        XCTAssertEqual(reopened.phrase(lessonID: "de-s-01", phraseID: "phrase")?.transcript, "Hallo")
    }

    @MainActor
    func testAccountSwitchDoesNotSubmitOtherUsersPendingWork() async {
        let api = ProgressAPIFake(), defaults = defaults(#function)
        let store = LearningProgressStore(api: api, defaults: defaults)
        store.configure(jwt: "account-a")
        await store.refresh()
        store.enqueue(lessonID: "de-s-01", phraseID: "phrase", transcript: "Private", score: 90)
        store.configure(jwt: "account-b")
        await store.refresh()
        XCTAssertTrue(store.pending.isEmpty)
        XCTAssertTrue(api.saves.isEmpty)
        XCTAssertTrue(store.lessons.isEmpty)
        store.configure(jwt: "account-a")
        await store.refresh()
        XCTAssertEqual(api.saves.count, 1)
    }

    @MainActor
    func testDelayedResponseCannotLeakIntoNewAccount() async {
        let api = ProgressAPIFake()
        let store = LearningProgressStore(api: api, defaults: defaults(#function))
        store.configure(jwt: "account-a")
        api.suspendFetch = true
        let task = Task { await store.refresh() }
        while api.fetchGate == nil { await Task.yield() }
        store.configure(jwt: "account-b")
        api.fetchGate?.resume(returning: [LessonProgress(lessonId: "private", catalogRevision: MobileLearningCatalog.progressRevision,
            generation: 0, completedAt: "date", completionSource: "manual", phrases: [])])
        await task.value
        XCTAssertTrue(store.lessons.isEmpty)
        XCTAssertFalse(store.isReady)
        XCTAssertFalse(store.isBusy)
    }

    @MainActor
    func testManualCompletionAndResetDoNotInventScoresOrModifyXP() async {
        let api = ProgressAPIFake(), defaults = defaults(#function)
        let stats = LearningStatsStore(defaults: defaults)
        stats.recordShadowingAttempt()
        let xp = stats.xp
        let store = LearningProgressStore(api: api, defaults: defaults)
        store.configure(jwt: "account-a")
        await store.refresh()
        await store.setCompletion(lessonID: "de-s-01", reset: false)
        XCTAssertEqual(store.completedLessonCount, 1)
        XCTAssertEqual(store.lessons["de-s-01"]?.completionSource, "manual")
        XCTAssertEqual(store.lessons["de-s-01"]?.phrases, [])
        await store.setCompletion(lessonID: "de-s-01", reset: true)
        XCTAssertEqual(store.completedLessonCount, 0)
        XCTAssertEqual(store.lessons["de-s-01"]?.generation, 1)
        XCTAssertEqual(stats.xp, xp)
    }

    @MainActor
    func testStalePendingAttemptCannotResurrectResetProgress() async {
        let api = ProgressAPIFake()
        let store = LearningProgressStore(api: api, defaults: defaults(#function))
        store.configure(jwt: "account-a")
        await store.refresh()
        store.enqueue(lessonID: "de-s-01", phraseID: "phrase", transcript: "Hallo", score: 100)
        api.records = [LessonProgress(lessonId: "de-s-01", catalogRevision: MobileLearningCatalog.progressRevision,
            generation: 1, completedAt: nil, completionSource: nil, phrases: [])]
        await store.refresh()
        XCTAssertTrue(api.saves.isEmpty)
        XCTAssertTrue(store.pending.isEmpty)
        XCTAssertFalse(store.lessons["de-s-01"]!.isCompleted)
        XCTAssertNotNil(store.errors["de-s-01"])
    }

    @MainActor
    func testGuestAndUnknownGenerationCannotPersistOrComplete() async {
        let api = ProgressAPIFake()
        let store = LearningProgressStore(api: api, defaults: defaults(#function))
        store.enqueue(lessonID: "de-s-01", phraseID: "phrase", transcript: "Hallo", score: 100)
        await store.setCompletion(lessonID: "de-s-01", reset: false)
        XCTAssertTrue(store.pending.isEmpty)
        XCTAssertEqual(api.commandCount, 0)
        store.configure(jwt: "account-a")
        api.failFetch = true
        await store.refresh()
        store.enqueue(lessonID: "de-s-01", phraseID: "phrase", transcript: "Hallo", score: 100)
        XCTAssertTrue(store.pending.isEmpty)
        XCTAssertFalse(store.isReady)
        XCTAssertNotNil(store.message)
    }

    @MainActor
    func testPendingSaveBlocksResetAndRepeatedRefreshDoesNotResubmit() async {
        let api = ProgressAPIFake()
        let store = LearningProgressStore(api: api, defaults: defaults(#function))
        store.configure(jwt: "account-a")
        await store.refresh()
        store.enqueue(lessonID: "de-s-01", phraseID: "phrase", transcript: "Hallo", score: 100)
        await store.setCompletion(lessonID: "de-s-01", reset: true)
        XCTAssertEqual(api.commandCount, 0)
        await store.refresh()
        await store.refresh()
        XCTAssertEqual(api.saves.count, 1)
    }

    func testPhrasePassThreshold() {
        XCTAssertFalse(PhraseProgress(phraseId: "p", bestScore: 79, latestScore: 79, transcript: "").passed)
        XCTAssertTrue(PhraseProgress(phraseId: "p", bestScore: 80, latestScore: 10, transcript: "").passed)
    }

    @MainActor
    func testSameUserIDOnDifferentBackendsKeepsSeparatePendingCaches() async {
        let api = ProgressAPIFake()
        let store = LearningProgressStore(api: api, defaults: defaults(#function))
        store.configure(jwt: "account-a", backendID: "https://first.example.invalid/api")
        await store.refresh()
        store.enqueue(lessonID: "de-s-01", phraseID: "phrase", transcript: "Private first backend", score: 90)
        store.configure(jwt: "account-a", backendID: "https://second.example.invalid/api")
        await store.refresh()
        XCTAssertTrue(store.pending.isEmpty)
        XCTAssertTrue(api.saves.isEmpty)
        store.configure(jwt: "account-a", backendID: "https://first.example.invalid/api")
        await store.refresh()
        XCTAssertEqual(api.saves.count, 1)
    }

    @MainActor
    func testOversizedTranscriptCannotTrapQueue() async {
        let api = ProgressAPIFake()
        let store = LearningProgressStore(api: api, defaults: defaults(#function))
        store.configure(jwt: "account-a")
        await store.refresh()
        store.enqueue(lessonID: "de-s-01", phraseID: "phrase", transcript: String(repeating: "😀", count: 2501), score: 90)
        XCTAssertTrue(store.pending.isEmpty)
        XCTAssertNotNil(store.errors["de-s-01"])
        store.enqueue(lessonID: "de-s-01", phraseID: "phrase", transcript: "Short valid attempt", score: 90)
        await store.refresh()
        XCTAssertEqual(api.saves.count, 1)
        XCTAssertTrue(store.pending.isEmpty)
    }
}
