## Context

The exam speaking flow is server-owned: the mobile client sends a deterministic greeting + full history, and the backend builds the system prompt from `examMode` (mode/lessonId/stage) via `resolveExamSystemInstruction`. The exam-ready correction is produced by a separate `/api/fix-text` round trip, invoked from `ChatEngine.fetchTeacherFix`.

## Goals / Non-Goals

**Goals:**
- Make the model aware of the seeded examiner greeting so it continues instead of re-introducing.
- Make the exam inline correction a stage-aware rewrite of the learner's own utterance.
- Make the fix-text `model` field real (honored by the backend).

**Non-Goals:**
- Changing the non-exam web chat history windowing.
- Changing the exam system prompt's stage instructions (they are already correct).

## Decisions

- Scope the leading-assistant drop to non-exam only. The exam branch of `buildConversation` will use a plain length tail (`.slice(-HISTORY_MESSAGE_LIMIT)`) over non-system history, keeping a leading assistant opener. Rationale: the seeded greeting is the only history on a fresh exam and dropping it is the direct cause of the re-introduction; OpenRouter/the exam model accept a conversation that begins with an assistant opener. Non-exam keeps `tailConversation` unchanged to avoid altering web-chat behavior. Alternative considered: instruct the model in the system prompt that it already greeted — rejected because the greeting content is client-generated and varies by stage, so it must come from history, not the prompt.
- Rewrite the exam `examReadyAnswer` prompt to: rewrite only the learner's final (user) message into a single correct, natural A1 German response that fits the current stage; keep the learner's intended meaning; do not answer for the examiner, do not extend the examiner's sentence, no comments/translations; return unchanged if already correct. Pass the current stage id (a human-readable German label such as "Über die Familie sprechen") into the prompt so the model knows the task. Rationale: the stage id already conveys the task to a capable model and is available on the client as `persona.examMode?.stage`.
- Honor an optional `model` in `/api/fix-text`: `const model = req.body.model || process.env.OPEN_ROUTER_FIX_MODEL || process.env.OPEN_ROUTER_MODEL || "deepseek/deepseek-v4-flash"`. This makes the client contract true and lets the exam correction pin a model explicitly.

## Risks / Trade-offs

- Preserving a leading assistant opener in exam history: if the window were long and started mid-conversation on an assistant turn, that assistant turn is now kept. Mitigation: the exam opener is short and the window is 20, so in practice the kept leading assistant is the seeded greeting; the model already handles assistant-first openings.
- Passing the stage label into the correction prompt adds a little prompt text; negligible.
