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

        XCTAssertEqual(store.completedLessonCount, 2)
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
        XCTAssertEqual(reloaded.completedLessonCount, 1)
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
            XCTAssertEqual(store.completedLessonCount, 1)
            XCTAssertEqual(store.totalReviews, 3)
            XCTAssertNil(defaults.data(forKey: "learning.stats"))
        }
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
            XCTAssertEqual(alice.completedLessonCount, 1)
        }
        // A later user does not inherit it twice.
        withAuthUsername("bob") {
            let bob = LearningStatsStore(defaults: defaults)
            XCTAssertEqual(bob.completedLessonCount, 0)
        }
    }
}
