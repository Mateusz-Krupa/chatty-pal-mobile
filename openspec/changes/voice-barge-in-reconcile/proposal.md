# Proposal — voice-barge-in-reconcile

## Why

The voice conversation loop is the most important part of the bot, and today it feels unnatural in two ways: (1) the learner has to wait out the entire bot reply before speaking again (the mic is locked while the bot is thinking/playing), and (2) when the learner's single utterance is split by the VAD silence window, the bot reacts to the first half prematurely and there is no way to keep the thought going. A natural voice assistant lets the user interrupt the bot at any time and continue seamlessly.

## What changes

- **Barge-in:** while the bot is waiting for its response or playing it (voice turns only), the app monitors the microphone with automatic echo cancellation and detects when the learner is speaking. On detection it stops the bot (generation + speech) and immediately reopens the microphone so the learner can continue.
- **Reconcile:** the bot's interrupted (unfinished) reply is removed from the transcript, and the learner's continuing utterance is merged with the interrupted one into a single user message before being sent, so the bot answers the whole thought once.
- **Echo cancellation:** voice conversation turns run the audio session in play-and-record with the voice-chat mode so the bot's own speech is cancelled from the microphone signal and does not trigger itself.
- **VAD window** 1.8s → 2.5s: barge-in is self-healing, so a longer end-of-speech window is safe and reduces premature splits.

## Impact

- New: `BargeInDetector` (pure, unit-testable), `VoiceMonitor` (AVAudioEngine + AEC session) + `VoiceMonitoring` protocol.
- Touched: `ChatEngine` (arm/disarm, reconcile, merge, VAD window), `ChatEngineDependencies` (`makeMonitor`), `AVAudioPlayback` (preserve AEC session during playback).
- Tests: detector unit tests + ChatEngine barge-in/reconcile integration (FakeMonitor).
- No backend change. Three new source files registered in pbxproj.
