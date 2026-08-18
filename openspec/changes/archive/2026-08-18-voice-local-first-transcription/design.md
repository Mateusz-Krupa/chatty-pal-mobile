# Design — voice-local-first-transcription

## Setting

```swift
enum VoiceTranscriptionMode: String, CaseIterable, Identifiable {
    case local, cloud
    var title: String  // "On-device (fast)" / "Cloud Whisper (accurate)"
}

extension AppEnvironment {
    static var voiceTranscriptionMode: VoiceTranscriptionMode  // UserDefaults "voiceTranscriptionMode", default .local
}
```

Read live (not cached in the engine) so a settings change takes effect on the next utterance without rebuilding the engine.

## Chat (ChatEngine.finishUtterance)

```
let useCloud = AppEnvironment.voiceTranscriptionMode == .cloud
guard useCloud, let wav else { send local transcript immediately; return }
// cloud path unchanged (isTranscribing chip + Whisper + local fallback)
```

`local` mode reuses the existing nil-wav branch verbatim — `voiceState = .idle`, send if non-empty. No "Transcribing..." chip, no network.

## Shadowing (ShadowingPhraseRow.finishRecording)

Same gate around the existing Whisper `Task`. In `local` mode: score `localTranscript` synchronously (same review hook + stats). The "Transcribing..." label only appears in cloud mode.

## Tests

- Mode accessor: default `.local` when unset; round-trips stored raw values; unknown value → `.local`.
- ChatEngine: in local mode a voice turn sends the SFSpeech transcript and the transcriber is never called (FakeTranscriber.calls stays empty); cloud mode still calls it (existing tests cover).
