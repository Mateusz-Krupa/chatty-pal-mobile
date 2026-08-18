# Proposal — voice-latency-speedups

## Why

After moving voice input to Whisper, each voice turn gained a visible "transcribing" wait (upload + server ffmpeg + OpenAI call) on top of the 3.0s VAD silence window. The learner perceives the whole conversation as slower. Four targeted changes cut ~3–5s off every turn:

1. **Faster model** — `gpt-4o-mini-transcribe` instead of `whisper-1` (OpenAI's newer transcribe model: markedly faster, cheaper, equal-or-better accuracy). The web route forwards the `model` field verbatim, so this is a mobile-only change.
2. **Smaller upload** — resample the captured mic audio (44.1/48 kHz) to 16 kHz mono when building the WAV (~3× smaller payload).
3. **Shorter VAD window** — 3.0s → 1.8s of silence to end a turn (still learner-friendly, saves ~1.2s every single turn, works even offline).
4. **Skip server ffmpeg** — the web `/api/transcriptions` route re-encodes every upload to MP3 with ffmpeg even when the client already sends a ready-to-use format; with mobile now sending WAV, the route can pass it straight through to OpenAI.

## What changes

- Mobile: `WhisperTranscriber` default model, `SpeechController`/`WAVFile` 16 kHz resample, `ChatEngine` default `silenceWindow`.
- Web (separate OpenSpec change in `chatty-pal`): `src/pages/api/transcriptions.ts` skips ffmpeg when the incoming file is already a supported format.

## Impact

- Mobile files: `WhisperTranscriber.swift`, `WAVFile.swift` (+resample), `SpeechController.swift`, `ChatEngine.swift`, tests.
- Web files: `src/pages/api/transcriptions.ts`.
- Spec delta: `chat-voice-input` (silence window 3.0s → 1.8s; model name in Whisper requirement; new 16 kHz payload requirement).
- No new dependencies, no keys in the app.
