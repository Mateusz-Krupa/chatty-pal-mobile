# Design — Chat learner-friendly silence window

## Decision

`ChatEngine` default `silenceWindow`: 1.2s → 3.0s.

Rationale: target users are A1/B1 learners; thinking pauses of 2–4s are normal while composing a sentence. A 3s window absorbs typical mid-sentence pauses while adding at most 1.8s of tail latency for a finished utterance. The value stays an init parameter (tests use 0.05–0.3s).

Trade-off: finished sentences are sent ~1.8s later than before. Accepted — learners benefit more from not being cut off. If it feels sluggish, this is a one-constant tuning.

## Out of scope

Adaptive window (e.g., longer when the user has just started speaking), per-user setting in the app UI.
