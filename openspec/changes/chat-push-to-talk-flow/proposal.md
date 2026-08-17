# Chat push-to-talk flow

## Why

The current voice loop auto-reopens the microphone 0.35s after every bot response (`pendingResume` + `scheduleResumeRecording`). In real use this produces the exact complaints reported:

- "It keeps listening to me all the time" — the mic silently reopens on every turn.
- "It stops mid-sentence, there is no end" — a premature `isFinal` from SFSpeech sends the first half of the sentence, closes the mic while the bot processes, and the second half is lost.
- "Sometimes nothing happens / it takes a long time / the response doesn't play" — the audio session flaps between `.record` and `.playback` on every turn, and the recognizer keeps the silence timer alive with noise.

The user wants a simple, predictable model: **tap the button → it listens → I stop talking → it sends and responds → while it responds the mic is closed → back to idle**.

## What Changes

- Remove the auto-resume machinery (`pendingResume`, `resumeDelay`, `scheduleResumeRecording`): after a bot response the mic stays closed.
- The microphone can only start from `.idle` — never during `waitingForBot` or `playingTTS`.
- While recording, an `isFinal` recognition result no longer triggers an immediate send; only the VAD silence window (1.2s of real audio silence) or a manual mic tap ends the utterance, so a full sentence is sent as one message.
- The mic button is visually disabled while the bot is thinking or speaking.

## Impact

- Affected specs: `chat-voice-input` (ADDED: push-to-talk flow; the VAD end-of-speech requirement is unchanged).
- Affected code: `chatty-pal/ChatEngine.swift`, `chatty-pal/ChatInputBar.swift`, `chatty-pal/ChatView.swift`, `chatty-palTests/ChatEngineTests.swift`.
- No server, permission, or pbxproj changes.
- Out of scope: barge-in (interrupting the bot by talking), adaptive silence timing.
