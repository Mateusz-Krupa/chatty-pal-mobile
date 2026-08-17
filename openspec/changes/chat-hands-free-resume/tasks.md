# Tasks — chat-hands-free-resume

## 1. ChatEngine
- [x] 1.1 Add `autoResumeListening` flag + `resumeTask`; init param `resumeDelay = 0.6`
- [x] 1.2 Set the flag in `sendText` / `speak` when stopping a recording turn
- [x] 1.3 `finishPlaybackPhase` consumes the flag → schedules `startRecording` after `resumeDelay`
- [x] 1.4 `interrupt` / `toggleTTS`-off clear the flag and cancel the pending resume
- [x] 1.5 `beginRecording` cancels any pending resume task

## 2. Tests
- [x] 2.1 Voice flow: auto-resume after TTS (startCount 2, state .recording); TTS-fail and bot-fail paths too
- [x] 2.2 Typed-text turn: no resume (startCount 0)
- [x] 2.3 Manual stop: no resume (existing test)
- [x] 2.4 TTS-off mid-playback: no stale resume on the next turn
- [x] 2.5 Full suite green + generic build

## 3. Finish
- [x] 3.1 Commit + archive
