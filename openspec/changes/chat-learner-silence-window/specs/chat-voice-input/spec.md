## MODIFIED Requirements

### Requirement: Silence window tuned to real audio
The silence window SHALL be 3.0 seconds, measured on audio energy, to absorb the thinking pauses typical of language learners composing a sentence.

#### Scenario: Timing of the end-of-speech decision
- **WHEN** the last voice-above-threshold buffer arrives during recording
- **THEN** the transcript is eligible to be sent no earlier than 3.0 seconds after that buffer

#### Scenario: Learner pauses to think mid-sentence
- **WHEN** the user stops producing audible speech for less than 3.0 seconds and then continues speaking
- **THEN** the silence timer restarts on the new voice activity and the full sentence is sent as one message
