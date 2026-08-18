# Tasks — voice-latency-speedups

- [x] 1.1 `WhisperTranscriber`: model `whisper-1` → `gpt-4o-mini-transcribe` + test update
- [x] 1.2 `WAVFile.resample` (pure linear interpolation) + resample tests
- [x] 1.3 `SpeechController`: build WAV from 16 kHz-resampled samples (skip if rate ≤ 16k)
- [x] 2.1 `ChatEngine`: default `silenceWindow` 3.0 → 1.8
- [x] 3.1 Web repo `chatty-pal`: OpenSpec change + `transcriptions.ts` skips ffmpeg for already-supported formats (wav etc.)
- [x] 4.1 Build + full test suite green
- [x] 4.2 Commit (mobile + web) + archive both OpenSpec changes
