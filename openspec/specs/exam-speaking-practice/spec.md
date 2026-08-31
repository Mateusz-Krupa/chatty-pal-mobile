# exam-speaking-practice Specification

## Purpose
TBD - created by archiving change exam-prep-goethe-a1. Update Purpose after archive.
## Requirements
### Requirement: Speaking task entry point
A campaign lesson whose learning goal requires spoken interaction SHALL show a clearly labelled speaking mission step after its relevant preparation activities. The step SHALL open a speaking practice screen for the task stage selected on that lesson's speaking mission card.

#### Scenario: User starts a selected speaking task stage
- **WHEN** the user selects a stage and starts the speaking step of a campaign lesson
- **THEN** the app opens the speaking practice screen with the lesson goal and that selected task stage visible

#### Scenario: Lesson without spoken goal
- **WHEN** a campaign lesson has no spoken-interaction goal
- **THEN** the lesson does not show a generic "Practice speaking" card

### Requirement: Examiner persona
The speaking practice SHALL use a bot configured as the Goethe A1 oral-practice examiner. The persona SHALL drive the conversation using the lesson's explicit task stage, speak concise A1-level German, remain in the examiner role, and provide bounded encouraging feedback before continuing.

#### Scenario: Examiner follows the task stage
- **WHEN** the user completes the objective of an active speaking task stage
- **THEN** the bot acknowledges the response briefly and moves to the next defined stage or ends the mission when the final stage is complete

#### Scenario: User writes in English
- **WHEN** the user sends a message in English during practice
- **THEN** the bot responds in German and gently prompts the user to continue in German

### Requirement: Temporary conversation
Speaking practice conversations SHALL NOT be saved to the main chat history and SHALL start empty on every launch.

#### Scenario: Reloading a speaking task
- **WHEN** the user finishes a speaking task and later opens the same task again
- **THEN** the conversation starts fresh without previous messages

#### Scenario: Main chat unaffected
- **WHEN** the user returns to the main chat after a speaking task
- **THEN** the main chat history contains no messages from the speaking task

### Requirement: Automatic start
The speaking practice screen SHALL start its assigned task stage automatically by requesting the stage opening line when opened without existing history. When history for that stage exists, the screen SHALL resume it without requesting a duplicate opening line. The screen SHALL provide a Refresh chat action that clears the active stage history and requests a new opening line.

#### Scenario: Opening a fresh practice screen
- **WHEN** the speaking practice screen opens with no stored history for its stage
- **THEN** the app requests the stage-start response and the examiner responds without requiring a generic learner opening line

#### Scenario: Refreshing a resumed practice screen
- **WHEN** the learner refreshes a resumed speaking stage
- **THEN** the prior stage history is cleared and the examiner starts the stage again

### Requirement: User input and finish
The speaking practice screen SHALL allow the user to respond by voice (microphone) or by text using the shared chat input, and SHALL provide a "Finish practice" action that ends the session and returns to the unit.

#### Scenario: Voice response
- **WHEN** the user records a voice message during practice
- **THEN** the transcript is sent to the bot and the bot's spoken answer is played

#### Scenario: Finishing practice
- **WHEN** the user taps "Finish practice"
- **THEN** any active speech or generation is interrupted and the app returns to the unit detail

#### Scenario: Leaving the screen
- **WHEN** the user navigates away from the speaking practice screen
- **THEN** active TTS playback and bot generation are stopped

