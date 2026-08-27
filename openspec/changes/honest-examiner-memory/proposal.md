## Why

Speaking-practice conversations disappear when the learner leaves the screen because they use transient storage. The examiner also receives no learner memory, and its current prompt requests only encouraging feedback instead of an honest assessment useful for preparing to pass the Goethe A1 exam.

## What Changes

- Persist each campaign speaking conversation locally by lesson and stage so reopening it resumes the existing exchange.
- Add a visible "Refresh chat" action that clears only the active speaking conversation and restarts it from the examiner opening.
- Extend the exam contract with optional learner context derived from the existing per-language learner summary; the server adds it to its authoritative exam instruction.
- Replace encouragement-only exam feedback with concise, truthful stage feedback: what worked, what needs improvement, and a PASS / BORDERLINE / NOT YET PASS verdict for that practice task.

## Capabilities

### New Capabilities

- `exam-speaking-memory`: Persistent speaking-session history, learner context, and learner-controlled refresh behavior.

### Modified Capabilities

- `exam-conversation-quality`: Server-owned exam instructions incorporate bounded learner context and require honest assessment feedback.
- `exam-speaking-practice`: Speaking practice resumes its active conversation and supports resetting that conversation.

## Impact

- iOS: chat storage, `ExamMode`, examiner persona creation, campaign speaking UI, and iOS contract tests.
- Web: `src/pages/api/exam.ts`, `src/pages/api/bot.ts`, and Jest contract tests.
- No new dependencies or external API endpoints.
