# Design — inline-context-corrections

## Approach

The correction pipeline already exists (`ChatEngine.fetchTeacherFix` → `TeacherService.fixText` → `/api/fix-text`, a fine-tuned single-turn model). This change (a) feeds recent conversation context into that request, and (b) in exam mode, attaches the result to the learner's own message instead of appending a separate teacher bubble.

## Key decisions

1. **Correction is stored on the learner message.** `ChatMessage` gains `var correction: String?`. Persisted history stays valid because the field is optional (old JSON decodes to `nil`). Storing on the message — instead of recomputing — keeps the "correction is visible on reload" scenario true and avoids re-calling the model on reload.

2. **Context is passed as real chat history to a general model, not the fine-tuned one.** `TeacherService.fixText` sends the recent turns in the `messages` array of the `/api/fix-text` body plus a `model` override, and puts a proofreader system instruction first. Verified live: the fine-tuned `ft:gpt-3.5-turbo` model is unreliable with any multi-turn context — it started answering the conversation instead of fixing, or "fixed" a context line instead of the learner's message. With `model: "gpt-4o-mini"` + an explicit system instruction ("return ONLY the corrected final learner message, minimal changes, resolve pronouns from context, never answer questions") the endpoint returned the corrected learner text reliably, fixed the gender case ("die Küche" → "ich kaufe sie") and left correct sentences unchanged. Context = last 4 user/assistant turns, trimmed; system/teacher/translation/suggestion roles are excluded.

3. **Context is always sent, never optional.** `ChatEngine` always has the conversation, so it always supplies context. Free chat also sends context (harmless; its UI is unchanged).

4. **No-op detection via diff, not string equality.** After receiving the corrected text, build the word-level diff (existing `TextDiffer`). If there is no `removed`/`added` segment (i.e. only `.same`), treat the message as already correct and do not store a correction. This is case/punctuation-insensitive, matching how the diff is displayed.

5. **Exam vs free-chat divergence is only where the result goes.** Both modes fetch the same way. Exam mode (`persona.examMode != nil`) writes `correction` onto the last learner message; free chat appends a `.teacher` message as today.

6. **Rendering.** `MessageView` shows a compact diff row under a `.user` bubble when `message.correction != nil`. Reuses `TextDiffer` (strikethrough secondary + bold orange) and aligns to the learner side (trailing).

## Non-goals

- No change to the fine-tuned model or the `/api/fix-text` endpoint.
- No change to free-chat UI (teacher bubble stays).
- No TTS of the correction; the learner's original text is what is spoken.

## Risks / mitigations

- **Model over-rewrites** (e.g. reorders a long sentence). Mitigation: no-op detection prevents empty corrections; the system instruction demands minimal changes; live tests showed correct sentences come back unchanged. If it rewrites too aggressively in practice, the diff still only highlights the changed words, which is the accepted behavior (same as the current teacher bubble).
- **Context too long.** Mitigation: cap at 4 turns and trim each turn to 500 characters.
- **Model availability / cost.** `gpt-4o-mini` is a cheap, standard model on the same OpenAI key the endpoint already uses; one short call per learner message. If the `model` override is ever unavailable the endpoint returns 500 and the fix is simply skipped (existing failure path — corrections are best-effort and never surface as errors).
