# Design — learning-today-stats

## Model

`LearningStatsData` (Codable, UserDefaults key `learning.stats`):
- `activityDates: Set<String>` — "yyyy-MM-dd" of any recorded activity.
- `completedLessons: Set<String>` — lesson IDs practiced at least once.
- `totalReviews: Int` — grades given in Word Review.
- `totalShadowing: Int` — shadowing attempts finished.

`LearningStatsStore` — `@MainActor final class`, `.shared` singleton, same shape as `WordReviewStore`:
- `recordLessonPractice(lessonID:)` — inserts into `completedLessons` + marks today active.
- `recordReviewGrade()` — `totalReviews += 1` + marks today active.
- `recordShadowingAttempt()` — `totalShadowing += 1` + marks today active.
- `var streak: Int`, `var dueWordCount: Int` (delegates to `WordReviewStore.shared.dueCount`), `var completedLessonCount: Int`.
- Persistence: save on every mutation; load in init.

## Streak (pure)

```swift
static func streak(for dates: Set<String>, today: Date) -> Int
```
- Build a `Set<DateComponents day>` from `dates` (same calendar as storage: `.current`).
- Start at `today`; if today's day is not in the set, start at yesterday (a not-yet-studied today doesn't break the streak).
- Count consecutive days present, walking backward.

## UI — TodayCard

Compact card in `ChatView` between `headerView` and `ChatMessageList`:
- Row 1: flame + "N-day streak" (or "No streak yet — start now!"), spacer, due badge "N due" when > 0.
- Row 2: two stat chips — "X lessons" (book icon), "Y reviews" (checkmark icon).
- Tapping the card (or the due badge) pushes `MenuDestination.wordReview` via the existing `navigationPath`.
- Reads `LearningStatsStore.shared` + `WordReviewStore.shared`; refreshes on `onAppear`/`scenePhase`.

## Hooks

- `LearningLessonDetailView`: "Practice in Chatty Pal" button → `LearningStatsStore.shared.recordLessonPractice(lesson.id)`.
- `ShadowingPhraseRow.finishRecording()` → `recordShadowingAttempt()`.
- `WordReviewView.grade(_:)` → `recordReviewGrade()`.

## Testing

`LearningStatsTests`: streak on consecutive days, streak gap resets, missing-today-keeps-streak (yesterday active), empty set = 0, lesson dedup, totals increment, persistence round-trip (inject UserDefaults suite).
