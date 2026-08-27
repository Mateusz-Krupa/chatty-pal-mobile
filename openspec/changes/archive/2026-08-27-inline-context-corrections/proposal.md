## Why

In exam speaking practice the learner currently receives a separate teacher bubble with the corrected text, generated without any conversation context (so word choice and gender can be "fixed" arbitrarily). The agreed UX: a minimal correction shown inline under the learner's own message, with the wrong part struck through and the fix highlighted, using the recent conversation as context.

## What Changes

- `ChatMessage` gains an optional `correction` field (backward compatible with persisted history).
- `TeacherService.fixText` sends the recent conversation context (last 4 user/assistant turns) via the existing `messages` field of `/api/fix-text`, together with a proofreader system instruction and a `model: "gpt-4o-mini"` override (the endpoint already passes both through). The fine-tuned model is unreliable with multi-turn context (live-verified: it answered the conversation or fixed context lines instead), so the fix now runs on a general model with an explicit "return only the corrected final learner message" instruction.
- `ChatEngine.fetchTeacherFix`: in exam mode the result is attached to the last learner message as `correction` (no separate `.teacher` message); if the corrected text is unchanged, no correction is stored. Free chat keeps the existing teacher bubble (now also context-aware).
- `MessageView` renders a compact diff (strikethrough original + highlighted fix) under a learner message that carries a correction.

## Capabilities

### New Capabilities
- `inline-text-correction`: context-aware, minimal inline correction under learner messages in exam speaking practice; free chat keeps its teacher bubble.

### Modified Capabilities
(none — the free-chat teacher bubble requirement is unchanged; exam speaking gains the new capability)

## Impact

- iOS only: `ChatMessage.swift`, `TeacherService.swift`, `ChatEngine.swift`, `MessageView.swift` + unit tests.
- Backend unchanged: `/api/fix-text` already forwards `messages` to the model (verified live: the fine-tuned model respects context and returns correct sentences unchanged).
- No deployment needed.
