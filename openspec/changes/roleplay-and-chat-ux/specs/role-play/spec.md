# role-play — Spec Delta

## ADDED Requirements

### Requirement: Role-play scenario catalog

The app SHALL list global role-play scenarios from the CMS (situation name + prompt) for signed-in students. If the CMS is unreachable, the app SHALL fall back to the last cached list; if none is cached, it SHALL show an error with retry.

#### Scenario: Open Role Play
- **WHEN** a signed-in student opens "Role Play"
- **THEN** the app shows the CMS global situations as tappable cards

#### Scenario: CMS offline with cache
- **WHEN** the CMS request fails and a cached list exists
- **THEN** the cached list is shown

### Requirement: Role-play conversation and result

Starting a scenario SHALL create a role-play conversation (titled with the situation name) where the bot plays the scenario in the learner's language/level. Finishing SHALL show a result card with the learner's message count, teacher correction count, and award +100 XP exactly once.

#### Scenario: Play and finish
- **WHEN** the learner starts "At the café", chats, and taps "Finish role play"
- **THEN** a result card shows their stats, +100 XP is awarded once, and the conversation remains in "My chats"
