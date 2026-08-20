# chat-persona-prompt — Spec Delta

## ADDED Requirements

### Requirement: Honest and short bot replies

The main chat persona instruction SHALL NOT tell the bot to invent answers; it SHALL instruct the bot to admit unknowns simply and change topic, and to keep replies to at most 2 short sentences so the learner gets speaking time.

#### Scenario: Bot unsure of an answer
- **WHEN** the learner asks something the bot cannot answer
- **THEN** the persona instruction directs the bot to say so simply in the target language and move the conversation on

#### Scenario: Voice conversation pacing
- **WHEN** the bot replies in a voice conversation
- **THEN** its reply is at most two short sentences per the persona instruction
