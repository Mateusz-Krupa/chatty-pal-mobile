# Design — Learning word review (SRS)

## Context

Vocabulary is taught in two places (lessons, exam units) and never revisited. We add a Leitner-box review queue fed automatically by both, with a dedicated review screen.

## Model

```swift
struct ReviewWord: Codable, Hashable, Identifiable {
    let id: String       // normalized german, e.g. "der einkauf"
    let german: String
    let english: String
    let example: String?
    let source: String   // "lesson:<id>" | "exam:<unitId>"
    var box: Int         // 1...5
    var due: Date
}
```

## Scheduler (pure, testable)

`WordReviewScheduler` (static functions):

- Intervals by box: `[1: 10 min, 2: 1 day, 3: 3 days, 4: 7 days, 5: 14 days]`.
- New word: box 1, due now (immediately reviewable today).
- Grade `.again` → box 1, due now + 10 min.
- Grade `.good` → box + 1 (max 5), due now + interval[newBox].
- Grade `.easy` → box + 2 (max 5), due now + interval[newBox].
- `dueWords(words, now)`: `due <= now`, sorted by due.

Keeping the math in a pure enum makes it unit-testable with fixed dates.

## Store

`WordReviewStore` — `@MainActor @Observable`, singleton `shared`, persists `[ReviewWord]` as JSON in UserDefaults key `learning.wordReview`.

- `add(german:english:example:source:)`: id = normalized german (lowercased, whitespace-collapsed); skip if id exists (existing word keeps its schedule).
- `addWords(_ items:)` for bulk from content sources.
- `due(now:)`, `grade(wordID:grade:)` using the scheduler, `save()` on every mutation.
- `sessionLimit = 20`: a review session takes at most 20 due words (sorted, so the most overdue first).

## Collection hooks (automatic, no manual UI)

- `LearningMaterialsHomeView` lesson open / `startLearningPractice`: `WordReviewStore.shared.addLesson(lesson)` — vocabulary (german/meaning + example) and phrases (german/english).
- `ExamUnitDetailView` "Mark as complete": `WordReviewStore.shared.addExamUnit(unit)` — unit vocabulary only (phrases are already in lessons' wheelhouse; keep the queue small).

## UI

`WordReviewView` (pushed from menu, `.wordReview` destination):

- Header: "X words due" / "All caught up".
- Card: German word (+ example sentence, speaker button → `ExamTTS.speak`), tap to flip → English meaning; three buttons: Again (red), Good (accent), Easy (green).
- Progress: "n of session".
- End of session: summary ("You reviewed N words") + Done.
- Empty state: "Nothing due right now. New words arrive from your lessons and exam prep."

Menu: `MenuDestination.wordReview` in the Student section ("Word Review", `text.book.closed`), due-count badge shown via `MenuRowContent` extension (small capsule with the count when > 0).

## Files / pbxproj

New: `chatty-pal/WordReview.swift` (model + scheduler + store), `chatty-pal/WordReviewView.swift`, `chatty-palTests/WordReviewTests.swift`. pbxproj IDs `AA...37`–`AA...42` (3 build file + 3 file references).

## Risks / Trade-offs

- UserDefaults storage is fine at this scale (hundreds of words); migrate to a file only if it grows.
- Dedupe by German string: the same word from two sources stays one card (first source wins, schedule is shared) — desirable.
- 20-word session cap prevents a long backlog from becoming a wall; overdue words roll to the next session.

## Test Strategy

- Scheduler: new word due now; again/good/easy box + due math with fixed dates; box cap at 5; due filtering + ordering.
- Store: add dedupe, add bulk, grade updates persistence, round-trip load.
- Existing suites stay green.
