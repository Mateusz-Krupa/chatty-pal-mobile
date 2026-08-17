# Tasks — chat-push-to-talk-flow

## 1. ChatEngine
- [x] 1.1 `startRecording()`: guard on `voiceState == .idle` only (was `!= .recording`)
- [x] 1.2 `handleTranscription`: `isFinal` updates `transcriptText` only (no cancel/send); partials still reset the silence timer
- [x] 1.3 Remove `pendingResume`, `resumeDelay` param, `scheduleResumeRecording`; `finishPlaybackPhase` returns to `.idle` only
- [x] 1.4 `sendText` / `speak`: drop the `pendingResume = true` branches

## 2. UI
- [x] 2.1 `ChatInputBar`: add `isVoiceLocked: Bool = false`; mic button disabled + dimmed when locked
- [x] 2.2 `ChatView`: pass `engine.voiceState == .waitingForBot || engine.voiceState == .playingTTS`

## 3. Tests
- [x] 3.1 Update voice-flow tests: no auto-resume (startCount stays 1, voiceState .idle after TTS)
- [x] 3.2 New test: isFinal mid-utterance does not send; following partial continues; VAD silence sends whole sentence as one message
- [x] 3.3 New test: startRecording during waitingForBot/playingTTS is a no-op
- [x] 3.4 Full test suite green + generic build

## 4. Finish
- [x] 4.1 Commit
- [x] 4.2 Archive OpenSpec change
