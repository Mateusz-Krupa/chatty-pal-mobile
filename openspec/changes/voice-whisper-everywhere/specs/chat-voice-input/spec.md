# chat-voice-input — Spec Delta

## ADDED Requirements

### Requirement: Whisper transcription for voice input

The app SHALL transcribe recorded voice input with the OpenAI Whisper API by posting the captured audio to the web app's existing `POST /api/transcriptions` endpoint (`model=whisper-1` plus a language hint), using the same server-side key as the web app. The app SHALL NOT embed any OpenAI key.

#### Scenario: Chat voice turn is transcribed with Whisper
- **WHEN** the learner finishes a voice utterance in the chat and the recording was captured
- **THEN** the app posts the audio to `/api/transcriptions` and sends the returned text to the bot

#### Scenario: Whisper failure falls back to the local transcript
- **WHEN** the transcription request fails or returns empty text
- **THEN** the app sends the local speech-recognition transcript instead, so voice input still works

### Requirement: Shadowing uses Whisper transcription

The shadowing pronunciation score SHALL be computed from the Whisper transcription of the learner's attempt, falling back to the local speech-recognition transcript when Whisper is unavailable.

#### Scenario: Shadowing scores the Whisper transcript
- **WHEN** the learner finishes a shadowing attempt and transcription succeeds
- **THEN** the per-word score is computed from the Whisper transcript of the attempt

#### Scenario: Shadowing falls back to the local transcript
- **WHEN** the learner finishes a shadowing attempt and transcription fails
- **THEN** the score is computed from the local speech-recognition transcript
