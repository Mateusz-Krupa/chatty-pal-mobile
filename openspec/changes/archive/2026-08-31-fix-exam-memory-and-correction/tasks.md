## 1. Backend — examiner memory

- [x] 1.1 In the exam path of `buildConversation`, preserve a leading assistant opener (plain 20-message tail over non-system history) instead of the leading-assistant drop.
- [x] 1.2 Add a backend test: a fresh exam whose only history is the seeded greeting keeps the greeting in the constructed conversation.

## 2. Backend — fix-text model

- [x] 2.1 Make `/api/fix-text` honor an optional `model` field (fall back to the existing env default).
- [x] 2.2 Add a backend test asserting a request `model` overrides the default and a missing `model` falls back.

## 3. Mobile — stage-aware exam correction

- [x] 3.1 Rewrite the `examReadyAnswer` prompt to a stage-aware rewrite of the learner's own last utterance (no answering for the examiner, no extending the examiner's line, unchanged when already correct).
- [x] 3.2 Pass the current stage (`persona.examMode?.stage`) into the correction request and include it in the prompt.
- [x] 3.3 Add a mobile test asserting the exam correction request carries the current stage and the rewrite instruction.

## 4. Verify

- [x] 4.1 Run the backend Jest suite for `bot` and `fix-text`.
- [x] 4.2 Run the mobile build and focused test suites.
