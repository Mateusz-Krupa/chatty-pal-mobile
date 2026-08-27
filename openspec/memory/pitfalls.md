# Pitfalls

## P-001: Fine-tuned fix-text model breaks with multi-turn context
Feeding the `ft:gpt-3.5-turbo` fix-text model a multi-turn `messages` history makes it stop correcting the learner's message — it either answers the conversation or returns a "corrected" context line. Keep single-turn "Fix to X: text" for that model; use a general model with an explicit proofreader system prompt when context is needed.
**Evidence:** openspec/changes/archive/2026-08-27-inline-context-corrections/
**Last verified:** 2026-08-27

## P-002: Swift synthesized Encodable emits null for nil String?
A `let model: String?` encoded by synthesized `Encodable` serializes to `"model": null` when nil. Server-side JS default parameters only apply to `undefined`, so `null` reaches OpenAI and errors. Use a custom `encode(to:)` with `encodeIfPresent` for optional request fields.
**Evidence:** openspec/changes/archive/2026-08-27-inline-context-corrections/
**Last verified:** 2026-08-27
