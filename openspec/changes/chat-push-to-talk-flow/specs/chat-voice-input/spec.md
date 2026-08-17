## ADDED Requirements

### Requirement: Push-to-talk flow
The chat voice input SHALL follow a one-utterance-per-tap model: the microphone opens only when the user taps the mic button while idle, and it SHALL stay closed while the bot is waiting for a response, generating it, or playing it back.

#### Scenario: User starts listening
- **WHEN** the user taps the mic button while the chat is idle
- **THEN** recording starts and the listening bar with the live level indicator is shown

#### Scenario: User taps the mic while it is recording
- **WHEN** the user taps the mic button while recording
- **THEN** recording stops, the accumulated transcript is sent, and the bot flow starts

#### Scenario: User taps the mic during the bot turn
- **WHEN** the user taps the mic button while the bot is waiting for a response, thinking, or playing its answer
- **THEN** nothing happens, recording does not start, and the mic button appears disabled

#### Scenario: Bot response finishes
- **WHEN** the bot's text response finishes playing (or TTS is disabled and the reply is appended)
- **THEN** the chat returns to idle and the microphone stays closed until the user taps the mic again

### Requirement: One utterance per turn
A single recorded turn SHALL be sent as one user message. A recognition `isFinal` event SHALL refresh the shown transcript but SHALL NOT end the turn; the turn ends only when the VAD silence window expires or the user taps the mic manually.

#### Scenario: Recognizer emits a final mid-sentence
- **WHEN** an `isFinal` result arrives while the user is still speaking (a pause longer than the recognizer's internal gap)
- **THEN** no message is sent, the microphone keeps recording, and the transcript continues to accumulate

#### Scenario: User finishes the sentence
- **WHEN** the user stops speaking and audio energy stays below the voice threshold for the silence window
- **THEN** the complete accumulated transcript is sent as a single user message
