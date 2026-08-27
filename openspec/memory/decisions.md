# Decisions

## D-001: Preserve final guided-chat feedback
For guided speaking practice, feedback requested at completion stays visible as the final examiner message before the learner can close the session.
**Evidence:** openspec/changes/archive/2026-08-27-examiner-feedback-breakdown/
**Last verified:** 2026-08-27

## D-002: Context-aware text correction uses a general model, not the fine-tuned one
The fine-tuned `ft:gpt-3.5-turbo` fix-text model is unreliable with multi-turn context (it answers the conversation or "fixes" a context line). Corrections therefore run on `gpt-4o-mini` via the `/api/fix-text` `model` passthrough, with a proofreader system instruction that returns only the corrected final learner message and resolves pronouns from context.
**Evidence:** openspec/changes/archive/2026-08-27-inline-context-corrections/
**Last verified:** 2026-08-27
