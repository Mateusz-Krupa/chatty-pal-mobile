# Learning shadowing mode

## Why

Listening and repeating (shadowing) is a core A1 technique, but the app only offers free chat. A guided "hear it → say it → get feedback" loop with per-word feedback closes the pronunciation gap and feeds weak material straight into the review queue.

## What Changes

- New pure `ShadowingScorer` (testable): greedy word alignment between a reference phrase and the spoken transcript, per-word match flags, percent score.
- New "Shadowing: Listen & Repeat" section in the lesson detail: per phrase — speaker (TTS), mic (push-to-talk via `SpeechController`), after stop: percent + the reference words colored matched/unmatched.
- Feedback loop: if the score is below 60%, the whole phrase is added to the Word Review queue automatically (with a visible note).
- New tests for the scorer (pbxproj entry).

## Impact

- Affected specs: new capability `shadowing`.
- Affected code: new `chatty-pal/ShadowingScorer.swift`, `chatty-palTests/ShadowingScorerTests.swift`; touched `chatty-pal/LearningViews.swift`; pbxproj IDs `AA...43`/`AA...44`.
- No server changes, no new permissions (mic + speech already used by chat).
