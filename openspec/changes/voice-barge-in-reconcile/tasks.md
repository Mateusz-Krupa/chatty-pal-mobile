# Tasks — voice-barge-in-reconcile

- [x] 1.1 `BargeInDetector` (pure): threshold/settle/sustain/cooldown, `arm(now:)`/`disarm()`/`feed(_:now:)`
- [x] 1.2 `VoiceMonitor` (AVAudioEngine + `.playAndRecord`/`.voiceChat` AEC) + `VoiceMonitoring` protocol
- [x] 1.3 `ChatEngineDependencies`: add `makeMonitor`; live = `VoiceMonitor()`
- [x] 2.1 `AVAudioPlayback.play`: preserve `.playAndRecord` session (don't clobber AEC)
- [x] 2.2 `ChatEngine`: state (`voiceTurnActive`, `mergeTargetID`, `inFlightAssistantID`, `monitor`, `bargeInDetector`); VAD `1.8` → `2.5`
- [x] 2.3 `ChatEngine`: arm in `requestBotResponse` (voice turns), record `inFlightAssistantID`
- [x] 2.4 `ChatEngine`: `handleMonitorLevel` / `handleBargeIn` (reconcile + interrupt + startRecording)
- [x] 2.5 `ChatEngine`: `reconcileInterruptedTurn` + `deliverUtterance` (merge); wire `finishUtterance` to it; `sendText` clears merge target; disarm in `interrupt`/`finishPlaybackPhase`
- [x] 3.1 Tests: `BargeInDetector` unit tests (sustain/cooldown/settle/disarmed)
- [x] 3.2 Tests: ChatEngine barge-in + reconcile/merge integration (FakeMonitor); typed cancels merge
- [x] 4.1 Register new files in pbxproj (BargeInDetector, VoiceMonitor, BargeInTests) — IDs `AA…67`+
- [x] 4.2 Build + full test suite green
- [x] 4.3 Third-person self-evaluation of the voice loop; fix anything ≤ 4.5 until > 4.5
- [x] 4.4 Commit + archive
