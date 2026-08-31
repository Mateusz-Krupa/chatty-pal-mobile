## MODIFIED Requirements

### Requirement: Automatic start
The speaking practice screen SHALL start its assigned task stage automatically by requesting the stage opening line when opened without existing history. When history for that stage exists, the screen SHALL resume it without requesting a duplicate opening line. The screen SHALL provide a Refresh chat action that clears the active stage history and requests a new opening line.

#### Scenario: Opening a fresh practice screen
- **WHEN** the speaking practice screen opens with no stored history for its stage
- **THEN** the app requests the stage-start response and the examiner responds without requiring a generic learner opening line

#### Scenario: Refreshing a resumed practice screen
- **WHEN** the learner refreshes a resumed speaking stage
- **THEN** the prior stage history is cleared and the examiner starts the stage again
