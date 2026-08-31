# Decisions

## D-001: Preserve final guided-chat feedback
For guided speaking practice, feedback requested at completion stays visible as the final examiner message before the learner can close the session.
**Evidence:** openspec/changes/archive/2026-08-27-examiner-feedback-breakdown/
**Last verified:** 2026-08-27

## D-002: Context-aware text correction uses a general model, not the fine-tuned one
The fine-tuned `ft:gpt-3.5-turbo` fix-text model is unreliable with multi-turn context (it answers the conversation or "fixes" a context line). Corrections therefore run on `gpt-4o-mini` via the `/api/fix-text` `model` passthrough, with a proofreader system instruction that returns only the corrected final learner message and resolves pronouns from context.
**Evidence:** openspec/changes/archive/2026-08-27-inline-context-corrections/
**Last verified:** 2026-08-27

## D-003: Use bounded exam history as the facts checklist
For short A1 stages, the server-provided 20-message conversation history is sufficient for the examiner to recognize facts the learner already stated. Prompt rules make it skip clearly answered name, city, job, and similar questions rather than persisting a separate facts store.
**Evidence:** openspec/changes/archive/2026-08-27-examiner-feedback-and-facts/
**Last verified:** 2026-08-27

## D-004: Deduplicate the submitted exam turn
The server removes a trailing history message equal to the submitted learner turn before appending the turn. This keeps each learner answer visible to the examiner exactly once.
**Evidence:** openspec/changes/archive/2026-08-27-fix-exam-conversation-history/
**Last verified:** 2026-08-27
