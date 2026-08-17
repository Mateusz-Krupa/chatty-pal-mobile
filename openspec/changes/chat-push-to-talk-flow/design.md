# Design — Chat push-to-talk flow

## Context

Current state machine (`ChatEngine`):

```
idle --mic tap--> recording
recording --isFinal OR silence-timer--> sendText --> waitingForBot
waitingForBot --bot reply--> playingTTS
playingTTS --TTS end--> idle, then if pendingResume: auto startRecording (0.35s)
```

`pendingResume` is set every time `sendText`/`speak` runs while recording — which is *every* voice-sent turn — so the mic reopens after each bot answer. `isFinal` also sends immediately, and SFSpeech emits finals on mid-sentence pauses, which (with the mic closing for bot processing) drops the rest of the sentence.

## Target state machine

```
idle --mic tap--> recording
recording --VAD silence 1.2s--> sendText --> waitingForBot
recording --mic tap (manual)--> stopSpeechAndSend --> waitingForBot
recording --speech error--> idle
waitingForBot --bot reply--> playingTTS
playingTTS --TTS end--> idle          (mic stays closed)
```

Rules:

1. `startRecording()` only proceeds from `.idle` (guard `voiceState == .idle`).
2. `handleTranscription`: partial results update `transcriptText` and reset the silence timer (fallback for quiet speech). `isFinal` updates `transcriptText` only — it neither cancels the timer nor sends. The utterance ends only on real-audio silence (VAD timer) or a manual tap.
3. Delete `pendingResume`, `resumeDelay`, `scheduleResumeRecording`. `finishPlaybackPhase` just returns to `.idle`.
4. Mic button disabled while `voiceState` is `.waitingForBot` or `.playingTTS`.

## Decisions

### 1. `isFinal` no longer sends

Rationale: the reported "stops mid-sentence" bug is caused by finals arriving during natural pauses. With the mic staying open (no bot processing in between), a 1.2s VAD window cleanly separates "pause" from "done" using actual audio energy. `isFinal` is kept as a transcript-refresh signal only.

Trade-off: if the mic stops reporting (hardware issue) and only finals arrive, the timer will still fire 1.2s after the last partial/final and send — acceptable.

### 2. No auto-resume

Rationale: the user explicitly wants "when it responds it stops listening". One utterance per tap is the most predictable model and removes the record/playback session flapping that likely contributes to "response doesn't play".

### 3. Mic gating in UI

`ChatInputBar` gains `isVoiceLocked: Bool = false` (default keeps Homework/Exam call sites compiling). ChatView passes `engine.voiceState == .waitingForBot || engine.voiceState == .playingTTS`. Locked state: mic button `.disabled(true)` + reduced opacity. `toggleRecording` is additionally guarded engine-side by the `.idle` guard, so the two layers agree.

## Risks / Trade-offs

- Users who liked continuous listening lose it. Acceptable — it was the source of complaints.
- `waitingForBot` can be long (LLM latency); the disabled mic during that time is intentional and visible (Thinking... indicator already shows).
- The 1.2s VAD window is unchanged from the VAD change; tune in a follow-up only if users still report late/early cuts.

## Test Strategy

- Update existing voice-flow tests: after a voice-sent turn + bot reply + TTS, `startCount == 1` (no auto-resume) and `voiceState == .idle`.
- New: `isFinal` mid-utterance does not send; a following partial continues; VAD silence sends the whole sentence as one user message.
- New: `startRecording` during `.waitingForBot` / `.playingTTS` does nothing (`startCount` unchanged).
- Existing VAD + TranscriptTracker tests stay green.
