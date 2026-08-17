# exam-writing Specification

## Purpose
TBD - created by archiving change exam-prep-goethe-a1. Update Purpose after archive.
## Requirements
### Requirement: Writing prompt display
A unit that has a writing prompt SHALL show a "Schreiben" card in its detail screen with the exam prompt (task description, formal requirements such as length, and any bullet points the user must cover).

#### Scenario: User opens a writing unit
- **WHEN** the user opens a unit that has a writing prompt
- **THEN** the Schreiben card shows the prompt text and an editable text area for the answer

#### Scenario: Unit without prompt
- **WHEN** a unit has no writing prompt
- **THEN** the unit detail does not show a Schreiben card

### Requirement: Writing answer correction
The app SHALL allow the user to submit their writing answer for correction. The correction SHALL be produced by the existing teacher-fix endpoint with a prompt that frames the answer as a Goethe A1 exam writing task, and SHALL be displayed below the text area.

#### Scenario: Successful correction
- **WHEN** the user taps "Check my writing" with non-empty text
- **THEN** the app sends the answer with the writing-exam prompt to the teacher endpoint and displays the correction feedback below the text

#### Scenario: Empty answer
- **WHEN** the user taps "Check my writing" with empty text
- **THEN** the app does not send a request and prompts the user to write something first

#### Scenario: Request failure
- **WHEN** the correction request fails (network error or authentication error)
- **THEN** the app shows an error message, keeps the user's text in the editor, and allows retrying

### Requirement: A1-level writing tasks
The catalog SHALL contain writing units covering the Goethe A1 writing formats: informal message (e.g., Kurze Nachricht), formal letter/application (e.g., Bewerbung or formelle Nachricht), each with an explicit word-count requirement at A1 level.

#### Scenario: Writing formats coverage
- **WHEN** the app loads the exam catalog
- **THEN** at least one writing unit covers an informal message and at least one covers a formal text

