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
    /// 3 stars: everything correct and the speaking and writing tasks done.
    /// 2 stars: at least 60% correct.
    /// 1 star: at least 30% correct.
    static func stars(correct: Int, total: Int, spoke: Bool, wrote: Bool) -> Int {
        guard total > 0 else { return 0 }
        if correct >= total, spoke, wrote { return 3 }
        if correct * 10 >= total * 6 { return 2 }
        if correct * 10 >= total * 3 { return 1 }
        return 0
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

    static func exercise(id: String) -> ExamExercise? {
        allLessons
            .flatMap { $0.exercises + $0.readingExercises }
            .first { $0.id == id }
    }

    static func checkpointExercises(_ checkpoint: CampaignCheckpoint) -> [ExamExercise] {
        checkpoint.exerciseIDs.compactMap { exercise(id: $0) }
    }

    static func finalExamExercises(_ exam: CampaignFinalExam) -> [ExamExercise] {
        exam.exerciseIDs.compactMap { exercise(id: $0) }
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

        // Exercise IDs referenced by checkpoints and final exam must exist in the legacy catalog.
        let knownExerciseIDs = Set(ExamA1Catalog.units.flatMap { $0.exercises }.map(\.id))
        for checkpoint in ExamCampaignCatalog.allCheckpoints {
            for id in checkpoint.exerciseIDs where !knownExerciseIDs.contains(id) {
                issues.append(Issue(severity: "error", message: "checkpoint \(checkpoint.id) references unknown exercise \(id)"))
            }
            for id in checkpoint.speakingLessonIDs where ExamCampaignCatalog.lesson(id: id) == nil {
                issues.append(Issue(severity: "error", message: "checkpoint \(checkpoint.id) references unknown speaking lesson \(id)"))
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
            for id in exam.exerciseIDs where !knownExerciseIDs.contains(id) {
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
