## Why

In lesson l20 ("Lesen: E-Mail, Museum, Stellenanzeige") the learner answers 15 reading questions, but only the E-Mail text is shown. Questions 6-15 reference the museum notice and the job advertisement, which are never displayed — the learner cannot answer them. The cause is structural: `CampaignLesson` stores a single `readingText` plus a flat `readingQuestions` list, so passages and their questions are not bound together.

## What Changes

- New value type `ReadingPassage` (id, title, text, questions) that binds a reading text to its own questions.
- **BREAKING (internal model):** `CampaignLesson.readingText`/`readingQuestions` are replaced by `readingPassages: [ReadingPassage]`.
- Content (configuration) for l4, l17, l20 is rewritten to declare passages; l20 now declares three passages so all three texts are shown with their questions.
- The mission "Exam task" step renders each passage's text followed by its questions.
- Validation gains a check: every reading passage must have non-empty text and at least one question.

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `exam-campaign`: reading content is declared as passages, each bound to its questions; a lesson's exam task shows every passage the learner must answer against.

## Impact

- iOS model: `chatty-pal/ExamCampaign.swift` (`ReadingPassage`, `CampaignLesson`, `MissionPlan`, catalog helpers)
- iOS content: `chatty-pal/ExamCampaignContent.swift` (l4, l17, l20)
- iOS UI: `chatty-pal/ExamCampaignViews.swift` (exam task step, mission exercise list, final-exam replay mapping)
- Tests: `chatty-palTests/ExamCampaignTests.swift` (content coverage assertion)
- No server changes, no API changes, no dependencies.
