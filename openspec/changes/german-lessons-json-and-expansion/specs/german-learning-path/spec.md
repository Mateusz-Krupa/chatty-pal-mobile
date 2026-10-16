## MODIFIED Requirements

### Requirement: Grammar-progression German lesson path

The German learning catalog SHALL present a sequential grammar-progression path of exactly 36 lessons at approximately reference-book-step granularity, following the split map defined in the change design, from A1 sounds to an A2 life-story review, replacing the 14-lesson compression. Each lesson SHALL keep the existing format: intro, exactly 3 can-do goals, 7-11 target phrases, 5-6 vocabulary items with usage notes, a 5-8 line dialogue with exactly two strictly alternating speakers, and a practice prompt scoped to the lesson's structure. Lesson ids SHALL be `de-s-01`..`de-s-36` (fresh namespace, never reused from a previous catalog).

#### Scenario: Learner opens the German lesson path

- **WHEN** the learner opens the German lesson path screen
- **THEN** 36 lessons are listed in grammar-progression order with A1 lessons (1-22) before A2 lessons (23-36)
- **AND** the lesson count badge reflects the loaded content

#### Scenario: Lesson opens word review

- **WHEN** the learner starts practice on any lesson
- **THEN** that lesson's vocabulary and phrases are added to the word-review store under source `lesson:de-s-NN` with no code changes to the review pipeline

#### Scenario: Legacy completion ids do not inflate progress

- **WHEN** a learner has stored completions for retired `de-g-*` ids and opens the stats after the catalog update
- **THEN** completedLessonCount counts only ids present in the active catalog

### Requirement: Independently authored content

All text in the German lesson path SHALL be newly authored original content. The copyrightable text of any third-party book (including "Easy German Step-by-Step") SHALL NOT be copied or paraphrased; only uncopyrightable grammar facts, conjugation paradigms, and the conventional A1→A2 topic sequence may inform the path.

#### Scenario: Dialogue uses only original sentences

- **WHEN** any lesson dialogue or example sentence is inspected
- **THEN** it is an original sentence written for this app, using vocabulary appropriate to the cumulative lessons up to that point

## ADDED Requirements

### Requirement: Lessons are delivered as bundled JSON

German lesson content SHALL live in a versioned `german-lessons.json` resource shipped in the app bundle and decoded into the existing `LearningLesson` model at load time; no lesson prose SHALL remain hard-coded in Swift. A unit test SHALL load the file from the **built app target bundle** and assert schema invariants (schemaVersion 1, sequential ids `de-s-01`..`de-s-36`, exactly 3 goals, 5-6 vocabulary items, 5-8 dialogue lines with two alternating speakers, A1 before A2), so malformed content or a broken resource build phase cannot ship silently.

#### Scenario: Content update without lesson code changes

- **WHEN** lesson text is added or edited only in `german-lessons.json`
- **THEN** the app presents the updated path with no changes to Swift view, word-review, or stats code

#### Scenario: Missing or invalid bundle content in release

- **WHEN** the shipped `german-lessons.json` is absent, corrupt, or declares an unsupported schemaVersion in a release build
- **THEN** the app logs the failure and presents an empty lesson catalog instead of crashing

#### Scenario: Invalid content during development

- **WHEN** the same failure occurs in a Debug build
- **THEN** the loader asserts so breakage is impossible to miss during development

### Requirement: Conversations play with per-lesson voice ids

Conversation playback SHALL source speaker voices from optional `voiceA`/`voiceB` fields on each lesson (either both present or both absent) instead of hard-coded language checks: even-index lines use voiceA, odd-index lines use voiceB. The lesson content test SHALL enforce strict speaker alternation so voice assignment follows speaker identity. Lessons without voice fields play all lines with the lesson's default voice; a failed alternate-voice synthesis falls back to the lesson voice and the sequence continues.

#### Scenario: German two-voice dialogue

- **WHEN** a lesson with `voiceA: "Vicki"` and `voiceB: "Daniel"` plays its conversation
- **THEN** the first speaker's lines use Vicki and the second speaker's lines use Daniel throughout, regardless of line order

#### Scenario: Alternate voice unavailable

- **WHEN** synthesis of a line with the assigned voice fails
- **THEN** that line is retried with the lesson's default voice and playback continues
