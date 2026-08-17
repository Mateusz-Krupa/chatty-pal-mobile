# Tasks — chat-vad-voice-activity

## 1. RMS in SpeechController
- [x] 1.1 Add `static func rms(of buffer: AVAudioPCMBuffer) -> Float` (pure, first channel, sum-of-squares / frameCount)
- [x] 1.2 Add `var onAudioLevel: ((Float) -> Void)?` and invoke it with `rms(of:)` inside the existing input tap
- [x] 1.3 Clear `onAudioLevel` / stop reporting in `stopRecording()`

## 2. Protocol + engine wiring
- [x] 2.1 Add `var onAudioLevel: ((Float) -> Void)?` to the `SpeechRecognition` protocol (with default `nil` for existing fakes)
- [x] 2.2 `ChatEngine`: add `voiceThreshold = 0.02` and `private(set) var audioLevel: Float = 0`
- [x] 2.3 `beginRecording()`: wire `onAudioLevel` → MainActor hop → above threshold: `scheduleSilenceTimer()` + `audioLevel = min(1, rms / (voiceThreshold * 4))`; below: `audioLevel = 0`
- [x] 2.4 Change default `silenceWindow` from 2 to 1.2
- [x] 2.5 Reset `audioLevel = 0` in `stopSpeechAndSend`, `stopSpeechWithoutSend`, `interrupt`

## 3. UI level indicator
- [x] 3.1 In `ChatView` listening panel: add a 4pt capsule level bar filled proportional to `engine.audioLevel`

## 4. Tests
- [x] 4.1 `SpeechController.rms(of:)` unit tests: constant amplitude, alternating ±a, silence (new test file + pbxproj entries, IDs from AA...35)
- [x] 4.2 `ChatEngine` VAD tests with fake speech: silence window fires send; continuous voice above threshold does not; below-threshold level does not reset timer; level resets to 0 on stop

## 5. Verify
- [x] 5.1 Build (generic iOS Simulator) succeeds
- [x] 5.2 Full test suite green
- [x] 5.3 Commit
