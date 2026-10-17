import XCTest
@testable import chatty_pal

final class LearningStatsTests: XCTestCase {
    private let calendar = Calendar.current

    private func day(_ offset: Int, from today: Date) -> String {
        let date = calendar.date(byAdding: .day, value: offset, to: calendar.startOfDay(for: today))!
        return LearningStats.dayKey(date, calendar: calendar)
    }

    func testConsecutiveDaysStreak() {
        let today = Date()
        let dates: Set<String> = [day(0, from: today), day(-1, from: today), day(-2, from: today)]
        XCTAssertEqual(LearningStats.streak(for: dates, today: today, calendar: calendar), 3)
    }

    func testGapResetsStreak() {
        let today = Date()
        let dates: Set<String> = [day(0, from: today), day(-1, from: today), day(-3, from: today)]
        XCTAssertEqual(LearningStats.streak(for: dates, today: today, calendar: calendar), 2)
    }

    func testMissingTodayKeepsStreak() {
        let today = Date()
        let dates: Set<String> = [day(-1, from: today), day(-2, from: today)]
        XCTAssertEqual(LearningStats.streak(for: dates, today: today, calendar: calendar), 2)
    }

    func testEmptyDatesGiveZeroStreak() {
        XCTAssertEqual(LearningStats.streak(for: [], today: Date(), calendar: calendar), 0)
    }

    @MainActor
    func testRecordLessonPracticeIsIdempotentAndCountsOnce() {
        let defaults = UserDefaults(suiteName: #function)!
        defaults.removePersistentDomain(forName: #function)
        let store = LearningStatsStore(defaults: defaults)

        store.recordLessonPractice(lessonID: "de-a1-greetings")
        store.recordLessonPractice(lessonID: "de-a1-greetings")
        store.recordLessonPractice(lessonID: "de-a1-shopping")

        XCTAssertEqual(store.completedLessonCount(knownLessonIDs: ["de-a1-greetings", "de-a1-shopping"]), 2)
        XCTAssertGreaterThanOrEqual(store.streak, 1)
    }

    @MainActor
    func testTotalsIncrement() {
        let defaults = UserDefaults(suiteName: #function)!
        defaults.removePersistentDomain(forName: #function)
        let store = LearningStatsStore(defaults: defaults)

        store.recordReviewGrade()
        store.recordReviewGrade()
        store.recordShadowingAttempt()

        XCTAssertEqual(store.totalReviews, 2)
        XCTAssertEqual(store.totalShadowing, 1)
    }

    @MainActor
    func testPersistenceRoundTrip() {
        let defaults = UserDefaults(suiteName: #function)!
        defaults.removePersistentDomain(forName: #function)

        let first = LearningStatsStore(defaults: defaults)
        first.recordLessonPractice(lessonID: "de-a1-restaurant")
        first.recordReviewGrade()

        let reloaded = LearningStatsStore(defaults: defaults)
        XCTAssertEqual(reloaded.completedLessonCount(knownLessonIDs: ["de-a1-restaurant"]), 1)
        XCTAssertEqual(reloaded.totalReviews, 1)
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
    func testLegacyStatsMigratedToScopedKey() {
        let defaults = UserDefaults(suiteName: #function)!
        defaults.removePersistentDomain(forName: #function)
        let legacy = LearningStatsData(activityDates: [], completedLessons: ["de-a1-restaurant"], totalReviews: 3, totalShadowing: 1)
        defaults.set(try! JSONEncoder().encode(legacy), forKey: "learning.stats")

        // Legacy data migrates to the signed-in user on first load.
        withAuthUsername("alice") {
            let store = LearningStatsStore(defaults: defaults)
            XCTAssertEqual(store.completedLessonCount(knownLessonIDs: ["de-a1-restaurant"]), 1)
            XCTAssertEqual(store.totalReviews, 3)
            XCTAssertNil(defaults.data(forKey: "learning.stats"))
        }
    }

    @MainActor
    func testCompletedLessonCountIgnoresRetiredLessonIDs() {
        let defaults = UserDefaults(suiteName: #function)!
        defaults.removePersistentDomain(forName: #function)
        let store = LearningStatsStore(defaults: defaults)

        // The shipping catalog JSON must be loadable in the test host; the first shipping lesson id is its first lesson.
        XCTAssertFalse(MobileLearningCatalog.germanLessons.isEmpty)
        store.recordLessonPractice(lessonID: MobileLearningCatalog.germanLessons[0].id)
        store.recordLessonPractice(lessonID: "de-g-99")   // retired id, not in the active catalog

        XCTAssertEqual(store.completedLessonCount, 1)
    }

    @MainActor
    func testAccountsAreIsolated() {
        let defaults = UserDefaults(suiteName: #function)!
        defaults.removePersistentDomain(forName: #function)

        withAuthUsername("alice") {
            let alice = LearningStatsStore(defaults: defaults)
            alice.recordReviewGrade()
        }
        withAuthUsername("bob") {
            let bob = LearningStatsStore(defaults: defaults)
            XCTAssertEqual(bob.totalReviews, 0)
        }
        withAuthUsername("alice") {
            let alice = LearningStatsStore(defaults: defaults)
            XCTAssertEqual(alice.totalReviews, 1)
        }
    }

    @MainActor
    func testGuestProgressCarriedToUserOnLogin() {
        let defaults = UserDefaults(suiteName: #function)!
        defaults.removePersistentDomain(forName: #function)

        withAuthUsername(nil) {
            let guest = LearningStatsStore(defaults: defaults)
            guest.recordLessonPractice(lessonID: "de-a1-greetings")
        }
        withAuthUsername("alice") {
            let alice = LearningStatsStore(defaults: defaults)
            XCTAssertEqual(alice.completedLessonCount(knownLessonIDs: ["de-a1-greetings"]), 1)
        }
        // A later user does not inherit it twice.
        withAuthUsername("bob") {
            let bob = LearningStatsStore(defaults: defaults)
            XCTAssertEqual(bob.completedLessonCount(knownLessonIDs: ["de-a1-greetings"]), 0)
        }
    }

    // MARK: - XP / levels / quests

    @MainActor
    func testXPLevelCurve() {
        let defaults = UserDefaults(suiteName: #function)!
        defaults.removePersistentDomain(forName: #function)
        let store = LearningStatsStore(defaults: defaults)
        XCTAssertEqual(store.level, 1)
        XCTAssertEqual(store.levelProgress, 0)

        store.award(.lesson)     // 50 XP + 25 quest bonus = 75
        XCTAssertEqual(store.xp, 75)
        store.award(.rolePlay)   // +100 = 175
        store.award(.review)     // +25 = 200
        XCTAssertEqual(store.level, 2)
        XCTAssertEqual(store.levelProgress, 0, accuracy: 0.0001)
        store.award(.shadowing)  // +10 = 210
        XCTAssertEqual(store.level, 2)
        XCTAssertEqual(store.levelProgress, 0.05, accuracy: 0.0001)
    }

    @MainActor
    func testDailyQuestBonusAwardedOncePerDay() {
        let defaults = UserDefaults(suiteName: #function)!
        defaults.removePersistentDomain(forName: #function)
        let store = LearningStatsStore(defaults: defaults)

        store.award(.review) // 25 XP
        XCTAssertEqual(store.questProgress, 25)
        XCTAssertFalse(store.questCompletedToday)
        store.award(.review) // 50 XP -> quest bonus
        XCTAssertEqual(store.questProgress, 50)
        XCTAssertTrue(store.questCompletedToday)
        let xpBefore = store.xp
        store.award(.message) // +5 XP, no second bonus
        XCTAssertEqual(store.xp, xpBefore + 5)
    }

    @MainActor
    func testQuestBonusRewardsNextDay() {
        let defaults = UserDefaults(suiteName: #function)!
        defaults.removePersistentDomain(forName: #function)
        let store = LearningStatsStore(defaults: defaults)
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        store.award(.review, now: yesterday)
        store.award(.review, now: yesterday) // 50 yesterday -> bonus
        store.award(.review, now: today)
        store.award(.review, now: today)     // 50 today -> bonus again
        XCTAssertEqual(store.xp, 150)
    }

    @MainActor
    func testWeeklyRecapWindow() {
        let defaults = UserDefaults(suiteName: #function)!
        defaults.removePersistentDomain(forName: #function)
        let store = LearningStatsStore(defaults: defaults)
        let today = Date()
        let inside = calendar.date(byAdding: .day, value: -6, to: today)!
        let outside = calendar.date(byAdding: .day, value: -8, to: today)!

        store.award(.message, now: today)
        store.award(.message, now: inside)
        store.award(.message, now: outside)

        let recap = store.weeklyRecap(now: today, calendar: calendar)
        XCTAssertEqual(recap.messages, 2)
        XCTAssertEqual(recap.xp, 10)
    }

    func testPreXPDataDecodesWithDefaults() throws {
        let legacy = """
        {"activityDates":["2026-01-01"],"completedLessons":["de-a1-greetings"],"totalReviews":2,"totalShadowing":0}
        """
        let decoded = try JSONDecoder().decode(LearningStatsData.self, from: legacy.data(using: .utf8)!)
        XCTAssertEqual(decoded.totalReviews, 2)
        XCTAssertEqual(decoded.xp, 0)
        XCTAssertNil(decoded.lastQuestRewardDay)
        XCTAssertTrue(decoded.dayLog.isEmpty)
    }
}
