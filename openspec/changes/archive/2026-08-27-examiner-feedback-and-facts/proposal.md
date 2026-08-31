## Why

Learner feedback from the A1 examiner is too vague: "Besser so" gives 1–2 generic corrections instead of showing, example by example, exactly which of the learner's utterances were wrong and what to say instead. Separately, the examiner re-asks information the learner already stated (name, city, job) instead of recognizing it from the conversation — the learner expects a "facts already told" checklist.

## What Changes

- Exam speaking prompts (server-owned, `chatty-pal/src/pages/api/exam.ts` `EXAM_BASE_RULES`):
  - "Besser so" becomes an example-by-example list: for each concrete learner mistake, quote the learner's short original fragment and give the minimal better alternative (`Du: „…" → Besser: „…"`), up to 4 examples, most important first.
  - New rule: the examiner tracks facts the candidate already provided in this conversation (name, origin, city, job/studies, family, hobbies, symptoms) and never asks for information that was already stated — it briefly acknowledges and moves on; if a stage's questions are all already answered by prior statements, it moves to the next step.
- No API shape change, no mobile code change — the model already receives the full capped conversation history.

## Capabilities

### New Capabilities
(none)

### Modified Capabilities
- `exam-conversation-quality`: "Mission-appropriate bot response" — the final practice assessment lists concrete quoted examples with better alternatives, and the examiner does not re-ask facts the candidate already provided.

## Impact

- Backend only: `chatty-pal/src/pages/api/exam.ts` (prompt text) + `exam.test.ts` (instruction assertions).
- Requires deployment to chatty-pal.com (explicit approval needed per workspace rules).
- Validation: deterministic instruction tests + live model calls before deploy.
