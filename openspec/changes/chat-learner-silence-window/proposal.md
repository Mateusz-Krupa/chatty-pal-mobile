# Chat learner-friendly silence window

## Why

The 1.2s VAD silence window is tuned for fluent speakers. The app's users are beginners still learning the language — they pause 2–4s to think of a word or phrase mid-sentence, and the current window cuts them off and sends a half-sentence.

## What Changes

- The silence window default changes from 1.2s to 3.0s in `ChatEngine` (single parameter, still injectable for tests).

## Impact

- Affected specs: `chat-voice-input` (MODIFIED: silence window value).
- Affected code: `chatty-pal/ChatEngine.swift` (default value only).
- Tests unaffected (they inject their own small windows).
