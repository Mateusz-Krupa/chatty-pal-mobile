# Chat VAD (Voice Activity Detection)

## Why

The chat's end-of-speech detection is text-driven: the 2s silence timer in `ChatEngine` resets only when a new partial transcription arrives from `SFSpeechRecognizer`. In practice this means:

- While the user is silent, the recognizer may keep emitting (or re-emitting) partials, so the timer never fires and the bot waits indefinitely.
- A natural pause longer than 2s mid-sentence stops the transcript from changing, so the sentence is cut and sent as a fragment.

Both are visible as "the chat doesn't react cleanly when I stop talking."

## What Changes

- `SpeechController` computes the RMS level of each microphone buffer in the existing audio tap and reports it through a new `onAudioLevel` callback (no new permissions, no new audio session work).
- `ChatEngine` treats reported voice energy as the source of truth for silence: voice above threshold resets the silence timer (in addition to partial transcriptions, as a fallback for quiet speech). The silence window shortens from 2s to 1.2s since it is now measured on real audio.
- `ChatEngine` exposes a normalized `audioLevel` (0...1) so the UI can show live voice feedback.
- The listening bar in `ChatView` shows a small live level indicator that grows while the user is talking.
- `SpeechController.rms(of:)` is a static pure function so the threshold math is unit-testable.

## Impact

- Affected specs: `chat-voice-input` (end-of-speech detection behavior, voice-activity feedback).
- Affected code: `chatty-pal/SpeechController.swift`, `chatty-pal/ChatEngineDependencies.swift`, `chatty-pal/ChatEngine.swift`, `chatty-pal/ChatView.swift`; new unit tests for RMS computation.
- No new entitlements, no API surface changes, no server changes.
- Out of scope (explicitly): barge-in (interrupting TTS by talking), on-device-only recognition, waveform rendering.
