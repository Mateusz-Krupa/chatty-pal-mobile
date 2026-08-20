# chat-ux-assists — Spec Delta

## ADDED Requirements

### Requirement: Quick-reply suggestions

After a complete bot reply, the app SHALL show up to 3 tappable suggested follow-up messages below the chat; tapping one SHALL send it as the learner's message. Suggestions SHALL be cleared when the learner sends any message or starts recording.

#### Scenario: Suggestion tap
- **WHEN** the bot finishes a reply and the learner taps a suggestion chip
- **THEN** the chip text is sent as a learner message and the chips are cleared

#### Scenario: No valid suggestions
- **WHEN** the bot's suggestion response cannot be parsed as a JSON array of strings
- **THEN** no chips are shown (the chat is unaffected)

### Requirement: Inline correction diff

Teacher corrections SHALL be displayed as a word-level diff of the learner's original sentence: changed words struck through, corrected words highlighted, in the teacher bubble.

#### Scenario: Corrected sentence
- **WHEN** the learner writes "Ich hab gut geschlafen" and the teacher returns "Ich habe gut geschlafen"
- **THEN** the teacher bubble shows "hab" struck through and "habe" highlighted
