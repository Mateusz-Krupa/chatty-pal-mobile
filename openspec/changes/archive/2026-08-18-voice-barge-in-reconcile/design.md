# Design — voice-barge-in-reconcile

## BargeInDetector (pure)

Stateless-in-spirit, injectable clock. Decides when the learner is speaking over the bot.

```swift
struct BargeInDetector {
    var threshold: Float = 0.02     // min RMS to count as speech
    var settle: TimeInterval = 0.5  // ignore for this long after arm (AEC settling)
    var sustain: TimeInterval = 0.4 // speech must persist this long (kill blips)
    var cooldown: TimeInterval = 1.0// min gap between two triggers

    mutating func arm(now: Date)
    mutating func disarm()
    @discardableResult mutating func feed(_ rms: Float, now: Date) -> Bool
}
```

`feed` returns `true` exactly when: armed, past `settle`, not in `cooldown`, and `rms > threshold` has held continuously for `sustain`. A dip below threshold resets the sustain window. After firing, `cooldown` suppresses further triggers.

## VoiceMonitor (live) + VoiceMonitoring

```swift
protocol VoiceMonitoring: AnyObject {
    var onLevel: ((Float) -> Void)? { get set }
    func start() throws
    func stop()
}
```

`VoiceMonitor` owns an `AVAudioEngine`. `start()` sets the shared session to `.playAndRecord` / `.voiceChat` / `[.defaultToSpeaker, .allowBluetooth]` (system AEC + speaker routing), installs a 1024-frame input tap, computes `SpeechController.rms(of:)` per buffer and delivers it on the main thread. `stop()` stops the engine and removes the tap. It does NOT nil `onLevel` (arming re-sets it; the detector's `armed` flag is the real gate).

Only one audio engine runs at a time: the monitor runs during the bot turn (waiting + playing), the `SpeechController` runs during recording. The engine switches cleanly between them.

## AVAudioPlayback — preserve AEC

```swift
let session = AVAudioSession.sharedInstance()
if session.category != .playAndRecord {
    try? session.setCategory(.playback, mode: .default, options: [])
}
try? session.setActive(true, options: .notifyOthersOnDeactivation)
```

During a barge-in turn the session is already `.playAndRecord`/`.voiceChat` (set by the monitor), so playback leaves it alone and AEC stays active. Outside voice turns the category is `.playback` and behaviour is unchanged.

## ChatEngine wiring

New state: `voiceTurnActive: Bool`, `mergeTargetID: UUID?`, `inFlightAssistantID: UUID?`, `bargeInDetector = BargeInDetector()`, `monitor: any VoiceMonitoring`.

- **Arming** — `requestBotResponse` arms barge-in only when `voiceTurnActive` (i.e. the turn was voice-started): `armBargeIn()` = `try? monitor.start()` + `detector.arm(now:)`. The first assistant bubble records `inFlightAssistantID` (stream + one-shot paths).
- **Typed turns** — `sendText` sets `mergeTargetID = nil` and never sets `voiceTurnActive`, so typed replies never arm barge-in.
- **Level** — `handleMonitorLevel(rms)` = `if detector.feed(rms, now: .now) { handleBargeIn() }`.
- **Barge-in** — `handleBargeIn()` = `reconcileInterruptedTurn()` → `interrupt()` → `startRecording()`.
- **Reconcile** — `reconcileInterruptedTurn()`: remove the message whose id == `inFlightAssistantID` (if present), clear it, then set `mergeTargetID` to the last user message's id.
- **Merge** — `deliverUtterance(_ text:)` (voice-only path, called from `finishUtterance` local + cloud branches instead of `sendText`): if `mergeTargetID` matches an existing user message, append the text to it (single bubble) and send the merged text; else append a new user message. Always clears `mergeTargetID`. Sets `voiceTurnActive = true` before requesting the reply.
- **Disarm** — `finishPlaybackPhase` (normal end) and `interrupt` both call `disarmBargeIn()` = `detector.disarm()` + `monitor.stop()`; `interrupt` also clears `inFlightAssistantID` and `voiceTurnActive` but leaves `mergeTargetID` (a following typed `sendText` or the merged `deliverUtterance` consumes it).
- **VAD** — `silenceWindow` default `1.8` → `2.5`.

Empty utterances never call `deliverUtterance`, so a pending `mergeTargetID` survives a no-speech segment and still merges the next real one.

## Testability

`BargeInDetector` is pure (inject `now`). `ChatEngine` takes `makeMonitor` in its dependencies; tests inject a `FakeMonitor` that records `started` and can `feed(rms)` into `onLevel`. The stream path is driven by the existing `FakeBot.streamMessage`.
