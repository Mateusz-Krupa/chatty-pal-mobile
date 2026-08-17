# Chat hands-free resume

## Why

The push-to-talk change closed the microphone after every bot response. The user now wants the hands-free loop: after the bot finishes speaking, the app should start listening again automatically — without the old defects (mic open *during* the bot's speech, premature mid-sentence sends, session flapping).

## What Changes

- After a bot response finishes playing, the microphone reopens automatically **only when the user's turn was started by voice** (a voice-sent transcript or a replay tap made while recording).
- Turns started by typed text do not reopen the mic.
- A manual mic-tap stop keeps the mic closed (explicit user intent).
- The resume happens in `finishPlaybackPhase` (after playback has truly ended), with a 0.6s settle delay so the TTS tail is not picked up as a new utterance.

## Impact

- Affected specs: `chat-voice-input` (MODIFIED: push-to-talk flow — mic stays closed during the bot turn, reopens automatically after a voice turn).
- Affected code: `chatty-pal/ChatEngine.swift`, `chatty-palTests/ChatEngineTests.swift`.
- No server, permission, or pbxproj changes.
