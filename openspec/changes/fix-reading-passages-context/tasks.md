# Tasks — fix-reading-passages-context

## 1. Model

- [x] 1.1 Add `ReadingPassage` (id, title, text, questions) and replace `readingText`/`readingQuestions` on `CampaignLesson` with `readingPassages` + `readingExercises`/`hasReadingTask` conveniences
- [x] 1.2 Update `MissionPlan` (exam task step condition) and `ExamCampaignCatalog.exercise(id:)` to use the new fields
- [x] 1.3 Add validation: every passage has non-empty text and at least one question

## 2. Content

- [x] 2.1 Add `passage(_ unitID:)` builder in `ExamCampaignContent`
- [x] 2.2 Rewrite l4, l17 as single-passage lessons; l20 as three passages (mail, museum, stellenanzeige)

## 3. UI

- [x] 3.1 Exam task step renders each passage: titled text card, then its question cards
- [x] 3.2 Migrate remaining call sites (`allExercises`, final-exam `replayLessons`) to `readingExercises`

## 4. Verification

- [x] 4.1 Update `testContentCoversRequiredScope` (and any other failing test) for the new model
- [x] 4.2 Add a test: l20 exposes three passages whose question sets match the legacy units; every lesson's passage questions are all resolvable
- [x] 4.3 Build + full `chatty-palTests` suite green
