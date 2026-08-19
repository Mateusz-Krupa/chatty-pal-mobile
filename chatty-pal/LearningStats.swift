import Foundation
import Observation

struct LearningStatsData: Codable, Hashable {
    var activityDates: Set<String> = []
    var completedLessons: Set<String> = []
    var totalReviews: Int = 0
    var totalShadowing: Int = 0
}

enum LearningStats {
    static func dayKey(_ date: Date, calendar: Calendar = .current) -> String {
        calendar.startOfDay(for: date).formatted(.iso8601.year().month().day())
    }

    static func streak(for activityDates: Set<String>, today: Date, calendar: Calendar = .current) -> Int {
        var cursor = calendar.startOfDay(for: today)
        if !activityDates.contains(dayKey(cursor, calendar: calendar)) {
            cursor = calendar.date(byAdding: .day, value: -1, to: cursor)!
        }
        var count = 0
        while activityDates.contains(dayKey(cursor, calendar: calendar)) {
            count += 1
            cursor = calendar.date(byAdding: .day, value: -1, to: cursor)!
        }
        return count
    }
}

@MainActor
@Observable
final class LearningStatsStore {
    static let shared = LearningStatsStore()

    private(set) var data = LearningStatsData()

    private let defaults: UserDefaults
    private var scope: String

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.scope = DataScope.current
        self.data = Self.load(from: defaults, scope: self.scope)
    }

    // Reload after a login/logout switch so the store tracks the new account.
    func scopeDidChange() {
        scope = DataScope.current
        data = Self.load(from: defaults, scope: scope)
    }

    private var storageKey: String { "learning.stats.\(scope)" }

    var streak: Int {
        LearningStats.streak(for: data.activityDates, today: Date())
    }

    var completedLessonCount: Int {
        data.completedLessons.count
    }

    var totalReviews: Int {
        data.totalReviews
    }

    var totalShadowing: Int {
        data.totalShadowing
    }

    func recordLessonPractice(lessonID: String) {
        data.completedLessons.insert(lessonID)
        markTodayActive()
    }

    func recordReviewGrade() {
        data.totalReviews += 1
        markTodayActive()
    }

    func recordShadowingAttempt() {
        data.totalShadowing += 1
        markTodayActive()
    }

    private func markTodayActive() {
        data.activityDates.insert(LearningStats.dayKey(Date()))
        save()
    }

    private func save() {
        if let encoded = try? JSONEncoder().encode(data) {
            defaults.set(encoded, forKey: storageKey)
        }
    }

    private static func load(from defaults: UserDefaults, scope: String) -> LearningStatsData {
        let scopedKey = "learning.stats.\(scope)"
        if let data = defaults.data(forKey: scopedKey) {
            return decode(data)
        }
        // One-shot migrations: legacy unscoped key (app upgrade), then the
        // guest scope (carries pre-login progress to the signed-in user).
        let fallbacks = ["learning.stats", "learning.stats.guest"]
        for fallback in fallbacks where scope != "guest" {
            if let data = defaults.data(forKey: fallback) {
                defaults.set(data, forKey: scopedKey)
                defaults.removeObject(forKey: fallback)
                return decode(data)
            }
        }
        return LearningStatsData()
    }

    private static func decode(_ data: Data) -> LearningStatsData {
        (try? JSONDecoder().decode(LearningStatsData.self, from: data)) ?? LearningStatsData()
    }
}
