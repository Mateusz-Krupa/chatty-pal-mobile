# Design — voice-whisper-everywhere

## WAV capture (SpeechController)

`SpeechController` already taps the input node per `AVAudioPCMBuffer`. In that tap it will also append the buffer's raw float32 samples to an in-memory `Data` and remember the input format (sample rate, channel count). On `stopRecording()`:

- Stop engine + remove tap (as today).
- Convert captured float32 mono samples → Int16 little-endian (clamp [-1,1] → [-32768,32767]).
- Build a canonical 44-byte RIFF/WAVE header (PCM, 16-bit, mono, the captured sample rate) + payload.
- Return the finished `Data` (or `nil` if nothing was captured).

WAV is chosen over MP3 because iOS cannot natively encode MP3 and the OpenAI transcription API accepts WAV directly; it also matches what the web route's ffmpeg step handles fine (mp3 is only an internal re-encode there).

`stopRecording()` signature changes from `()` to `-> Data?`. `SpeechRecognition` protocol and the test double update to match.

## WhisperTranscriber

```swift
protocol AudioTranscribing {
    func transcribe(wav: Data, language: String) async throws -> String
}

struct WhisperTranscriber: AudioTranscribing {
    let baseURL: URL   // AppEnvironment.webBaseURL
    func transcribe(wav: Data, language: String) async throws -> String
}
```

- `POST {baseURL}/api/transcriptions`, `multipart/form-data`:
  - `file` = WAV bytes, filename `audio.wav`, `Content-Type: audio/wav`
  - `model` = `whisper-1`
  - `language` = language code (e.g. `de`)
- Header `Referer` = `{baseURL}/` (same pattern as `BotService`), so the route's `ALLOWED_ORIGIN` referer check passes.
- Decode `{"text": "..."}`; throw on non-2xx or missing `text`.
- No key in the app — the Next.js route adds `GPT_KEY` server-side, exactly like the web.

Pure helpers split out for testability: `multipartBody(...) -> (Data, contentType)` and `text(from:) -> String`.

## Chat flow (ChatEngine)

Keep everything (VAD, push-to-talk, hands-free resume) unchanged. The only change is what text gets sent:

- New dependency `transcriber: any AudioTranscribing` (live = `WhisperTranscriber(baseURL: AppEnvironment.webBaseURL)`).
- On end-of-utterance (VAD silence or manual stop): capture the WAV from `speech.stopRecording()`.
  - If a WAV is available: set `voiceState = .waitingForBot`, `await transcriber.transcribe(wav, language: persona.language.code)`, then `sendText(whisperText)`.
  - If transcription throws or returns empty: fall back to the local SFSpeech transcript (`sendTranscript(force:)`) so the user is never stuck.
- The on-screen live partial transcript during recording is still driven by SFSpeech (unchanged) — that is the "text appears as I speak" experience.

## Shared listening UI

New small view `ListeningIndicator(transcript: String, level: Float)` rendering the exact chat layout: transcript-or-"Listening..." label + red capsule level bar. Used by:
- `ChatView` (replaces the inline block).
- `ShadowingPhraseRow` (while recording).

## Shadowing flow

`ShadowingPhraseRow` records via its `SpeechController`. On stop:
- Show live transcript + level bar while recording (shared indicator).
- Build WAV, call `WhisperTranscriber(baseURL: AppEnvironment.webBaseURL).transcribe(wav, language: lessonLanguageCode)`.
- Score `ShadowingScorer.score(reference:, spoken: whisperText)`; on failure/empty fall back to the SFSpeech transcript.
- Keep the <60% → Word Review hook and stats recording.

Shadowing needs the lesson's language code (not just the speech locale) to hint Whisper. Pass it in.

## Testing

- `WAVFileTests`: header bytes (RIFF/WAVE, PCM fmt 1, 16-bit, mono), data size = 2 bytes/sample, empty input → nil.
- `WhisperTranscriberTests`: multipart body contains the boundary, file field with WAV bytes, model and language fields; `text(from:)` parses and rejects bad payloads.
- `ChatEngineTests`: bot receives the Whisper text on success; falls back to SFSpeech transcript when the transcriber throws; VAD/manual-stop still produce a send.
