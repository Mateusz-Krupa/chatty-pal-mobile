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
}
