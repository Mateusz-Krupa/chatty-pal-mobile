# Tasks: rebuild-german-lesson-path

## Phase 1 — Author content

- [x] Task 1: Write lessons 1–7 (A1: sounds, gender, sein, haben/ein, present tense, irregular present + werden, accusative) in `LearningCatalog.swift`, replacing the old array
- [x] Task 2: Write lessons 8–14 (A2: regular past + questions, irregular past + plurals, dative, modals + conjunctions, regular perfect, adjective endings + separable verbs, irregular perfect + review)
- [x] Task 3: Self-review dialogues for cumulative comprehensibility (no untaught grammar, glossed new words)

## Phase 2 — Verify

- [x] Task 4: Xcode build succeeds (Debug, simulator, no signing)
- [x] Task 5: `chatty-palTests` pass (WordReviewTests uses `germanLessons[0]` shape)
- [x] Task 6: Confirm lesson count badge and list render order in `GermanLearningLessonListView` need no changes

## Phase 3 — Full book coverage + dialogue quality pass

- [x] Task 7: Add remaining book subtopics: sondern (L11), ordinal dates + gestorben (L14)
- [x] Task 8: Reviewer quality pass on all 14 dialogues (naturalness, sense, humor) and apply required fixes
- [x] Task 9: Implement Play-all two-voice conversation playback in LearningLessonDetailView (Polly voiceId Vicki/Daniel, sequential, active-line highlight, stop on navigate away)
- [x] Task 10: Build + tests after playback feature (re-run after review fixes)
- [x] Task 11: Re-review final diff with reviewer and require >= 4.5/5 (4.9/5.0)

## Phase 4 — Close out

- [x] Task 12: Commit on a feature branch with message following repo style
