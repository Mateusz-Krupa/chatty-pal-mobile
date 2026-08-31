# Design: Honest Examiner Memory

## Current State

Main chat summaries are stored by `BotMemoryStore` per language and account scope. Campaign speaking creates a fresh `ChatEngine` with `TransientChatStore`, so leaving the screen discards its messages. Exam requests also discard the client system instruction in favor of the server-owned prompt, so adding memory only to `ChatPersona.memory` would not reach the model.

## Decisions

### Persist conversations by lesson and stage

Add `LessonChatStore: ChatStore`, backed by `UserDefaults` and keyed by `DataScope`, lesson ID, and stage ID. It stores only the active speaking stage's messages. Reopening the same stage restores its conversation; other stages remain independent.

The speaking screen exposes a visible `Refresh chat` action. It clears the active `LessonChatStore`, interrupts the current engine, and starts a fresh engine so the examiner opening is sent again. This is intentionally scoped to the active stage.

### Pass learner memory through the exam contract

Add optional `learnerContext` to `ExamMode`. `CampaignSpeakingView` reads the existing `BotMemoryStore` summary for the exam language and passes it via `ChatPersona.examinerA1`.

The server appends a bounded `ABOUT THE CANDIDATE` data section to the server-owned system instruction. The task and role remain authoritative; learner context is reference material, not an instruction channel.

### Honest examiner feedback

Replace the encouragement-only rule with a concise assessment rule. When the candidate finishes a task or explicitly asks how they did, the examiner gives:

1. One concrete strength.
2. One concrete weakness or missing requirement.
3. A truthful task-level verdict: `PASS`, `BORDERLINE`, or `NOT YET PASS`.
4. One next improvement.

The examiner remains polite and A1-appropriate during the task. The verdict is practice feedback, never an official Goethe result.

## Compatibility

`learnerContext` is optional in the iOS request and web type. Existing non-exam chat and legacy examiner mode continue to work. Empty or missing learner context produces the current instruction shape apart from the revised feedback policy.

## Validation

- iOS tests prove stage history persists and refresh clears only that stage.
- iOS contract tests prove learner context reaches `ExamMode`.
- Jest tests prove learner context is embedded in the server instruction and honest verdict language remains in the exam rules.
- Full mobile and targeted backend suites remain green.
