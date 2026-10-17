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
        XCTAssertEqual(ExamCampaignCatalog.zones.count, 6)
        XCTAssertEqual(ExamCampaignCatalog.allCheckpoints.count, 5)
        XCTAssertNotNil(ExamCampaignCatalog.finalExam)
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
        let vocabIDs = Set(lessons.flatMap { $0.vocabulary.map(\.id) })
        let vocabThemes = Set(vocabIDs.map { $0.components(separatedBy: "-").dropLast().joined(separator: "-") })
        XCTAssertGreaterThanOrEqual(vocabThemes.count, 12, "expected vocabulary from at least 12 themes, got \(vocabThemes.count)")

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
        // Quiz-only lesson: the 10 exercises are the whole denominator.
        XCTAssertEqual(MissionStars.stars(correct: 10, totalExercises: 10, spoke: false, hasSpeakingTask: false, wrote: false, hasWritingTask: false), 3)
        XCTAssertEqual(MissionStars.stars(correct: 6, totalExercises: 10, spoke: false, hasSpeakingTask: false, wrote: false, hasWritingTask: false), 2)
        XCTAssertEqual(MissionStars.stars(correct: 4, totalExercises: 10, spoke: false, hasSpeakingTask: false, wrote: false, hasWritingTask: false), 1)
        XCTAssertEqual(MissionStars.stars(correct: 2, totalExercises: 10, spoke: false, hasSpeakingTask: false, wrote: false, hasWritingTask: false), 0)
        // Speaking-only lesson (no quiz): doing the task is the entire activity set.
        XCTAssertEqual(MissionStars.stars(correct: 0, totalExercises: 0, spoke: true, hasSpeakingTask: true, wrote: false, hasWritingTask: false), 3)
        XCTAssertEqual(MissionStars.stars(correct: 0, totalExercises: 0, spoke: false, hasSpeakingTask: true, wrote: false, hasWritingTask: false), 0)
        // Mixed lesson: a perfect quiz without the present productive task is not 3 stars,
        // and the productive task alone cannot reach 3 stars without the quiz.
        XCTAssertEqual(MissionStars.stars(correct: 6, totalExercises: 6, spoke: false, hasSpeakingTask: true, wrote: false, hasWritingTask: false), 2)
        XCTAssertEqual(MissionStars.stars(correct: 6, totalExercises: 6, spoke: true, hasSpeakingTask: true, wrote: false, hasWritingTask: false), 3)
        // Doing only the productive task while missing every quiz answer is far from the
        // lesson's goal: 1 of 7 activities = 14%, below the 30% star floor.
        XCTAssertEqual(MissionStars.stars(correct: 0, totalExercises: 6, spoke: true, hasSpeakingTask: true, wrote: false, hasWritingTask: false), 0)
        // A lesson with no activities at all never earns stars.
        XCTAssertEqual(MissionStars.stars(correct: 0, totalExercises: 0, spoke: false, hasSpeakingTask: false, wrote: false, hasWritingTask: false), 0)
        // Exact floors and the correct-count clamp.
        XCTAssertEqual(MissionStars.stars(correct: 3, totalExercises: 10, spoke: false, hasSpeakingTask: false, wrote: false, hasWritingTask: false), 1, "30% exact floor")
        XCTAssertEqual(MissionStars.stars(correct: 4, totalExercises: 6, spoke: false, hasSpeakingTask: true, wrote: false, hasWritingTask: false), 1, "4 of a 7-activity lesson is 57%, below the 60% bar")
        XCTAssertEqual(MissionStars.stars(correct: 5, totalExercises: 6, spoke: false, hasSpeakingTask: true, wrote: false, hasWritingTask: false), 2)
        XCTAssertEqual(MissionStars.stars(correct: 20, totalExercises: 10, spoke: false, hasSpeakingTask: true, wrote: false, hasWritingTask: false), 2,
                       "overflowing correct counts must be clamped and may not compensate for an undone speaking task")
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

    // MARK: - R1 regressions (professionalize-goethe-a1-prep, tasks 2.1/2.3)

    func testReadingLessonsAttachDeclaredPassages() {
        // Regression: passages() zipped unit IDs against an empty titles list, silently
        // producing zero passages whenever the caller omitted titles. The assertions pin
        // the *declared* content, not just whatever happened to be attached.
        let l4 = ExamCampaignCatalog.lesson(id: "l4-reading-form")!
        XCTAssertEqual(l4.readingPassages.map(\.id), ["a1-read-formular"])
        let formular = ExamA1Catalog.units.first { $0.id == "a1-read-formular" }
        XCTAssertEqual(l4.readingPassages.first?.questions.map(\.id), formular?.exercises.map(\.id))
        XCTAssertFalse(l4.readingPassages.first!.text.isEmpty)
        XCTAssertTrue(MissionPlan(lesson: l4).steps.contains(.examTask), "declared reading must appear in the mission plan")

        let l17 = ExamCampaignCatalog.lesson(id: "l17-reading-offers")!
        XCTAssertEqual(l17.readingPassages.map(\.id), ["a1-read-anzeige", "a1-read-reise"])
        for passage in l17.readingPassages {
            let unit = ExamA1Catalog.units.first { $0.id == passage.id }
            XCTAssertFalse(passage.text.isEmpty, "passage \(passage.id) must carry its source text")
            XCTAssertEqual(passage.questions.map(\.id), unit?.exercises.map(\.id),
                           "passage \(passage.id) must bind exactly the unit's questions")
        }
        XCTAssertTrue(MissionPlan(lesson: l17).steps.contains(.examTask))

        for lesson in ExamCampaignCatalog.allLessons {
            for unitID in lesson.legacyUnitIDs where unitID.hasPrefix("a1-read-") {
                XCTAssertTrue(lesson.readingPassages.contains { $0.id == unitID },
                              "lesson \(lesson.id) declares reading unit \(unitID) but does not attach it")
            }
        }
    }

    func testDeclaredCheckpointAndFinalExercisesAllResolve() {
        for checkpoint in ExamCampaignCatalog.allCheckpoints {
            XCTAssertEqual(ExamCampaignCatalog.unresolvedExerciseIDs(checkpoint.exerciseIDs), [],
                           "checkpoint \(checkpoint.id) declares unresolvable exercises")
            XCTAssertEqual(ExamCampaignCatalog.checkpointExercises(checkpoint).map(\.id), checkpoint.exerciseIDs,
                           "checkpoint \(checkpoint.id) must resolve every declared ID, in declared order")
            for id in checkpoint.speakingLessonIDs {
                XCTAssertNotNil(ExamCampaignCatalog.lesson(id: id)?.speaking,
                                "checkpoint \(checkpoint.id) references lesson \(id) without a speaking task")
            }
        }

        let exam = ExamCampaignCatalog.finalExam!
        XCTAssertEqual(ExamCampaignCatalog.unresolvedExerciseIDs(exam.exerciseIDs), [])
        XCTAssertEqual(ExamCampaignCatalog.finalExamExercises(exam).map(\.id), exam.exerciseIDs,
                       "the practice test must resolve every declared ID, in declared order")
        for id in exam.writingLessonIDs {
            XCTAssertNotNil(ExamCampaignCatalog.lesson(id: id)?.writingPrompt)
        }
        for id in exam.speakingLessonIDs {
            XCTAssertNotNil(ExamCampaignCatalog.lesson(id: id)?.speaking)
        }
    }

    // MARK: - R1 completion evidence (tasks 2.4/2.5/2.6)

    func testMissionCompletionNeedsEvidencePerActivityType() {
        let speaking = ExamCampaignCatalog.lesson(id: "l3-speaking-introduce")!
        XCTAssertTrue(speaking.exercises.isEmpty && speaking.readingExercises.isEmpty,
                      "fixture expects a quiz-free speaking lesson")
        XCTAssertFalse(MissionCompletion.canCompleteLesson(lesson: speaking, correct: 0, checkedCount: 0, spoke: false, wrote: false),
                       "walking through a speaking lesson must not complete it")
        XCTAssertTrue(MissionCompletion.canCompleteLesson(lesson: speaking, correct: 0, checkedCount: 0, spoke: true, wrote: false))

        let writing = ExamCampaignCatalog.lesson(id: "l14-writing-messages")!
        XCTAssertNotNil(writing.writingPrompt)
        XCTAssertFalse(MissionCompletion.canCompleteLesson(lesson: writing, correct: 0, checkedCount: 0, spoke: false, wrote: false),
                       "a visited writing screen must not complete the lesson")
        XCTAssertTrue(MissionCompletion.canCompleteLesson(lesson: writing, correct: 0, checkedCount: 0, spoke: false, wrote: true))

        let quiz = ExamCampaignCatalog.lesson(id: "l1-identity")!
        let total = quiz.exercises.count + quiz.readingExercises.count
        XCTAssertGreaterThan(total, 0)
        XCTAssertFalse(MissionCompletion.canCompleteLesson(lesson: quiz, correct: total, checkedCount: total - 1, spoke: false, wrote: false),
                       "every declared exercise must be checked before completion")
        XCTAssertFalse(MissionCompletion.canCompleteLesson(lesson: quiz, correct: total * 7 / 10, checkedCount: total, spoke: false, wrote: false),
                       "below 80% correct must not complete")
        XCTAssertTrue(MissionCompletion.canCompleteLesson(lesson: quiz, correct: (total * 8 + 9) / 10, checkedCount: total, spoke: false, wrote: false),
                      "the minimal 80% pass must complete")
        XCTAssertTrue(MissionCompletion.canCompleteLesson(lesson: quiz, correct: total, checkedCount: total, spoke: false, wrote: false))
    }

    func testLessonCompletionCombinesQuizAndProductiveRequirements() {
        // Gap found in review: the two clauses of canCompleteLesson must INTERACT —
        // a passed quiz alone cannot complete a lesson that also carries a speaking task.
        let l12 = ExamCampaignCatalog.lesson(id: "l12-doctor-health")!
        let total = l12.exercises.count + l12.readingExercises.count
        XCTAssertGreaterThan(total, 0, "fixture expects l12 to carry a quiz")
        XCTAssertNotNil(l12.speaking, "fixture expects l12 to carry a speaking task")
        XCTAssertFalse(MissionCompletion.canCompleteLesson(lesson: l12, correct: total, checkedCount: total, spoke: false, wrote: false),
                       "quiz alone must not complete a lesson with a speaking task")
        XCTAssertTrue(MissionCompletion.canCompleteLesson(lesson: l12, correct: total, checkedCount: total, spoke: true, wrote: false))
    }

    func testEmptyActivitiesAreNeverCompletable() {
        let checkpoint = CampaignCheckpoint(id: "empty-cp", zoneID: "z-test", order: 99,
                                            title: "t", description: "d",
                                            exerciseIDs: [], speakingLessonIDs: [])
        XCTAssertFalse(MissionCompletion.canCompleteCheckpoint(checkpoint, correct: 0, checkedCount: 0))
        let exam = CampaignFinalExam(id: "empty-exam", title: "t", description: "d",
                                     requiredZoneIDs: [], exerciseIDs: [],
                                     writingLessonIDs: [], speakingLessonIDs: [])
        XCTAssertFalse(MissionCompletion.canCompleteFinalExam(exam, correct: 0, checkedCount: 0,
                                                              isLessonComplete: { _ in true }))
    }

    func testCheckpointCompletionRequiresEveryAnswer() {
        let checkpoint = ExamCampaignCatalog.allCheckpoints[0]
        let total = checkpoint.exerciseIDs.count
        XCTAssertFalse(MissionCompletion.canCompleteCheckpoint(checkpoint, correct: 0, checkedCount: 0),
                       "passing a checkpoint without any answer is forbidden")
        XCTAssertFalse(MissionCompletion.canCompleteCheckpoint(checkpoint, correct: total, checkedCount: total - 1),
                       "unanswered questions block passing")
        XCTAssertFalse(MissionCompletion.canCompleteCheckpoint(checkpoint, correct: 3, checkedCount: total),
                       "below 60% correct must not pass")
        XCTAssertTrue(MissionCompletion.canCompleteCheckpoint(checkpoint, correct: 4, checkedCount: total))
    }

    func testFinalPracticeTestNeedsQuizzesAndProductiveLessons() {
        let exam = ExamCampaignCatalog.finalExam!
        let total = exam.exerciseIDs.count
        XCTAssertFalse(MissionCompletion.canCompleteFinalExam(exam, correct: total, checkedCount: total, isLessonComplete: { _ in false }),
                       "the practice test must not finish without the linked writing and speaking lessons")
        XCTAssertFalse(MissionCompletion.canCompleteFinalExam(exam, correct: 0, checkedCount: 0, isLessonComplete: { _ in true }),
                       "unanswered quiz questions must not be skippable")
        XCTAssertFalse(MissionCompletion.canCompleteFinalExam(exam, correct: 5, checkedCount: total, isLessonComplete: { _ in true }),
                       "below 60% correct must not finish")
        XCTAssertFalse(MissionCompletion.canCompleteFinalExam(exam, correct: 7, checkedCount: total, isLessonComplete: { _ in true }),
                       "70 >= 72 is false: 7 of 12 is below the 60% bar")
        XCTAssertTrue(MissionCompletion.canCompleteFinalExam(exam, correct: 8, checkedCount: total, isLessonComplete: { _ in true }),
                      "8 of 12 is the minimal 60% pass")
        let requiredLessons = Set(exam.writingLessonIDs + exam.speakingLessonIDs)
        XCTAssertTrue(MissionCompletion.canCompleteFinalExam(exam, correct: total, checkedCount: total,
                                                             isLessonComplete: { requiredLessons.contains($0) }))
    }

    func testMissionResultSurvivesSaveAndReloadWithSameValues() {
        let suiteName = "campaign-result-reload-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let lesson = ExamCampaignCatalog.lesson(id: "l3-speaking-introduce")!
        let outcome = MissionResult(
            stars: MissionStars.stars(correct: 0, totalExercises: lesson.exercises.count,
                                      spoke: true, hasSpeakingTask: lesson.speaking != nil,
                                      wrote: false, hasWritingTask: lesson.writingPrompt != nil),
            correctCount: 0,
            exerciseCount: lesson.exercises.count + lesson.readingExercises.count,
            completedSpeaking: true,
            completedWriting: false
        )
        XCTAssertEqual(outcome.stars, 3, "the speaking task is this lesson's whole activity set")

        ExamCampaignProgress(defaults: defaults).record(outcome, for: lesson.id)

        let reloaded = ExamCampaignProgress(defaults: defaults)
        XCTAssertEqual(reloaded.bestStars(lesson.id), outcome.stars)
        XCTAssertEqual(reloaded.progress(for: lesson.id)?.exerciseCount, outcome.exerciseCount)
        XCTAssertEqual(reloaded.progress(for: lesson.id)?.completedSpeaking, true)
        XCTAssertEqual(reloaded.progress(for: lesson.id)?.completedWriting, false,
                       "a lesson without writing must not store writing as done")
    }

    // MARK: - R1 review round 1 (source binding, explicit resolution, honest claims)

    func testExerciseGroupsBindReadingQuestionsToTheirSource() {
        // The views render ExerciseGrouping output: a reading question must never render
        // without the passage it is about (checkpoints/finals used to flatten lists).
        let l17 = ExamCampaignCatalog.lesson(id: "l17-reading-offers")!
        let l17List = l17.exercises + l17.readingExercises
        let l17Groups = ExerciseGrouping.groups(for: l17List)
        XCTAssertEqual(l17Groups.flatMap(\.exercises).map(\.id), l17List.map(\.id),
                       "grouping must not lose or reorder questions")
        let l17Reading = l17Groups.compactMap { group -> (String, [String])? in
            guard let passage = group.passage else { return nil }
            return (passage.id, group.exercises.map(\.id))
        }
        XCTAssertEqual(l17Reading.map(\.0), ["a1-read-anzeige", "a1-read-reise"])
        for (passageID, questionIDs) in l17Reading {
            let unit = ExamA1Catalog.units.first { $0.id == passageID }
            XCTAssertEqual(questionIDs, unit?.exercises.map(\.id),
                           "group for \(passageID) must carry exactly its unit's questions")
        }

        // Checkpoint: the two form questions share exactly one group carrying the passage.
        let checkpoint = ExamCampaignCatalog.allCheckpoints[0]
        let checkpointList = ExamCampaignCatalog.checkpointExercises(checkpoint)
        let groups = ExerciseGrouping.groups(for: checkpointList)
        XCTAssertEqual(groups.flatMap(\.exercises).map(\.id), checkpointList.map(\.id))
        let formularGroups = groups.filter { $0.passage?.id == "a1-read-formular" }
        XCTAssertEqual(formularGroups.count, 1)
        XCTAssertEqual(formularGroups.first?.exercises.map(\.id),
                       ["a1-read-formular-e1", "a1-read-formular-e4"])

        // Every reading question in every lesson resolves to its own passage.
        for lesson in ExamCampaignCatalog.allLessons {
            for passage in lesson.readingPassages {
                for question in passage.questions {
                    XCTAssertEqual(ExamCampaignCatalog.passageSourceByExerciseID[question.id]?.id, passage.id,
                                   "question \(question.id) lost its passage \(passage.id) in \(lesson.id)")
                }
            }
        }
    }

    func testExerciseGroupingSplitsNonConsecutivePassageQuestions() {
        // Synthetic A-B-A: the same passage's questions separated by another exercise must
        // form two groups, each carrying the source (the split-then-reopen branch).
        let formular = ExamA1Catalog.units.first { $0.id == "a1-read-formular" }!
        let sein = ExamA1Catalog.units.first { $0.id == "a1-gram-sein-haben" }!
        let input = [formular.exercises[0], sein.exercises[0], formular.exercises[1]]
        let groups = ExerciseGrouping.groups(for: input)
        XCTAssertEqual(groups.count, 3)
        XCTAssertEqual(groups.map { $0.passage?.id }, ["a1-read-formular", nil, "a1-read-formular"])
        XCTAssertEqual(groups.flatMap(\.exercises).map(\.id), input.map(\.id), "no loss, no reorder")
    }

    func testResolveExercisesReportsUnknownIDsInsteadOfDroppingThem() {
        let result = ExamCampaignCatalog.resolveExercises(["does-not-exist-e1", "a1-gram-sein-haben-e1"])
        XCTAssertFalse(result.isComplete)
        XCTAssertEqual(result.unresolvedIDs, ["does-not-exist-e1"])
        XCTAssertEqual(result.exercises.map(\.id), ["a1-gram-sein-haben-e1"],
                       "resolvable IDs must survive next to the reported failure")
        for checkpoint in ExamCampaignCatalog.allCheckpoints {
            XCTAssertTrue(ExamCampaignCatalog.checkpointResolution(checkpoint).isComplete, checkpoint.id)
        }
        XCTAssertTrue(ExamCampaignCatalog.finalExamResolution(ExamCampaignCatalog.finalExam!).isComplete)
    }

    func testStarsIgnoreEvidenceForActivitiesTheLessonDoesNotHave() {
        // Discriminating case: a quiz that is not done may not be carried over the line by
        // spoke/wrote flags belonging to tasks the lesson does not even have.
        XCTAssertEqual(MissionStars.stars(correct: 0, totalExercises: 5, spoke: true, hasSpeakingTask: false,
                                          wrote: true, hasWritingTask: false), 0)
        XCTAssertEqual(MissionStars.stars(correct: 5, totalExercises: 5, spoke: true, hasSpeakingTask: false,
                                          wrote: true, hasWritingTask: false), 3)
        XCTAssertEqual(MissionStars.stars(correct: 0, totalExercises: 0, spoke: true, hasSpeakingTask: false,
                                          wrote: true, hasWritingTask: false), 0,
                       "flags without a matching task must not mint stars")
    }

    func testFinalGateBlocksOnEachProductiveRequirementIndependently() {
        let exam = ExamCampaignCatalog.finalExam!
        let total = exam.exerciseIDs.count
        let writingDone = Set(exam.writingLessonIDs)
        let speakingDone = Set(exam.speakingLessonIDs)
        XCTAssertFalse(MissionCompletion.canCompleteFinalExam(exam, correct: total, checkedCount: total,
                                                              isLessonComplete: { writingDone.contains($0) }),
                       "missing speaking lessons must block the finish")
        XCTAssertFalse(MissionCompletion.canCompleteFinalExam(exam, correct: total, checkedCount: total,
                                                              isLessonComplete: { speakingDone.contains($0) }),
                       "missing writing lessons must block the finish")
    }

    func testNoStaleMockExamClaimsInUserFacingCampaignText() {
        var texts: [String] = []
        for zone in ExamCampaignCatalog.zones {
            texts.append(zone.title)
            texts.append(zone.goal)
        }
        if let exam = ExamCampaignCatalog.finalExam {
            texts.append(exam.title)
            texts.append(exam.description)
        }
        for lesson in ExamCampaignCatalog.allLessons {
            texts.append(lesson.title)
            texts.append(lesson.goal)
            if let task = lesson.speaking {
                texts.append(task.missionLabel)
            }
        }
        for text in texts {
            let lowered = text.lowercased()
            XCTAssertFalse(lowered.contains("mock"), "stale mock claim in user-facing text: \(text)")
            XCTAssertFalse(lowered.contains("full exam"), "stale full-exam claim in user-facing text: \(text)")
        }
    }
}
