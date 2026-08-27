import XCTest
@testable import chatty_pal

@MainActor
final class ExamCampaignTests: XCTestCase {

    // MARK: - Catalog structure

    func testCampaignCatalogIsStructurallyValid() {
        let issues = ExamCampaignValidation.validate().filter { $0.severity == "error" }
        XCTAssertTrue(issues.isEmpty, "Validation errors: \(issues.map(\.description))")
    }

    func testZonesAreOrderedFromOne() {
        let orders = ExamCampaignCatalog.zones.map(\.order)
        XCTAssertEqual(orders, Array(1...ExamCampaignCatalog.zones.count))
    }

    func testOrderedNodesFollowZoneAndLessonOrder() {
        let nodes = ExamCampaignCatalog.orderedNodes
        XCTAssertEqual(nodes.count, ExamCampaignCatalog.zones.reduce(0) { $0 + $1.nodes.count })
        var lastZoneOrder = -1
        for entry in nodes {
            XCTAssertGreaterThanOrEqual(entry.zone.order, lastZoneOrder, "zones must not go backwards")
            lastZoneOrder = entry.zone.order
        }
    }

    // MARK: - Content coverage

    func testContentCoversRequiredScope() {
        let lessons = ExamCampaignCatalog.allLessons
        let vocabThemes = Set(lessons.flatMap { $0.vocabulary.map(\.id) })
        XCTAssertGreaterThanOrEqual(vocabThemes.count, 12 * 5, "expected vocabulary from at least 12 themes, got \(vocabThemes.count) items")

        let grammarUnits = Set(lessons.flatMap { $0.grammarPoints.map(\.id) })
        XCTAssertGreaterThanOrEqual(grammarUnits.count, 10, "expected at least 10 grammar objectives, got \(grammarUnits.count)")

        var hasReading = false
        var hasListening = false
        var hasSpeaking = false
        var hasWriting = false
        for lesson in lessons {
            if lesson.hasReadingTask { hasReading = true }
            if lesson.exercises.contains(where: { $0.kind == .listening }) { hasListening = true }
            if lesson.speaking != nil { hasSpeaking = true }
            if lesson.writingPrompt != nil { hasWriting = true }
        }
        XCTAssertTrue(hasReading, "campaign must include reading practice")
        XCTAssertTrue(hasListening, "campaign must include listening practice")
        XCTAssertTrue(hasSpeaking, "campaign must include speaking practice")
        XCTAssertTrue(hasWriting, "campaign must include writing practice")
    }

    func testEveryCheckpointHasExercises() {
        for checkpoint in ExamCampaignCatalog.allCheckpoints {
            XCTAssertFalse(ExamCampaignCatalog.checkpointExercises(checkpoint).isEmpty,
                           "checkpoint \(checkpoint.id) has no resolvable exercises")
        }
    }

    // MARK: - Unlocking and progress

    private func freshProgress() -> ExamCampaignProgress {
        ExamCampaignProgress(defaults: UserDefaults(suiteName: "campaign-test-\(UUID().uuidString)")!)
    }

    func testFirstLessonUnlockedOthersLocked() {
        let progress = freshProgress()
        let zone1 = ExamCampaignCatalog.zones[0]
        XCTAssertTrue(progress.isLessonUnlocked(zone1.lessons[0]))
        XCTAssertFalse(progress.isLessonUnlocked(zone1.lessons[1]))
        XCTAssertFalse(progress.isCheckpointUnlocked(zone1.checkpoints[0]))
        XCTAssertFalse(progress.isFinalExamUnlocked())
    }

    func testCompletingLessonUnlocksNext() {
        let progress = freshProgress()
        let zone1 = ExamCampaignCatalog.zones[0]
        let first = zone1.lessons[0]
        let second = zone1.lessons[1]

        XCTAssertFalse(progress.isLessonUnlocked(second))
        progress.record(MissionResult(stars: 2, correctCount: 5, exerciseCount: 10, completedSpeaking: true), for: first.id)

        XCTAssertTrue(progress.isComplete(first.id))
        XCTAssertTrue(progress.isLessonUnlocked(second))
        XCTAssertEqual(progress.bestStars(first.id), 2)
        XCTAssertEqual(progress.completedCount(in: zone1), 1)
    }

    func testReplayKeepsBestStars() {
        let progress = freshProgress()
        let first = ExamCampaignCatalog.zones[0].lessons[0]
        progress.record(MissionResult(stars: 3, correctCount: 10, exerciseCount: 10, completedSpeaking: true), for: first.id)
        progress.record(MissionResult(stars: 1, correctCount: 5, exerciseCount: 10), for: first.id)
        XCTAssertEqual(progress.bestStars(first.id), 3)
        XCTAssertEqual(progress.completedCount(in: ExamCampaignCatalog.zones[0]), 1)
    }

    func testStarsFormula() {
        XCTAssertEqual(MissionStars.stars(correct: 10, total: 10, spoke: true, wrote: true), 3)
        XCTAssertEqual(MissionStars.stars(correct: 6, total: 10, spoke: false, wrote: false), 2)
        XCTAssertEqual(MissionStars.stars(correct: 4, total: 10, spoke: false, wrote: false), 1)
        XCTAssertEqual(MissionStars.stars(correct: 2, total: 10, spoke: false, wrote: false), 0)
    }

    func testLegacyProgressMigratesToCampaign() {
        let suiteName = "campaign-legacy-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        let legacyID = "a1-voc-familie"
        defaults.set([legacyID], forKey: ExamCampaignProgress.legacyCompletedKey)
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let progress = ExamCampaignProgress(defaults: defaults)
        guard let lesson = ExamCampaignCatalog.lesson(byLegacyID: legacyID) else {
            return XCTFail("legacy unit \(legacyID) does not map to a campaign lesson")
        }
        XCTAssertTrue(progress.isComplete(lesson.id))
        XCTAssertTrue(progress.isLegacyComplete(legacyID))
    }

    func testProgressSurvivesRestart() {
        let suiteName = "campaign-persist-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let lesson = ExamCampaignCatalog.zones[0].lessons[0]

        let first = ExamCampaignProgress(defaults: defaults)
        first.record(MissionResult(stars: 2, correctCount: 8, exerciseCount: 10), for: lesson.id)

        let second = ExamCampaignProgress(defaults: defaults)
        XCTAssertTrue(second.isComplete(lesson.id))
        XCTAssertEqual(second.bestStars(lesson.id), 2)
    }

    // MARK: - Mission planning

    func testReadingPassagesBindTextToQuestions() {
        let l20 = ExamCampaignCatalog.lesson(id: "l20-reading-technique")!
        XCTAssertEqual(l20.readingPassages.map(\.id), ["a1-read-mail", "a1-read-museum", "a1-read-stellenanzeige"])
        for passage in l20.readingPassages {
            XCTAssertFalse(passage.text.isEmpty, "passage \(passage.id) must carry its text")
            XCTAssertEqual(passage.questions.map(\.id).prefix(1).first?.hasPrefix(passage.id), true)
            let source = ExamA1Catalog.units.first { $0.id == passage.id }
            XCTAssertEqual(passage.questions.map(\.id), source?.exercises.map(\.id))
        }
        XCTAssertEqual(l20.readingExercises.count, 15)

        for lesson in ExamCampaignCatalog.allLessons {
            for passage in lesson.readingPassages {
                XCTAssertFalse(passage.text.isEmpty)
                XCTAssertFalse(passage.questions.isEmpty)
            }
        }
    }

    func testMissionPlanOrderAndSpeakingGate() {
        let speaking = ExamCampaignCatalog.lesson(id: "l3-speaking-introduce")!
        let plan = MissionPlan(lesson: speaking)
        XCTAssertTrue(plan.steps.contains(.speaking))
        XCTAssertTrue(plan.steps.first == .briefing)
        XCTAssertEqual(plan.steps.last, .outcome)
        XCTAssertTrue(plan.requiresSpokenInteraction)

        let reading = ExamCampaignCatalog.lesson(id: "l4-reading-form")!
        let readingPlan = MissionPlan(lesson: reading)
        XCTAssertFalse(readingPlan.steps.contains(.speaking))
        XCTAssertFalse(readingPlan.requiresSpokenInteraction)
    }
}
