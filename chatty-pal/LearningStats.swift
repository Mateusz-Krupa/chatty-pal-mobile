import Foundation
import Observation

struct DayLog: Codable, Hashable {
    var messages: Int = 0
    var reviews: Int = 0
    var xp: Int = 0
}

struct LearningStatsData: Codable, Hashable {
    var activityDates: Set<String> = []
    var completedLessons: Set<String> = []
    var totalReviews: Int = 0
    var totalShadowing: Int = 0
    var xp: Int = 0
    var dayLog: [String: DayLog] = [:]
    var lastQuestRewardDay: String? = nil
    var messagesSent: Int = 0

    init(
        activityDates: Set<String> = [],
        completedLessons: Set<String> = [],
        totalReviews: Int = 0,
        totalShadowing: Int = 0,
        xp: Int = 0,
        dayLog: [String: DayLog] = [:],
        lastQuestRewardDay: String? = nil,
        messagesSent: Int = 0
    ) {
        self.activityDates = activityDates
        self.completedLessons = completedLessons
        self.totalReviews = totalReviews
        self.totalShadowing = totalShadowing
        self.xp = xp
        self.dayLog = dayLog
        self.lastQuestRewardDay = lastQuestRewardDay
        self.messagesSent = messagesSent
    }

    // Tolerant decode: pre-XP payloads lack the newer keys, and a crash here
    // would wipe the learner's legacy progress.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        activityDates = try c.decodeIfPresent(Set<String>.self, forKey: .activityDates) ?? []
        completedLessons = try c.decodeIfPresent(Set<String>.self, forKey: .completedLessons) ?? []
        totalReviews = try c.decodeIfPresent(Int.self, forKey: .totalReviews) ?? 0
        totalShadowing = try c.decodeIfPresent(Int.self, forKey: .totalShadowing) ?? 0
        xp = try c.decodeIfPresent(Int.self, forKey: .xp) ?? 0
        dayLog = try c.decodeIfPresent([String: DayLog].self, forKey: .dayLog) ?? [:]
        lastQuestRewardDay = try c.decodeIfPresent(String.self, forKey: .lastQuestRewardDay)
        messagesSent = try c.decodeIfPresent(Int.self, forKey: .messagesSent) ?? 0
    }
}

enum XPEvent {
    case message
    case review
    case lesson
    case shadowing
    case rolePlay

    var amount: Int {
        switch self {
        case .message: return 5
        case .review: return 25
        case .lesson: return 50
        case .shadowing: return 10
        case .rolePlay: return 100
        }
    }
}

struct WeeklyRecap: Hashable {
    var messages: Int = 0
    var reviews: Int = 0
    var xp: Int = 0
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

    var xp: Int {
        data.xp
    }

    // MARK: - XP / gamification

    static let dailyQuestXP = 50
    static let questBonusXP = 25
    static let xpPerLevel = 200

    var level: Int { 1 + data.xp / Self.xpPerLevel }
    var levelProgress: Double { Double(data.xp % Self.xpPerLevel) / Double(Self.xpPerLevel) }
    var questProgress: Int { min(data.dayLog[LearningStats.dayKey(Date())]?.xp ?? 0, Self.dailyQuestXP) }
    var questCompletedToday: Bool { questProgress >= Self.dailyQuestXP }

    func weeklyRecap(now: Date = Date(), calendar: Calendar = .current) -> WeeklyRecap {
        var recap = WeeklyRecap()
        for offset in 0..<7 {
            guard let day = calendar.date(byAdding: .day, value: -offset, to: calendar.startOfDay(for: now)) else { continue }
            let log = data.dayLog[LearningStats.dayKey(day, calendar: calendar)]
            recap.messages += log?.messages ?? 0
            recap.reviews += log?.reviews ?? 0
            recap.xp += log?.xp ?? 0
        }
        return recap
    }

    func award(_ event: XPEvent, now: Date = Date()) {
        let day = LearningStats.dayKey(now)
        data.xp += event.amount
        data.dayLog[day, default: DayLog()].xp += event.amount
        switch event {
        case .message:
            data.messagesSent += 1
            data.dayLog[day, default: DayLog()].messages += 1
        case .review:
            data.dayLog[day, default: DayLog()].reviews += 1
        default:
            break
        }
        data.activityDates.insert(day)
        applyQuestBonus(now: now)
        save()
    }

    private func applyQuestBonus(now: Date) {
        let day = LearningStats.dayKey(now)
        guard (data.dayLog[day]?.xp ?? 0) >= Self.dailyQuestXP, data.lastQuestRewardDay != day else { return }
        data.xp += Self.questBonusXP
        data.lastQuestRewardDay = day
    }

    // MARK: - Events

    func recordUserMessage(now: Date = Date()) {
        award(.message, now: now)
    }

    func recordLessonPractice(lessonID: String, now: Date = Date()) {
        data.completedLessons.insert(lessonID)
        award(.lesson, now: now)
    }

    func recordReviewGrade(now: Date = Date()) {
        data.totalReviews += 1
        award(.review, now: now)
    }

    func recordShadowingAttempt(now: Date = Date()) {
        data.totalShadowing += 1
        award(.shadowing, now: now)
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
