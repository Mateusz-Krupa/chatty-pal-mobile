## Why

Two exam bugs hurt the speaking practice experience:
1. The examiner re-introduces itself. The mobile app seeds a deterministic examiner greeting as the first assistant turn, but the backend `tailConversation` helper drops a leading assistant message from the 20-message window. On a fresh exam the greeting is the only history, so it is dropped and the model never sees it already greeted — then the exam system prompt ("greet the candidate, introduce yourself") makes it greet again.
2. The inline "exam-ready answer" correction is framed as "answer the latest assistant question" and has no awareness of the current task stage, so it sometimes produces text that reads like a continuation of the examiner's line instead of a corrected version of the learner's own utterance.

Additionally, the mobile fix-text client sends a `model` field that the backend `/api/fix-text` handler ignores, so client-side model selection is a false contract.

## What Changes

- Backend (`chatty-pal`): in the exam path of `buildConversation`, preserve the client's session history including a leading assistant opener (stop dropping the seeded examiner greeting). Non-exam web chat keeps the existing leading-assistant drop.
- Backend (`chatty-pal`): `/api/fix-text` honors an optional `model` field from the request (falls back to the existing env default), so the client `model` selection is real.
- Mobile (`chatty-pal-mobile`): rewrite the exam `examReadyAnswer` correction prompt to rewrite the learner's own last utterance into a correct, natural A1 response that fits the current stage, and pass the current stage into the prompt.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `exam-conversation-quality`: the exam conversation preserves a leading assistant opener (the seeded examiner greeting) instead of dropping it.
- `inline-text-correction`: in exam mode the inline correction is a stage-aware rewrite of the learner's own last utterance, never a continuation of the examiner's line.

## Impact

- `chatty-pal/src/pages/api/bot.ts` (exam branch of `buildConversation`), `chatty-pal/src/pages/api/fix-text.ts` (honor `model`), and their tests.
- `chatty-pal-mobile/chatty-pal/TeacherService.swift` (`examReadyAnswer` prompt), `chatty-pal/ChatEngine.swift` (pass the current stage into the correction request), and related tests.
