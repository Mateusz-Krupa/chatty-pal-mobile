# Tasks: Honest Examiner Memory

## 1. Speaking history storage

- [x] 1.1 Add `LessonChatStore`, scoped by account, lesson, and stage; test load/save/clear persistence.
- [x] 1.2 Use `LessonChatStore` in campaign speaking and prevent a duplicate opening message when restored history exists.

## 2. Learner context contract

- [x] 2.1 Add optional `learnerContext` to `ExamMode` and `ChatPersona.examinerA1`; pass `BotMemoryStore`'s exam-language summary from campaign speaking.
- [x] 2.2 Extend web exam request typing and server instruction construction to include bounded candidate context.
- [x] 2.3 Add iOS and Jest contract tests for learner context.

## 3. Honest feedback

- [x] 3.1 Replace encouragement-only examiner feedback rules with the truthful PASS / BORDERLINE / NOT YET PASS practice rubric.
- [x] 3.2 Extend Jest instruction tests for the rubric and the non-official-result disclaimer.

## 4. Refresh chat UX

- [x] 4.1 Add a visible Refresh chat action to campaign speaking that clears only the active stage and starts the examiner again.
- [x] 4.2 Add a lifecycle test for refresh and persisted stage history.

## 5. Verification

- [x] 5.1 Run `npx jest src/pages/api/bot.test.ts src/pages/api/exam.test.ts`.
- [x] 5.2 Build and run the full `chatty-palTests` suite on the iPhone SE simulator.
