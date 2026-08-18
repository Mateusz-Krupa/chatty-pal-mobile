# Proposal — voice-local-first-transcription

## Why

The cloud Whisper round-trip (upload + server + OpenAI) adds 1–3s to every voice turn and shadowing attempt. The on-device SFSpeech transcript is already captured live (it drives the "Listening..." text) and is instant. The learner prefers speed: the on-device transcript should be the default, with cloud Whisper available as an opt-in for accuracy.

## What changes

- New `VoiceTranscriptionMode` setting (`local` default / `cloud`), read live from `UserDefaults`.
- Chat voice turns: in `local` mode the on-device transcript is sent immediately — no upload, no "Transcribing..." wait. `cloud` mode keeps the current Whisper path (with local fallback on failure).
- Shadowing: same gate — `local` scores the on-device transcript instantly; `cloud` scores the Whisper transcript as today.
- Settings sheet: "Voice input" picker (On-device (fast) / Cloud Whisper (accurate)).

## Impact

- New: mode enum + accessor (in `BotService.swift` near `AppEnvironment`), Settings picker.
- Touched: `ChatEngine.finishUtterance`, `ShadowingPhraseRow.finishRecording`.
- No backend change. No new files (keeps pbxproj untouched).
