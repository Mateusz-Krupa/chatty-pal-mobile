# conversations — Spec Delta

## ADDED Requirements

### Requirement: Conversation list

The app SHALL store each chat as a separate conversation (title, kind, language, level, messages, timestamps) and SHALL show them in a "My chats" list ordered by most recent activity. The main chat screen SHALL open the most recent conversation for the active language, and a "New chat" action SHALL start a fresh conversation.

#### Scenario: Reopen yesterday's chat
- **WHEN** the learner opens "My chats" and taps a previous conversation
- **THEN** the chat screen loads that conversation's messages

#### Scenario: Start fresh
- **WHEN** the learner taps "New chat"
- **THEN** a new empty conversation is created for the current language/level and the previous one is preserved in the list

### Requirement: Conversation title

A conversation's title SHALL default to "New chat" and SHALL become the learner's first message (truncated to 40 characters) after the first user message is sent.

#### Scenario: First message sets title
- **WHEN** the learner sends "How was your weekend?" as the first message
- **THEN** the conversation is listed as "How was your weekend?"

### Requirement: Legacy chat migration

Existing chat threads stored under the previous keys SHALL be imported once as conversations when the store first loads for an account.

#### Scenario: Upgrade migration
- **WHEN** a user with an old German B1 thread updates the app
- **THEN** "My chats" contains a "Chatty Pal" conversation (German B1) with that history and the legacy key is removed

### Requirement: Message cap

Each conversation SHALL keep at most the last 200 messages on save.

#### Scenario: Long conversation
- **WHEN** a conversation exceeds 200 messages
- **THEN** the oldest messages are dropped on save and the newest 200 are kept
