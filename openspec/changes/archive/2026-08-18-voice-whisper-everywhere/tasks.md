# Tasks — voice-whisper-everywhere

- [x] 1.1 `WAVFile.swift` (pure: float32 mono → 16-bit WAV Data) + `WAVFileTests.swift` (pbxproj 51/52, 53/54)
- [x] 1.2 `SpeechController`: capture PCM in tap, `stopRecording() -> Data?` WAV; update `SpeechRecognition` protocol + test double
- [x] 1.3 `WhisperTranscriber.swift` (multipart POST to /api/transcriptions, Referer, no key) + `WhisperTranscriberTests.swift` (pbxproj 55/56, 57/58)
- [x] 2.1 `ChatEngineDependencies`: `AudioTranscribing` protocol + `transcriber` dependency (live = WhisperTranscriber)
- [x] 2.2 `ChatEngine`: on end-of-utterance send Whisper text (waitingForBot while transcribing), fallback to SFSpeech transcript
- [x] 3.1 `ListeningIndicator.swift` shared view (pbxproj 59/60); use in `ChatView` + `ShadowingPhraseRow`
- [x] 3.2 Shadowing: live UI while recording, Whisper scoring with fallback, pass lesson language code
- [x] 4.1 Build + full test suite green (update ChatEngineTests for transcriber)
- [x] 4.2 Commit + archive
