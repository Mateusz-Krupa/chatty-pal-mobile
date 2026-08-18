# Proposal — voice-whisper-everywhere

## Why

The mobile app currently relies on Apple's on-device `SFSpeechRecognizer`, which is a dictation model tuned for fluent native speech and performs poorly on accented German (the learner's case). The web app already does better: it records the utterance and posts it to the Next.js `/api/transcriptions` route, which converts to MP3 (ffmpeg) and calls OpenAI `whisper-1` server-side (the OpenAI key never ships in the app). The mobile app talks to the same `chatty-pal.com` origin for the bot, so it can reuse the exact same endpoint.

Additionally, only the main chat shows the nice "Listening..." UI (red level bar + live transcript text as the user speaks). Shadowing shows a plain "Listening... say it now" line. The learner wants the same live listening experience everywhere voice input is possible.

## What changes

- `SpeechController` also captures raw PCM while recording and, on stop, builds a 16-bit mono WAV from the captured samples (no ffmpeg needed on device — WAV is accepted by the transcription API).
- New `WhisperTranscriber` service: POSTs the WAV as multipart to `{webBaseURL}/api/transcriptions` with `model=whisper-1`, a `language` hint, and the same `Referer` header the bot already sends. Returns the transcribed text. No API key in the app.
- **Chat**: SFSpeech stays live for the on-screen partial transcript, but the text actually sent to the bot becomes the Whisper transcription of the captured recording. On Whisper failure, fall back to the local SFSpeech transcript so voice input is never blocked.
- **Shadowing**: score against the Whisper transcription (falling back to SFSpeech). The shadowing row gets the same live listening UI as the chat — "Listening..." label, live transcript, red level bar — via a small shared `ListeningIndicator` view.

## Impact

- New files: `WAVFile.swift`, `WhisperTranscriber.swift`, `ListeningIndicator.swift` (+ `WAVFileTests.swift`, `WhisperTranscriberTests.swift`).
- Touched: `SpeechController.swift` (PCM capture + WAV export), `ChatEngineDependencies.swift` (new `AudioTranscribing` protocol + dependency), `ChatEngine.swift` (send Whisper text, fallback), `LearningViews.swift` (shadowing live UI + Whisper scoring), `ChatView.swift` (reuse shared indicator).
- No new dependencies, no key exposure, no backend change — reuses the existing web API route.
