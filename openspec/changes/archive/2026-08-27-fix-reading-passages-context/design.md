# Design — fix-reading-passages-context

## Audit result

Every exercise in the catalog was checked for external context dependencies:

- Grammar / vocabulary / phrase units: all questions are self-contained (context is inside the question or the option list). The unit's `text` is an explanation shown in the Grammar step, not a passage the questions depend on.
- Listening units: every `listening` exercise carries its own `spokenText`; the card already renders a "Play audio" button. No missing context.
- Reading units: questions reference a passage. The lesson model only supports ONE passage (`readingText`) plus a flat question list. **l20 mixes three passages (mail, museum, stellenanzeige) and only shows the mail text.** l4 and l17 each use a single passage and work correctly.

So the fix is a model/content fix, not a per-lesson patch.

## Model

```swift
struct ReadingPassage: Identifiable, Hashable {
    let id: String        // source unit id (a1-read-mail, ...)
    let title: String     // learner-facing label (E-Mail, Museum, Stellenanzeige)
    let text: String
    let questions: [ExamExercise]
}
```

`CampaignLesson` drops `readingText`/`readingQuestions` and gains:

```swift
let readingPassages: [ReadingPassage]
```

with a convenience used across the app:

```swift
var readingExercises: [ExamExercise] { readingPassages.flatMap(\.questions) }
var hasReadingTask: Bool { !readingPassages.isEmpty }
```

## Configuration (content file)

A builder turns a legacy reading unit into a passage:

```swift
private static func passage(_ unitID: String, title: String? = nil) -> ReadingPassage?
```

Lessons become declarative:

- l4:  `readingPassages: [passage("a1-read-formular")]`
- l17: `readingPassages: [passage("a1-read-anzeige")]`
- l20: `readingPassages: [passage("a1-read-mail"), passage("a1-read-museum"), passage("a1-read-stellenanzeige")]`

No special-casing anywhere in the UI: the exam task step simply iterates `lesson.readingPassages`, rendering a titled text card followed by that passage's question cards.

## UI

The `.examTask` step becomes:

```
For each passage:
    card(title: passage.title) { Text(passage.text) }
    ForEach(passage.questions) { CampaignExerciseCard(...) }
```

The "Check answers" button and result counting continue to operate on `lesson.exercises + lesson.readingExercises`, so stars, the 80% complete gate, and the outcome screen are unchanged.

## Call-site migration (found by audit, all small)

- `MissionPlan`: `hasReadingTask` replaces the `readingText != nil || !readingQuestions.isEmpty` check.
- `ExamCampaignCatalog.exercise(id:)`: flat-map `readingExercises`.
- `ExamCampaignViews`: `allExercises`, exam task rendering, final-exam `replayLessons` mapping.
- `ExamCampaignTests.testContentCoversRequiredScope`: `hasReadingTask`.

## Validation

New structural rule: every `ReadingPassage` must have a non-empty `text` and at least one question; every question's `correctIndex` must be in range (already implied by existing exercise validation, now also covered for passage questions).

## Risks

- Model field removal is compile-time safe: all six call sites are in this repo and listed above.
- Star/gate math is unchanged (same exercise count per lesson).
- Legacy Mini-Examen (`ExamA1Catalog.buildMiniExamQuestions`) is untouched.
