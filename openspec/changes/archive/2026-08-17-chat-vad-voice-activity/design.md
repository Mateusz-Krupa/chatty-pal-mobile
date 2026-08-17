# Design — Chat VAD

## Context

`ChatEngine` currently resets its 2s silence timer only from `handleTranscription` (partial results) and fires `sendTranscript()` when either the timer expires or an `isFinal` result arrives. The user-perceived failure modes:

1. Silent user: recognizer keeps producing partials (or the engine keeps resetting on noise) → the bot waits forever.
2. Mid-sentence pause > 2s: no new partial arrives → sentence is cut and sent as a fragment.

`SpeechController.startRecording()` already installs a tap on `AVAudioEngine.inputNode` bus 0 (`SpeechController.swift:49`) and receives `AVAudioPCMBuffer`s. RMS can be computed there with zero additional I/O.

## Goals

- End-of-speech decision driven by actual audio energy, not transcription text events.
- Visible voice-activity feedback in the listening bar.
- Pure, testable RMS math.
- No new permissions, no audio session changes, no server changes.

## Non-Goals

- Barge-in (interrupting bot TTS by talking) — separate change.
- Adaptive/ML VAD, noise gating beyond a fixed threshold.
- On-device recognition, waveform visualization.

## Decisions

### 1. RMS in the audio tap, reported as a callback

`SpeechController` gains:

```swift
var onAudioLevel: ((Float) -> Void)?   // raw RMS 0...1+, delivered on the tap thread
```

The tap closure computes `Self.rms(of: buffer)` and invokes the callback. `rms(of:)` is `static` and pure: sum of squares of `floatChannelData[0]` samples / frame count, square root.

Rationale: keeps signal processing in the controller (where the buffers already are), exposes a minimal scalar to the engine. Raw RMS (not dB) keeps the engine's threshold trivial and testable.

### 2. Voice threshold + normalization in ChatEngine

`ChatEngine` gains:

```swift
private let voiceThreshold: Float = 0.02   // RMS below this = silence
private(set) var audioLevel: Float = 0     // normalized 0...1 for the UI
```

`beginRecording()` wires `speech.onAudioLevel`:

- callback runs on the tap thread → hop to `MainActor` (same pattern as `onTranscription`)
- if `rms > voiceThreshold`: reset the silence timer AND set `audioLevel = min(1, rms / (voiceThreshold * 4))` (a talking voice typically sits around 0.05–0.3 RMS)
- otherwise: leave the timer alone (let it run out) and decay `audioLevel` to 0

Partial transcriptions still reset the timer (`handleTranscription` unchanged) — redundancy covers quiet speech whose RMS may dip under threshold while the recognizer is still confident.

Silence window: 2s → 1.2s. It is now real-audio silence, so 1.2s is a natural full stop without cutting typical mid-sentence pauses (~0.4–0.8s).

### 3. `isFinal` stays as an early send

`isFinal` still triggers `sendTranscript()` immediately (it is a strong end-of-utterance signal when the recognizer emits it). No debounce in this change: the delta logic in `TranscriptTracker` already coalesces a follow-on fragment into one message if the user continues.

### 4. UI: level bar in the listening bar

`ChatView`'s existing listening panel (`ChatView.swift:65-72`) gains a 4pt-tall capsule bar whose filled width tracks `engine.audioLevel` (0...1 → 0...full width), red, no animation timer (the level callback already fires ~50×/s at 1024-sample buffers). The existing pulsing mic ring stays as-is.

## Risks / Trade-offs

- Fixed threshold 0.02 may misbehave on very quiet mics or loud environments. Mitigation: constant lives in one place (`ChatEngine.voiceThreshold`); tune in follow-up if user feedback says so. No per-device calibration in v1.
- Level callback fires at buffer rate (~50/s) → `@Observable` invalidations at that rate. The listening bar only exists while recording and observes only `audioLevel`; cost is one small view refresh per buffer, acceptable. If profiling shows churn, coalesce to ~10 Hz.
- Tap-thread callback must hop to MainActor before touching engine state (existing `onTranscription` pattern reused).

## Test Strategy

- `SpeechController.rms(of:)`: build an `AVAudioPCMBuffer` with known amplitudes (e.g. constant 0.1 → rms 0.1; alternating ±0.1 → 0.1; zeros → 0), assert values.
- `ChatEngine` silence behavior with a fake `SpeechRecognition`: emit audio levels with a pause → transcript sent after silence window; continuous levels above threshold → not sent; partial-only reset still works (existing behavior preserved).
- Existing `TranscriptTracker` tests untouched and must stay green.
