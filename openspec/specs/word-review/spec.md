# word-review Specification

## Purpose
TBD - created by archiving change learning-word-review. Update Purpose after archive.
## Requirements
### Requirement: Spaced repetition scheduling
The app SHALL schedule vocabulary review using a five-box Leitner system. A word's box determines its review interval: box 1 = 10 minutes, box 2 = 1 day, box 3 = 3 days, box 4 = 7 days, box 5 = 14 days.

#### Scenario: Grading a word good
- **WHEN** the user grades a word "Good"
- **THEN** the word moves up one box (maximum 5) and its review is scheduled now plus that box's interval

#### Scenario: Grading a word again
- **WHEN** the user grades a word "Again"
- **THEN** the word returns to box 1 and is due again in 10 minutes

#### Scenario: Grading a word easy
- **WHEN** the user grades a word "Easy"
- **THEN** the word moves up two boxes (maximum 5) and its review is scheduled now plus that box's interval

### Requirement: Automatic word collection
The review queue SHALL be filled automatically from learning and completed campaign content; the user SHALL NOT need to add words manually. A campaign lesson SHALL add its eligible vocabulary and phrases after the learner completes its mission, rather than merely opening preparation content.

#### Scenario: Opening a non-campaign lesson
- **WHEN** the user opens a non-campaign lesson's detail or starts its practice
- **THEN** the lesson's vocabulary and phrases are added to the review queue

#### Scenario: Completing a campaign lesson
- **WHEN** the user completes an Exam Prep campaign lesson
- **THEN** the lesson's eligible vocabulary and phrases are added to the review queue

#### Scenario: Replaying a completed campaign lesson
- **WHEN** the user completes a campaign lesson that has already added its vocabulary to the review queue
- **THEN** the existing cards and their schedules are preserved

#### Scenario: Duplicate word from two sources
- **WHEN** the same German word is added from two different sources
- **THEN** only one card exists and its existing schedule is preserved
### Requirement: Word review session
The app SHALL provide a "Word Review" screen reachable from the Student section of the menu, showing due words as flashcards.

#### Scenario: Reviewing a due word
- **WHEN** the user opens Word Review while words are due
- **THEN** the first card shows the German word with an option to hear it, and tapping the card reveals the English meaning

#### Scenario: Session limit
- **WHEN** more than 20 words are due
- **THEN** the session offers at most 20 words, most overdue first, and the rest remain due for the next session

#### Scenario: Nothing due
- **WHEN** the user opens Word Review with no words due
- **THEN** the screen shows an "all caught up" empty state

#### Scenario: Menu badge
- **WHEN** words are due
- **THEN** the Word Review menu row shows a badge with the due count

