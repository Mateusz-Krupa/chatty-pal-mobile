import Foundation

// MARK: - Campaign models

struct CampaignZone: Identifiable, Hashable {
    let id: String
    let order: Int
    let title: String
    let goal: String
    let nodes: [CampaignNode]

    var lessons: [CampaignLesson] {
        nodes.compactMap { node in
            if case .lesson(let lesson) = node { return lesson }
            return nil
        }
    }

    var checkpoints: [CampaignCheckpoint] {
        nodes.compactMap { node in
            if case .checkpoint(let checkpoint) = node { return checkpoint }
            return nil
        }
    }
}

enum CampaignNode: Hashable, Identifiable {
    case lesson(CampaignLesson)
    case checkpoint(CampaignCheckpoint)
    case finalExam(CampaignFinalExam)

    var id: String {
        switch self {
        case .lesson(let lesson): return lesson.id
        case .checkpoint(let checkpoint): return checkpoint.id
        case .finalExam(let exam): return exam.id
        }
    }
}

struct ReadingPassage: Identifiable, Hashable {
    let id: String
    let title: String
    let text: String
    let questions: [ExamExercise]
}

struct CampaignLesson: Identifiable, Hashable {
    let id: String
    let zoneID: String
    let order: Int
    let title: String
    let goal: String
    let vocabulary: [ExamVocabularyItem]
    let grammarPoints: [CampaignGrammarPoint]
    let phrases: [ExamPhrase]
    let dialogue: [ExamDialogueLine]
    let exercises: [ExamExercise]
    let readingPassages: [ReadingPassage]
    let writingPrompt: String?
    let speaking: CampaignSpeakingTask?
    let legacyUnitID: String?
    let legacyUnitIDs: [String]

    var readingExercises: [ExamExercise] {
        readingPassages.flatMap(\.questions)
    }

    var hasReadingTask: Bool {
        !readingPassages.isEmpty
    }

    init(
        id: String,
        zoneID: String,
        order: Int,
        title: String,
        goal: String,
        vocabulary: [ExamVocabularyItem] = [],
        grammarPoints: [CampaignGrammarPoint] = [],
        phrases: [ExamPhrase] = [],
        dialogue: [ExamDialogueLine] = [],
        exercises: [ExamExercise] = [],
        readingPassages: [ReadingPassage] = [],
        writingPrompt: String? = nil,
        speaking: CampaignSpeakingTask? = nil,
        legacyUnitID: String? = nil,
        legacyUnitIDs: [String] = []
    ) {
        self.id = id
        self.zoneID = zoneID
        self.order = order
        self.title = title
        self.goal = goal
        self.vocabulary = vocabulary
        self.grammarPoints = grammarPoints
        self.phrases = phrases
        self.dialogue = dialogue
        self.exercises = exercises
        self.readingPassages = readingPassages
        self.writingPrompt = writingPrompt
        self.speaking = speaking
        self.legacyUnitID = legacyUnitID ?? legacyUnitIDs.first
        self.legacyUnitIDs = legacyUnitID.map { [$0] } ?? legacyUnitIDs
    }
}

struct CampaignGrammarPoint: Identifiable, Hashable {
    let id: String
    let title: String
    let explanation: String?
    let items: [ExamVocabularyItem]
}

struct CampaignSpeakingTask: Identifiable, Hashable {
    let id: String
    let missionLabel: String
    let stages: [CampaignSpeakingStage]
    let scenario: String
}

struct CampaignSpeakingStage: Identifiable, Hashable {
    let id: String
    let title: String
    let instruction: String
}

struct CampaignCheckpoint: Identifiable, Hashable {
    let id: String
    let zoneID: String
    let order: Int
    let title: String
    let description: String
    let exerciseIDs: [String]
    let speakingLessonIDs: [String]
}

struct CampaignFinalExam: Identifiable, Hashable {
    let id: String
    let title: String
    let description: String
    let requiredZoneIDs: [String]
    let exerciseIDs: [String]
    let writingLessonIDs: [String]
    let speakingLessonIDs: [String]
}

// MARK: - Mission steps

enum MissionStep: Hashable {
    case briefing
    case vocabulary
    case grammar
    case phrases
    case dialogue
    case exercises
    case examTask
    case speaking
    case writing
    case outcome
}

struct MissionPlan {
    let lesson: CampaignLesson
    let steps: [MissionStep]

    init(lesson: CampaignLesson) {
        self.lesson = lesson
        var steps: [MissionStep] = [.briefing]
        if !lesson.vocabulary.isEmpty { steps.append(.vocabulary) }
        if !lesson.grammarPoints.isEmpty { steps.append(.grammar) }
        if !lesson.phrases.isEmpty { steps.append(.phrases) }
        if !lesson.dialogue.isEmpty { steps.append(.dialogue) }
        if !lesson.exercises.isEmpty { steps.append(.exercises) }
        if lesson.hasReadingTask { steps.append(.examTask) }
        if lesson.writingPrompt != nil { steps.append(.writing) }
        if lesson.speaking != nil { steps.append(.speaking) }
        steps.append(.outcome)
        self.steps = steps
    }

    var requiresSpokenInteraction: Bool {
        lesson.speaking != nil
    }
}

// MARK: - Mastery

struct MissionResult: Hashable {
    var stars: Int
    var correctCount: Int
    var exerciseCount: Int
    var completedSpeaking: Bool
    var completedWriting: Bool

    init(stars: Int = 0, correctCount: Int = 0, exerciseCount: Int = 0,
         completedSpeaking: Bool = false, completedWriting: Bool = false) {
        self.stars = stars
        self.correctCount = correctCount
        self.exerciseCount = exerciseCount
        self.completedSpeaking = completedSpeaking
        self.completedWriting = completedWriting
    }
}

enum MissionStars {
    /// Honest stars: the denominator counts only activities actually present in the lesson.
    /// 3 stars: every exercise correct and every present productive task done.
    /// 2 stars: at least 60% of the present activities achieved.
    /// 1 star: at least 30% achieved.
    /// A lesson with no activities at all can never earn stars.
    static func stars(correct: Int, totalExercises: Int, spoke: Bool, hasSpeakingTask: Bool,
                      wrote: Bool, hasWritingTask: Bool) -> Int {
        let required = totalExercises + (hasSpeakingTask ? 1 : 0) + (hasWritingTask ? 1 : 0)
        guard required > 0 else { return 0 }
        // Evidence for an activity the lesson does not contain must not inflate the stars.
        let achieved = min(max(correct, 0), totalExercises)
            + ((hasSpeakingTask && spoke) ? 1 : 0)
            + ((hasWritingTask && wrote) ? 1 : 0)
        if achieved >= required { return 3 }
        if achieved * 10 >= required * 6 { return 2 }
        if achieved * 10 >= required * 3 { return 1 }
        return 0
    }
}

/// Completion rules outside SwiftUI: an activity counts only when there is evidence for it.
/// Merely walking through the screens must never complete a lesson, checkpoint or final test.
enum MissionCompletion {
    /// A lesson completes when every declared exercise was checked with at least 80% correct,
    /// and every present productive task (speaking/writing) has real evidence.
    static func canCompleteLesson(lesson: CampaignLesson, correct: Int, checkedCount: Int,
                                  spoke: Bool, wrote: Bool) -> Bool {
        let total = lesson.exercises.count + lesson.readingExercises.count
        let hasActivity = total > 0 || lesson.speaking != nil || lesson.writingPrompt != nil
        guard hasActivity else { return false }
        if total > 0 {
            guard checkedCount >= total else { return false }
            guard correct * 10 >= total * 8 else { return false }
        }
        if lesson.speaking != nil && !spoke { return false }
        if lesson.writingPrompt != nil && !wrote { return false }
        return true
    }

    /// A checkpoint passes only when every declared exercise was answered and checked
    /// (the declared list is the denominator), with at least 60% correct.
    static func canCompleteCheckpoint(_ checkpoint: CampaignCheckpoint, correct: Int, checkedCount: Int) -> Bool {
        let total = checkpoint.exerciseIDs.count
        guard total > 0, checkedCount >= total else { return false }
        return correct * 10 >= total * 6
    }

    /// The mixed practice test finishes only with all quiz questions answered and checked,
    /// at least 60% correct, and real completion records for its writing and speaking lessons.
    static func canCompleteFinalExam(_ exam: CampaignFinalExam, correct: Int, checkedCount: Int,
                                     isLessonComplete: (String) -> Bool) -> Bool {
        let total = exam.exerciseIDs.count
        guard total > 0, checkedCount >= total, correct * 10 >= total * 6 else { return false }
        guard exam.writingLessonIDs.allSatisfy(isLessonComplete) else { return false }
        guard exam.speakingLessonIDs.allSatisfy(isLessonComplete) else { return false }
        return true
    }
}

// MARK: - Exercise presentation groups

/// A render block: one reading passage with its own questions, or exercises without a
/// passage source. Views must render groups, never a flat exercise list, so a reading
/// question never appears without the text it is about (task 2.2).
struct ExerciseGroup: Hashable, Identifiable {
    let id: String
    let passage: ReadingPassage?
    let exercises: [ExamExercise]
}

enum ExerciseGrouping {
    /// Keeps catalog order; consecutive questions of the same passage form one group.
    static func groups(for exercises: [ExamExercise]) -> [ExerciseGroup] {
        var groups: [ExerciseGroup] = []
        var currentPassage: ReadingPassage?
        var current: [ExamExercise] = []
        func flush() {
            guard !current.isEmpty else { return }
            let id = (currentPassage?.id ?? "plain") + "-" + current[0].id
            groups.append(ExerciseGroup(id: id, passage: currentPassage, exercises: current))
            current = []
        }
        for exercise in exercises {
            let source = ExamCampaignCatalog.passageSourceByExerciseID[exercise.id]
            if source?.id != currentPassage?.id {
                flush()
                currentPassage = source
            }
            current.append(exercise)
        }
        flush()
        return groups
    }
}

// MARK: - Campaign catalog

enum ExamCampaignCatalog {
    static let zones: [CampaignZone] = ExamCampaignContent.zones

    static let allLessons: [CampaignLesson] = zones.flatMap { $0.lessons }
    static let allCheckpoints: [CampaignCheckpoint] = zones.flatMap { $0.checkpoints }
    static var finalExam: CampaignFinalExam? {
        zones.flatMap { $0.nodes }.compactMap { node in
            if case .finalExam(let exam) = node { return exam }
            return nil
        }.first
    }

    static func zone(id: String) -> CampaignZone? {
        zones.first { $0.id == id }
    }

    static func lesson(id: String) -> CampaignLesson? {
        allLessons.first { $0.id == id }
    }

    static func lesson(byLegacyID legacyID: String) -> CampaignLesson? {
        allLessons.first { $0.legacyUnitIDs.contains(legacyID) }
    }

    /// Single source of truth for exercise lookup: the shipped content catalog.
    /// Checkpoints and the final exam resolve through this index, so validation and
    /// runtime agree on exactly the same ID space (task 2.3).
    static let exerciseIndex: [String: ExamExercise] = {
        var index: [String: ExamExercise] = [:]
        for exercise in ExamA1Catalog.allExercises() {
            if index[exercise.id] == nil {
                index[exercise.id] = exercise
            }
        }
        return index
    }()

    static func exercise(id: String) -> ExamExercise? {
        exerciseIndex[id]
    }

    /// IDs that neither the content catalog nor the campaign lessons can resolve.
    static func unresolvedExerciseIDs(_ ids: [String]) -> [String] {
        ids.filter { exerciseIndex[$0] == nil }
    }

    /// The reading source each question belongs to, so every rendered question keeps
    /// its passage — in lessons, checkpoints and the practice test alike.
    static let passageSourceByExerciseID: [String: ReadingPassage] = {
        var index: [String: ReadingPassage] = [:]
        for lesson in allLessons {
            for passage in lesson.readingPassages {
                for question in passage.questions where index[question.id] == nil {
                    index[question.id] = passage
                }
            }
        }
        return index
    }()

    /// Resolves declared IDs and *reports* the missing ones instead of silently dropping them.
    /// Callers must surface `unresolvedIDs` as a content error and block completion.
    struct ExerciseResolution {
        let exercises: [ExamExercise]
        let unresolvedIDs: [String]
        var isComplete: Bool { unresolvedIDs.isEmpty }
    }

    static func resolveExercises(_ ids: [String]) -> ExerciseResolution {
        var exercises: [ExamExercise] = []
        var unresolved: [String] = []
        for id in ids {
            if let exercise = exerciseIndex[id] {
                exercises.append(exercise)
            } else {
                unresolved.append(id)
            }
        }
        return ExerciseResolution(exercises: exercises, unresolvedIDs: unresolved)
    }

    static func checkpointResolution(_ checkpoint: CampaignCheckpoint) -> ExerciseResolution {
        resolveExercises(checkpoint.exerciseIDs)
    }

    static func finalExamResolution(_ exam: CampaignFinalExam) -> ExerciseResolution {
        resolveExercises(exam.exerciseIDs)
    }

    static func checkpointExercises(_ checkpoint: CampaignCheckpoint) -> [ExamExercise] {
        checkpointResolution(checkpoint).exercises
    }

    static func finalExamExercises(_ exam: CampaignFinalExam) -> [ExamExercise] {
        finalExamResolution(exam).exercises
    }

// MARK: Ordering and unlock rules

    /// Flat, ordered list of all nodes across zones.
    static var orderedNodes: [(zone: CampaignZone, node: CampaignNode)] {
        zones.flatMap { zone in zone.nodes.map { (zone, $0) } }
    }

    /// Prerequisites for a lesson: every lesson ordered before it in the same zone.
    static func prerequisites(for lesson: CampaignLesson) -> [CampaignLesson] {
        guard let zone = zone(id: lesson.zoneID) else { return [] }
        return zone.lessons.filter { $0.order < lesson.order }
    }

    static func prerequisites(for checkpoint: CampaignCheckpoint) -> [CampaignLesson] {
        guard let zone = zone(id: checkpoint.zoneID) else { return [] }
        return zone.lessons.filter { $0.order < checkpoint.order }
    }

    static func prerequisites(for exam: CampaignFinalExam) -> [CampaignLesson] {
        let zoneIDs = Set(exam.requiredZoneIDs)
        return allLessons.filter { zoneIDs.contains($0.zoneID) }
    }
}

// MARK: - Validation

enum ExamCampaignValidation {
    struct Issue: CustomStringConvertible {
        let severity: String
        let message: String
        var description: String { "[\(severity)] \(message)" }
    }

    static func validate() -> [Issue] {
        var issues: [Issue] = []

        var lessonIDs = Set<String>()
        var nodeIDs = Set<String>()
        var checkpointIDs = Set<String>()
        for zone in ExamCampaignCatalog.zones {
            for node in zone.nodes {
                if nodeIDs.contains(node.id) {
                    issues.append(Issue(severity: "error", message: "duplicate node id \(node.id)"))
                }
                nodeIDs.insert(node.id)
                switch node {
                case .lesson(let lesson):
                    if lessonIDs.contains(lesson.id) {
                        issues.append(Issue(severity: "error", message: "duplicate lesson id \(lesson.id)"))
                    }
                    lessonIDs.insert(lesson.id)
                    if lesson.zoneID != zone.id {
                        issues.append(Issue(severity: "error", message: "lesson \(lesson.id) has zoneID \(lesson.zoneID) but sits in \(zone.id)"))
                    }
                case .checkpoint(let checkpoint):
                    if checkpointIDs.contains(checkpoint.id) {
                        issues.append(Issue(severity: "error", message: "duplicate checkpoint id \(checkpoint.id)"))
                    }
                    checkpointIDs.insert(checkpoint.id)
                    if checkpoint.zoneID != zone.id {
                        issues.append(Issue(severity: "error", message: "checkpoint \(checkpoint.id) has zoneID \(checkpoint.zoneID) but sits in \(zone.id)"))
                    }
                case .finalExam:
                    break
                }
            }
        }

        for zone in ExamCampaignCatalog.zones {
            var expected = 1
            for node in zone.nodes {
                if case .lesson(let lesson) = node {
                    if lesson.order != expected {
                        issues.append(Issue(severity: "error", message: "lesson \(lesson.id) has order \(lesson.order), expected \(expected) in zone \(zone.id)"))
                    }
                    expected += 1
                } else if case .checkpoint(let checkpoint) = node {
                    if checkpoint.order != expected {
                        issues.append(Issue(severity: "error", message: "checkpoint \(checkpoint.id) has order \(checkpoint.order), expected \(expected) in zone \(zone.id)"))
                    }
                    expected += 1
                }
            }
        }

        // Exercise IDs referenced by checkpoints and the final exam must resolve through the
        // same index the runtime uses — validation and gameplay can no longer disagree.
        for checkpoint in ExamCampaignCatalog.allCheckpoints {
            for id in ExamCampaignCatalog.unresolvedExerciseIDs(checkpoint.exerciseIDs) {
                issues.append(Issue(severity: "error", message: "checkpoint \(checkpoint.id) references unknown exercise \(id)"))
            }
            for id in checkpoint.speakingLessonIDs where ExamCampaignCatalog.lesson(id: id)?.speaking == nil {
                issues.append(Issue(severity: "error", message: "checkpoint \(checkpoint.id) references lesson \(id) without a speaking task"))
            }
        }

        // Every reading unit a lesson declares must actually be attached as a passage;
        // a silent drop (e.g. a builder bug) is an error, not an empty list.
        for lesson in ExamCampaignCatalog.allLessons {
            for unitID in lesson.legacyUnitIDs where unitID.hasPrefix("a1-read-") {
                if !lesson.readingPassages.contains(where: { $0.id == unitID }) {
                    issues.append(Issue(severity: "error", message: "lesson \(lesson.id) declares reading unit \(unitID) but attaches no passage for it"))
                }
            }
        }
        for lesson in ExamCampaignCatalog.allLessons {
            for passage in lesson.readingPassages {
                if passage.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    issues.append(Issue(severity: "error", message: "lesson \(lesson.id) passage \(passage.id) has no text"))
                }
                if passage.questions.isEmpty {
                    issues.append(Issue(severity: "error", message: "lesson \(lesson.id) passage \(passage.id) has no questions"))
                }
                for exercise in passage.questions {
                    if exercise.correctIndex >= exercise.options.count {
                        issues.append(Issue(severity: "error", message: "lesson \(lesson.id) passage \(passage.id) exercise \(exercise.id) has invalid correctIndex"))
                    }
                }
            }
        }
        if let exam = ExamCampaignCatalog.finalExam {
            for id in ExamCampaignCatalog.unresolvedExerciseIDs(exam.exerciseIDs) {
                issues.append(Issue(severity: "error", message: "final exam references unknown exercise \(id)"))
            }
            for id in exam.writingLessonIDs where ExamCampaignCatalog.lesson(id: id)?.writingPrompt == nil {
                issues.append(Issue(severity: "error", message: "final exam references lesson \(id) without a writing prompt"))
            }
            for id in exam.speakingLessonIDs where ExamCampaignCatalog.lesson(id: id)?.speaking == nil {
                issues.append(Issue(severity: "error", message: "final exam references lesson \(id) without a speaking task"))
            }
            for id in exam.requiredZoneIDs where ExamCampaignCatalog.zone(id: id) == nil {
                issues.append(Issue(severity: "error", message: "final exam requires unknown zone \(id)"))
            }
        } else {
            issues.append(Issue(severity: "error", message: "campaign has no final exam node"))
        }

        return issues
    }
}
