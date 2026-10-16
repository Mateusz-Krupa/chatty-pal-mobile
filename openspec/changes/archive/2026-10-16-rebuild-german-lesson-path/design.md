# Design: German grammar-progression path

## Content provenance rule (hard constraint)

The book PDF is used ONLY as a reference for topic list and ordering. No sentence, explanation, drills list, or dialogue from the book is copied or paraphrased. All German and English text in the catalog is newly written for this app. Standard grammar facts (conjugation tables, case rules, common vocabulary like `das Brot`) are uncopyrightable and are stated in our own words.

## Sequence (14 lessons, mirrors the standard A1→A2 grammar syllabus)

| # | id | Focus | Can-do goal |
|---|----|-------|-------------|
| 1 | de-g-01 | Sounds, spelling, cognates | Read any German word aloud |
| 2 | de-g-02 | Gender der/die/das + `heißen` | Name things correctly, introduce yourself |
| 3 | de-g-03 | `sein`, personal pronouns, demonstratives | Say who/what something is |
| 4 | de-g-04 | `haben`, `ein`/`kein`, `mein`/`dein` | Talk about what you have |
| 5 | de-g-05 | Regular present tense, verb-second order | Describe routines and actions |
| 6 | de-g-06 | Stem-vowel changes (fahren/sprechen/lesen), `werden` | Speak about changes and plans |
| 7 | de-g-07 | Accusative: direct objects, `den`, `für`/`ohne` | Say what you are doing to what |
| 8 | de-g-08 | Simple past of regular verbs + w-questions | Tell what happened, ask open questions |
| 9 | de-g-09 | Irregular past (ging/sah…), plurals, numbers/age | Tell a short story about the past |
| 10 | de-g-10 | Dative: `dem/der/den`, dative verbs, `mit`/`zu`/`nach` | Talk about helping, liking, giving |
| 11 | de-g-11 | `können`/`müssen` + `und/aber/oder` | Express ability, necessity, connect ideas |
| 12 | de-g-12 | Present perfect: `haben` + ge- participle | Talk about the past the way Germans speak |
| 13 | de-g-13 | Adjective endings + separable verbs | Describe things correctly, use anfangen/einkaufen |
| 14 | de-g-14 | Irregular participles, sein-perfect, review | Tell your full life story in past tense |

A1 = lessons 1–7, A2 = 8–14 (matches the book's own difficulty arc).

## Lesson template (maps 1:1 onto existing `LearningLesson`)

- `intro`: 2–3 sentences, why this structure matters + one memory trick.
- `goals`: 3 practical can-do statements.
- `phrases` (7–11): the target structures in the learner's mouth, shortest useful form.
- `vocabulary` (5-6): high-frequency words chosen so they *exercise* the lesson's grammar (e.g. gender lesson gets one clear der/die/das example each).
- `conversation` (5–6 lines): an original mini-dialogue between Lena (local) and Jonas (learner) that only uses vocabulary ≤ current lesson + previously taught material (cumulative comprehensibility — the key improvement over the book's isolated drills).
- `practicePrompt`: instructs the AI partner to stay inside the lesson's structure and correct only violations of it.

## Code shape

Two file changes: (1) replace the array in `MobileLearningCatalog.germanLessons` (LearningCatalog.swift) - static data, no new types, no persistence changes, word-review auto-collects vocabulary via existing `addLesson`; (2) extend `LearningLessonDetailView` (LearningViews.swift) with Play-all conversation playback: run-token cancellation (`conversationRunID`, `itemRunID`), sequential Polly synthesis with per-line voice (`Vicki`/`Daniel`, fallback to the lesson voice), `playingText` drives the active-bubble indicator, and single-clip playback polls `AVAudioPlayer.isPlaying` so Stop never leaves a suspended continuation.

## Risk: content volume

14 rich lessons ≈ 600 lines of Swift data. Mitigation: authored in one pass per lesson, German checked against A1/A2 wordlists, build verifies compilation; tests only rely on `germanLessons[0]` shape which is preserved.
