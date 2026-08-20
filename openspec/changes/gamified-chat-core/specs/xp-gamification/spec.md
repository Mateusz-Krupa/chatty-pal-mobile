# xp-gamification — Spec Delta

## ADDED Requirements

### Requirement: XP accrual

The app SHALL award XP for learning events: user chat message +5, word-review grading +25, lesson practice +50, shadowing attempt +10. XP SHALL persist per account and be shown with the user's level.

#### Scenario: Practice chat
- **WHEN** the learner sends a chat message (text or voice)
- **THEN** their XP increases by 5 and the message counter increases

#### Scenario: Level growth
- **WHEN** a learner has 450 XP
- **THEN** they are on level 3 with 50 XP toward level 4 (level = 1 + xp/200)

### Requirement: Daily quest

The app SHALL present a daily quest "Earn 50 XP today" with live progress. Completing it SHALL grant a one-time +25 bonus XP per day.

#### Scenario: Quest completed
- **WHEN** the learner's XP earned today reaches 50 for the first time
- **THEN** they receive +25 bonus XP and the quest shows as completed

#### Scenario: Next day resets
- **WHEN** a new day starts
- **THEN** the quest progress resets to 0/50

### Requirement: Weekly recap

The today card SHALL show a one-line weekly recap (messages sent, reviews, XP earned in the last 7 days).

#### Scenario: Recap row
- **WHEN** the learner opens the chat screen
- **THEN** the today card shows a compact "This week" line with those numbers
