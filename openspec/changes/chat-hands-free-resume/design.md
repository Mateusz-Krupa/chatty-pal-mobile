# Design — Chat hands-free resume

## Context

Push-to-talk made the flow predictable but removed the hands-free loop: after a bot answer the user must tap the mic again. The user explicitly wants: tap once → talk → bot answers → **app listens again automatically**.

The original auto-resume (removed) had defects: it fired 0.35s after TTS end, could re-open the mic while the bot was still finishing, and set `pendingResume` on every voice turn regardless of context. This time the resume is anchored to `finishPlaybackPhase` (playback truly finished, state `.idle`) with a settle delay.

## Target behavior

```
idle --mic tap--> recording
recording --VAD silence / mic tap--> sendText (marks voice turn) --> waitingForBot
waitingForBot --bot reply--> playingTTS
playingTTS --TTS end--> idle --0.6s, if voice turn--> recording   (hands-free loop)
idle --typed text--> waitingForBot --> playingTTS --> idle (mic stays closed)
```

Rules:

1. A turn is "voice-started" when `sendText` or a replay `speak` runs while `voiceState == .recording`. That sets `autoResumeListening = true`.
2. `finishPlaybackPhase()` consumes the flag: returns to `.idle`, then schedules `startRecording()` after `resumeDelay` (0.6s default).
3. Typed-text turns and manual mic-tap stops never set the flag — the mic stays closed.
4. `interrupt()` and turning TTS off clear the flag and cancel any pending resume task.
5. The 0.6s settle keeps the TTS tail out of the first microphone buffers, reducing self-echo feedback.

## Decisions

### 1. Flag consumed in `finishPlaybackPhase` only

Rationale: that is the single choke point where "bot turn over" becomes true (TTS end, TTS failure, TTS disabled). Resuming anywhere else re-introduces the "mic open during bot speech" complaint.

### 2. 0.6s settle delay

The old 0.35s felt like the app "listens all the time" and caught TTS tails. 0.6s after `onFinished` is quiet enough on typical hardware; it is an init parameter so tests can shrink it (harness uses 0.05s).

### 3. Replay-while-recording resumes listening

A replay tap made while recording stops the mic and plays the message; after it, the hands-free loop continues (same as before push-to-talk).

## Risks / Trade-offs

- Echo loop: the mic hears its own TTS → sends the bot's words back. Mitigations: resume only after `onFinished` + 0.6s + VAD threshold; monitor in the field, tune the delay if it happens.
- Users who type but also tapped the mic once stay in the voice loop until they tap the mic to stop — that is the requested behavior.

## Test Strategy

- Voice flow test updated: after reply + TTS, `startCount == 2` and state `.recording` (auto-resume).
- New: typed-text turn does not resume (`startCount == 0` after the turn).
- New: manual mic-tap stop does not resume (existing test keeps passing).
- New: TTS-off mid-playback clears the pending resume (no stale resume on the next turn).
- Existing push-to-talk tests (mic locked during bot turn, isFinal mid-sentence) stay green.
