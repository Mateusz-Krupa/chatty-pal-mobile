# chat-voice-input — Spec Delta

## MODIFIED Requirements

### Requirement: Silence window tuned to real audio
The silence window SHALL be 2.5 seconds, measured on audio energy: because barge-in makes a premature split self-healing (the learner can keep talking over the bot), the window can be longer to absorb the thinking pauses typical of language learners composing a sentence.

#### Scenario: Turn ends after 2.5s of silence
- **WHEN** the user stops producing audible speech while recording
- **THEN** the transcript is eligible to be sent no earlier than 2.5 seconds after that buffer

#### Scenario: Pause within the window does not end the turn
- **WHEN** the user stops producing audible speech for less than 2.5 seconds and then continues speaking
- **THEN** the silence timer restarts on the new voice activity and the full sentence is sent as one message
