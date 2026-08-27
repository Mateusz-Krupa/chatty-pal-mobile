import Foundation
import Combine

struct CampaignLessonProgress: Codable, Hashable {
    var stars: Int
    var correctCount: Int
    var exerciseCount: Int
    var completedSpeaking: Bool
    var completedWriting: Bool
    var completedAt: Date

    init(stars: Int = 0, correctCount: Int = 0, exerciseCount: Int = 0,
         completedSpeaking: Bool = false, completedWriting: Bool = false,
         completedAt: Date = .now) {
        self.stars = stars
        self.correctCount = correctCount
        self.exerciseCount = exerciseCount
        self.completedSpeaking = completedSpeaking
        self.completedWriting = completedWriting
        self.completedAt = completedAt
    }
}

final class ExamCampaignProgress: ObservableObject {
    static let shared = ExamCampaignProgress()

    private static let stateKey = "exam.a1.campaign.v1"
    static let legacyCompletedKey = "exam.a1.completed"

    private struct State: Codable {
        var version: Int
        var lessons: [String: CampaignLessonProgress]
    }

    @Published private(set) var lessons: [String: CampaignLessonProgress] = [:]
    @Published private(set) var legacyCompleted: Set<String> = []

    private let defaults: UserDefaults
    private var loaded = false

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        load()
    }

    // MARK: - Reading state

    func progress(for lessonID: String) -> CampaignLessonProgress? {
        lessons[lessonID]
    }

    func isComplete(_ lessonID: String) -> Bool {
        lessons[lessonID] != nil
    }

    func bestStars(_ lessonID: String) -> Int {
        lessons[lessonID]?.stars ?? 0
    }

    func isLegacyComplete(_ unitID: String) -> Bool {
        legacyCompleted.contains(unitID)
    }

    func completedCount(in zone: CampaignZone) -> Int {
        zone.lessons.filter { isComplete($0.id) }.count
    }

    // MARK: - Unlock rules

    func isLessonUnlocked(_ lesson: CampaignLesson) -> Bool {
        let prerequisites = ExamCampaignCatalog.prerequisites(for: lesson)
        return prerequisites.allSatisfy { isComplete($0.id) }
    }

    func isCheckpointUnlocked(_ checkpoint: CampaignCheckpoint) -> Bool {
        let prerequisites = ExamCampaignCatalog.prerequisites(for: checkpoint)
        return prerequisites.allSatisfy { isComplete($0.id) }
    }

    func isFinalExamUnlocked() -> Bool {
        guard let exam = ExamCampaignCatalog.finalExam else { return false }
        let prerequisites = ExamCampaignCatalog.prerequisites(for: exam)
        return prerequisites.allSatisfy { isComplete($0.id) }
    }

    /// The first node in campaign order that is available but not yet complete.
    func currentNode() -> (zone: CampaignZone, node: CampaignNode)? {
        for entry in ExamCampaignCatalog.orderedNodes {
            switch entry.node {
            case .lesson(let lesson):
                if isLessonUnlocked(lesson), !isComplete(lesson.id) {
                    return (entry.zone, entry.node)
                }
            case .checkpoint(let checkpoint):
                if isCheckpointUnlocked(checkpoint), !isComplete(checkpoint.id) {
                    return (entry.zone, entry.node)
                }
            case .finalExam(let exam):
                if isFinalExamUnlocked(), !isComplete(exam.id) {
                    return (entry.zone, entry.node)
                }
            }
        }
        return nil
    }

    // MARK: - Recording

    /// Records a mission result, keeping the best result seen so far.
    func record(_ result: MissionResult, for lessonID: String) {
        let existing = lessons[lessonID]
        let progress = CampaignLessonProgress(
            stars: max(existing?.stars ?? 0, result.stars),
            correctCount: max(existing?.correctCount ?? 0, result.correctCount),
            exerciseCount: max(existing?.exerciseCount ?? 0, result.exerciseCount),
            completedSpeaking: (existing?.completedSpeaking ?? false) || result.completedSpeaking,
            completedWriting: (existing?.completedWriting ?? false) || result.completedWriting,
            completedAt: existing?.completedAt ?? .now
        )
        lessons[lessonID] = progress
        save()
    }

    /// Checkpoints have no stars; completion is recorded as a plain done flag.
    func recordCheckpointComplete(_ checkpointID: String) {
        guard lessons[checkpointID] == nil else { return }
        lessons[checkpointID] = CampaignLessonProgress(stars: 0, completedAt: .now)
        save()
    }

    func reset() {
        lessons = [:]
        save()
    }

    // MARK: - Persistence

    private func load() {
        guard !loaded else { return }
        loaded = true
        if let data = defaults.data(forKey: Self.stateKey),
           let state = try? JSONDecoder().decode(State.self, from: data),
           state.version == 1 {
            lessons = state.lessons
        }
        legacyCompleted = Set(defaults.stringArray(forKey: Self.legacyCompletedKey) ?? [])
        migrateLegacyProgress()
    }

    private func migrateLegacyProgress() {
        var changed = false
        for legacyID in legacyCompleted {
            guard let lesson = ExamCampaignCatalog.lesson(byLegacyID: legacyID),
                  lessons[lesson.id] == nil else { continue }
            lessons[lesson.id] = CampaignLessonProgress(stars: 1, completedAt: .distantPast)
            changed = true
        }
        if changed { save() }
    }

    private func save() {
        let state = State(version: 1, lessons: lessons)
        if let data = try? JSONEncoder().encode(state) {
            defaults.set(data, forKey: Self.stateKey)
        }
    }
}
