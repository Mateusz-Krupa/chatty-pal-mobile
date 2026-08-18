# chat-voice-input — Spec Delta

## MODIFIED Requirements

### Requirement: Silence window tuned to real audio
The silence window SHALL be 1.8 seconds, measured on audio energy: long enough to absorb the thinking pauses typical of language learners composing a sentence, short enough that the conversation feels continuous.

#### Scenario: Turn ends after 1.8s of silence
- **WHEN** the user stops producing audible speech while recording
- **THEN** the transcript is eligible to be sent no earlier than 1.8 seconds after that buffer

#### Scenario: Pause within the window does not end the turn
- **WHEN** the user stops producing audible speech for less than 1.8 seconds and then continues speaking
- **THEN** the silence timer restarts on the new voice activity and the full sentence is sent as one message

### Requirement: Whisper transcription for voice input

The app SHALL transcribe recorded voice input with the OpenAI transcription API by posting the captured audio to the web app's existing `POST /api/transcriptions` endpoint (`model=gpt-4o-mini-transcribe` plus a language hint), using the same server-side key as the web app. The app SHALL NOT embed any OpenAI key.

#### Scenario: Chat voice turn is transcribed with Whisper
- **WHEN** the learner finishes a voice utterance in the chat and the recording was captured
- **THEN** the app posts the audio to `/api/transcriptions` with the fast transcribe model and sends the returned text to the bot

#### Scenario: Whisper failure falls back to the local transcript
- **WHEN** the transcription request fails or returns empty text
- **THEN** the app sends the local speech-recognition transcript instead, so voice input still works

## ADDED Requirements

### Requirement: Compact 16 kHz upload payload

The app SHALL resample the captured microphone audio to 16 kHz mono before building the WAV sent to the transcription endpoint, unless the captured rate is already 16 kHz or lower.

#### Scenario: High-rate capture is downsampled
- **WHEN** the microphone delivers 44.1 kHz audio
- **THEN** the uploaded WAV is 16 kHz mono and the transcription request succeeds

#### Scenario: Low-rate capture is untouched
- **WHEN** the microphone delivers 16 kHz or lower audio
- **THEN** the uploaded WAV uses the captured sample rate unchanged
