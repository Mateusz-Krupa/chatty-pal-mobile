# Learnings

## Outcome
- [pitfall] The fine-tuned `ft:gpt-3.5-turbo` fix-text model is NOT context-safe. With any multi-turn history it either answers the conversation, or "corrects" a context line instead of the learner's message. Single-turn "Fix to German: X" remains its reliable mode only.
- [decision] Context-aware corrections run on `gpt-4o-mini` via the `/api/fix-text` `model` passthrough, with a proofreader system instruction ("return ONLY the corrected final learner message, minimal changes, resolve pronouns from context, never answer questions"). Live-verified: fixes grammar, resolves gender from context, leaves correct sentences unchanged.
- [pitfall] Swift synthesized `Encodable` writes `null` for `String?` nil — the fix-text server passes `model` straight to OpenAI and JS default parameters do not catch `null`. Omitted keys require `encodeIfPresent`.
- [local] Diff rendering must insert a space between word-diff segments; the first implementation concatenated them ("Ichhabenin") and the bug existed in the pre-existing teacher bubble too.
- [local] Swift: a method with a default argument does not witness a shorter protocol requirement; add the real overload.
- memory impact: none retrieved (memory store was created mid-session for the previous archive and not yet indexed)
