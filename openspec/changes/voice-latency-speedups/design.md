# Design — voice-latency-speedups

## 1. Faster model (mobile-only)

`WhisperTranscriber.multipartBody` is called with `model: "whisper-1"`. Change the call site in `transcribe(wav:language:)` to `gpt-4o-mini-transcribe`. The web route (`transcriptions.ts`) forwards all form fields (`model`, `language`) verbatim to OpenAI, and the OpenAI transcriptions endpoint accepts `gpt-4o-mini-transcribe` with a `language` hint. No server change needed for the model itself.

Tests: `WhisperTranscriberTests` assert the model field — update expected value.

## 2. 16 kHz resample (mobile-only)

Mic input on iPhone is 44.1/48 kHz; speech is fully captured at 16 kHz (what Whisper/Deepgram natively use). Resampling before upload shrinks the WAV ~3×.

- New pure helper `WAVFile.resample(_ samples: [Float], from srcRate: Double, to dstRate: Double) -> [Float]` — linear interpolation:
  - `dstRate == srcRate` or trivial input → return as-is.
  - `outCount = Int((src.count - 1) * dst/src) + 1`; each output `i` maps to position `i * src/dst`, interpolating between the two source samples.
  - `dstRate > srcRate` (upsample) works with the same formula.
- `SpeechController.stopRecording()` builds the WAV from the resampled samples at 16 kHz (constant `WAVFile.targetSampleRate = 16000`), unless the captured rate is already ≤ 16 kHz (then no resample — avoid quality loss).
- SFSpeech still receives the original full-rate buffers (unchanged — live text quality unaffected).

Tests: resample length math, constant-signal preservation, downsample of a known ramp, identity at equal rates.

## 3. Shorter VAD window (mobile-only)

`ChatEngine` default `silenceWindow: 3.0 → 1.8`. Test harness passes its own value (0.05) so tests are unaffected. Spec delta updates the "Silence window tuned to real audio" requirement to 1.8s.

## 4. Skip server ffmpeg (web repo)

In `chatty-pal/src/pages/api/transcriptions.ts`: after parsing the multipart file, check the original file's content type / extension. If it is already one of OpenAI's accepted formats (`wav`, `mp3`, `m4a`, `webm`, `mp4`, `mpeg`, `flac`), forward the original temp file to OpenAI and skip the ffmpeg step entirely. Otherwise keep the existing ffmpeg→MP3 path (browser MediaRecorder webm/ogg still gets converted as before).

This is a separate OpenSpec change in the `chatty-pal` repo (`transcription-route-skip-ffmpeg`), implemented and committed there.

## Rollout / risk

- If `gpt-4o-mini-transcribe` is unavailable on the account, the route returns an error → mobile already falls back to the local SFSpeech transcript, so voice input degrades gracefully instead of breaking.
- 16 kHz is standard for speech; no quality risk for German A1 learners.
- 1.8s window: if users complain about cut-off turns, it is a one-constant rollback.
