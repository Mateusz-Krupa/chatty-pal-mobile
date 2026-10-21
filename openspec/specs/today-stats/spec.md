# today-stats Specification

## Purpose
TBD - created by archiving change learning-today-stats. Update Purpose after archive.
## Requirements
### Requirement: Activity recording

The app SHALL record review and shadowing activity locally: a review is counted once the learner grades a word and a shadowing attempt is counted once the learner finishes a recording with recognized speech. Lesson completion SHALL be taken from confirmed account-backed learning progress, not from opening practice. Existing local XP SHALL be preserved without uploading legacy completion flags as passed shadowing.

#### Scenario: Practice a lesson
- **WHEN** the learner taps "Practice in Chatty Pal" in a lesson
- **THEN** the app opens practice without marking the lesson completed solely because practice was opened

#### Scenario: Grade a word
- **WHEN** the learner grades a flashcard (Again/Good/Easy) in Word Review
- **THEN** the total review count increases by one and today is marked as an active day

#### Scenario: Finish a shadowing attempt
- **WHEN** the learner stops a shadowing recording after speaking
- **THEN** the total shadowing count increases by one and today is marked as an active day

### Requirement: Streak calculation

The streak SHALL be the number of consecutive active days ending today; a today with no activity yet SHALL NOT break the streak (the count starts from yesterday).

#### Scenario: Consecutive days
- **WHEN** the active days include today, yesterday, and the day before
- **THEN** the streak is 3

#### Scenario: Gap resets the streak
- **WHEN** the active days include today and yesterday but not the day before yesterday
- **THEN** the streak is 2

#### Scenario: Missing today keeps the streak
- **WHEN** the active days include yesterday and the day before, but not today
- **THEN** the streak is 2

#### Scenario: No activity
- **WHEN** there are no active days
- **THEN** the streak is 0

### Requirement: Today card on the home screen

The chat home screen SHALL show a "Today" card displaying the current streak, the number of due review words, and the counts of server-confirmed completed lessons and completed reviews. Tapping it SHALL navigate to Word Review.

#### Scenario: Card shows streak and due words
- **WHEN** the learner opens the app with a 3-day streak and 5 due words
- **THEN** the Today card shows the streak of 3 and a due indicator of 5

#### Scenario: Tap-through to review
- **WHEN** the learner taps the Today card
- **THEN** Word Review opens
