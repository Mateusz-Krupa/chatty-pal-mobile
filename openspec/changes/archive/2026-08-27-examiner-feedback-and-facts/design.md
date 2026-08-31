# Design — examiner-feedback-and-facts

## Approach

Prompt-only change to the server-owned exam instruction (`EXAM_BASE_RULES` in `chatty-pal/src/pages/api/exam.ts`). No new API fields, no mobile changes: the model already receives the full capped conversation (20 messages), which is exactly what both behaviors need — quoting the learner's actual utterances, and seeing which facts were already stated.

## Key decisions

1. **Example-by-example corrections live under the existing "Besser so" heading.** The heading set (`Du hast gesagt / Gut / Besser so / Urteil / Nächster Schritt`) is already part of the contract and rendered as the final message (D-001); changing only the content rule keeps the mobile side untouched. Format: `Du: „<short quoted fragment>" → Besser: „<minimal correction>"`, up to 4 examples, most important first, only for mistakes actually made (no invented examples — consistent with the existing honesty rule).
2. **Facts checklist is a behavioral rule, not data.** No new "known facts" state is stored. The rule instructs the examiner to scan the conversation before each question and skip anything already stated. The A1 stages are short (5 questions max) and well inside the 20-message window, so the history is reliable. If this proves flaky with longer conversations later, the bounded ABOUT THE CANDIDATE block (already injected) is the escalation path.
3. **Both rules go into EXAM_BASE_RULES** so they apply to every speaking lesson/stage and the legacy examiner mode, not just one lesson.

## Non-goals

- No changes to the inline word-diff correction (separate capability, `inline-text-correction`).
- No per-mistake TTS or UI styling of the feedback — it is the examiner's final text message.

## Risks / mitigations

- **Model over-quotes or invents examples.** Mitigation: the rule limits to real mistakes actually in the conversation, caps at 4, and reuses the existing "summarize only statements actually made" honesty rule. Live-verify with a seeded wrong-answer conversation before deploy.
- **Examiner stops asking too early** (skips a question the learner only partially answered). Mitigation: the rule says skip only when the information is *clearly already stated*; partial/unclear answers still get one simple follow-up. Live-verify.
