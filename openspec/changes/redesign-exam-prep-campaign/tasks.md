## 1. Campaign Foundation

- [x] 1.1 Audit the existing Exam A1 catalog and map every current unit to an ordered campaign lesson, supporting objective, or retired legacy ID.
- [x] 1.2 Define campaign, zone, lesson, checkpoint, mission-step, and mastery data models with unique IDs and fixed ordering.
- [x] 1.3 Add versioned local campaign progress that preserves and maps existing `ExamProgressModel` completion IDs.
- [x] 1.4 Add unit tests for campaign ordering, prerequisite unlocking, replay behavior, star state, and legacy-progress migration.

## 2. Exam Conversation Contract

- [x] 2.1 Define an explicit exam conversation request/response contract containing mode, lesson ID, task stage, learner message, bounded history, and optional mission-state metadata.
- [x] 2.2 Update the web bot endpoint to own exam-mode instructions and construct a single non-duplicated learner turn while preserving existing non-exam chat behavior.
- [x] 2.3 Update the iOS bot client and `ChatEngine` integration to use the exam conversation contract for campaign missions without regressing streaming, TTS, voice input, or interruption.
- [x] 2.4 Add backend request-contract tests that prevent duplicate latest learner messages and reject unsupported exam modes or task stages.
- [x] 2.5 Create deterministic exam conversation scenario fixtures for A1 German, role adherence, stage progression, response bounds, and English handling.

## 3. Campaign Content

- [x] 3.1 Define the six initial campaign zones, their can-do outcomes, checkpoints, and final mock-exam prerequisites from original Goethe A1-aligned material.
- [x] 3.2 Author the first complete campaign zone with ordered lessons, focused vocabulary and grammar support, guided exercises, and exam-style tasks.
- [x] 3.3 Author mission-specific speaking stages for the first zone and their expected completion conditions.
- [x] 3.4 Convert the remaining existing A1 vocabulary, grammar, reading, listening, speaking, and writing content into truthfully classified campaign lessons.
- [x] 3.5 Add original checkpoint and final mock-exam task sets that cover all four exam skills without claiming official scoring.
- [x] 3.6 Add catalog validation tests for unique identifiers, content coverage, truthful exam-skill classification, prerequisite validity, and required checkpoint availability.

## 4. Campaign Route Interface

- [x] 4.1 Replace the Exam Prep home section-card navigation with an ordered, game-inspired campaign route using the existing Chatty visual language.
- [x] 4.2 Render zone progress, current mission, available lessons, locked prerequisites, completed state, stars, checkpoints, and the final mock-exam state.
- [x] 4.3 Preserve access to replayable completed material and show a clear recommended next action after each state change.
- [x] 4.4 Validate the campaign route on narrow phone layouts, Dynamic Type, VoiceOver, and light/dark appearance where supported.

## 5. Mission Experience

- [x] 5.1 Build the reusable mission flow for briefing, can-do goal, preparation, guided exercise groups, exam-style task, contextual conversation, and outcome.
- [x] 5.2 Move vocabulary and grammar presentation out of the misleading `Lesen` section and into lesson preparation steps.
- [x] 5.3 Add lesson-scoped exercise sequencing, checking, retry behavior, result aggregation, and review recommendations.
- [x] 5.4 Integrate mission speaking steps with `TransientChatStore`, visible stage context, automatic examiner opening, and existing voice controls.
- [x] 5.5 Add the mission outcome UI with stars, strengths, review suggestions, replay, and next-mission actions.
- [x] 5.6 Add eligible completed-lesson vocabulary and phrases to `WordReviewStore` without resetting existing Leitner schedules.

## 6. Checkpoints And Final Assessment

- [x] 6.1 Implement checkpoint availability, retryable mixed exercise sessions, and outcome routing back to the campaign map.
- [x] 6.2 Replace the current random Mini-Examen with a gated final mock exam that reports results per exam skill and recommends lessons to replay.
- [x] 6.3 Ensure final mock results remain in-session only and are clearly distinguished from official Goethe exam results.

## 7. Validation And Release

- [ ] 7.1 Run the live-model exam scenario evaluation and review failures before enabling each supported mission mode.
- [x] 7.2 Extend iOS tests for the campaign flow, mission outcome, speaking lifecycle, word-review collection, and existing-chat regression behavior.
- [x] 7.3 Build the iOS project after each functional phase and run the mobile test suite after the campaign, mission, and assessment phases.
- [ ] 7.4 Verify the web bot endpoint tests (done — 46/46 jest) and manually test a full first-zone journey with text input, voice input, TTS, interruption, and offline/error states.
- [x] 7.5 Prepare a release checklist covering progress migration, accessibility, mobile visual polish, original-content provenance, and rollback to the legacy catalog.

## 8. Mission Outcome UX Fix

- [x] 8.1 Remove automatic progress recording on the last step; record the mission only when the learner taps "Complete" on the outcome screen
- [x] 8.2 Outcome footer: 80%+ correct shows "Close" + "Complete"; below 80% shows "Close" + "Replay" with an explanation of the 80% requirement in the result box
- [x] 8.3 Re-run the mobile test suite (including the updated flow test) and the iOS build
