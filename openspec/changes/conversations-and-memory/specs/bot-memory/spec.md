# bot-memory — Spec Delta

## ADDED Requirements

### Requirement: Rolling learner summary

The app SHALL maintain a short per-language summary of the learner (interests, names, observations) regenerated every 15 user messages from the recent conversation, and SHALL inject it into the bot's system instruction as "ABOUT YOUR FRIEND".

#### Scenario: Memory refresh
- **WHEN** the learner sends their 15th message in a session with at least 8 messages of context
- **THEN** the app asks the bot for a short learner summary and stores it for that language

#### Scenario: Bot receives memory
- **WHEN** a stored summary exists for the active language
- **THEN** the bot's system instruction includes an "ABOUT YOUR FRIEND" section with that summary
