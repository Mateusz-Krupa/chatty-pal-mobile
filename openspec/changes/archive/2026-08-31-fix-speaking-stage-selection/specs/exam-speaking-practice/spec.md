## MODIFIED Requirements

### Requirement: Speaking task entry point
A campaign lesson whose learning goal requires spoken interaction SHALL show a clearly labelled speaking mission step after its relevant preparation activities. The step SHALL open a speaking practice screen for the task stage selected on that lesson's speaking mission card.

#### Scenario: User starts a selected speaking task stage
- **WHEN** the user selects a stage and starts the speaking step of a campaign lesson
- **THEN** the app opens the speaking practice screen with the lesson goal and that selected task stage visible

#### Scenario: Lesson without spoken goal
- **WHEN** a campaign lesson has no spoken-interaction goal
- **THEN** the lesson does not show a generic "Practice speaking" card
