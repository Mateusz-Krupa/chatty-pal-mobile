# shadowing Specification

## Purpose
TBD - created by archiving change learning-shadowing. Update Purpose after archive.
## Requirements
### Requirement: Shadowing practice in lessons
Each lesson detail SHALL provide a "Shadowing: Listen & Repeat" section where the user hears a phrase, records themselves, and receives per-word feedback.

#### Scenario: Hearing a phrase
- **WHEN** the user taps the speaker on a shadowing phrase
- **THEN** the app speaks the phrase via TTS

#### Scenario: Recording and getting feedback
- **WHEN** the user taps the mic, speaks, and taps the mic again
- **THEN** the app shows a percent score and the reference words colored by match (matched vs unmatched)

#### Scenario: Empty or failed recording
- **WHEN** the user stops recording with no recognized speech
- **THEN** no score is shown and nothing is added to the review queue

### Requirement: Weak phrases feed the review queue
Shadowing results below 60 percent SHALL automatically add the whole phrase to the word review queue.

#### Scenario: Low shadowing score
- **WHEN** the user's shadowing score for a phrase is below 60 percent
- **THEN** the phrase is added to the word review queue and the row shows a note that it was added

#### Scenario: Good shadowing score
- **WHEN** the user's shadowing score is 60 percent or higher
- **THEN** nothing is added to the review queue

### Requirement: Testable word matching
The shadowing scorer SHALL be a pure function that aligns reference words with spoken words, so it is unit-testable without a microphone.

#### Scenario: Word missing in speech
- **WHEN** the spoken transcript lacks one reference word
- **THEN** that word is reported unmatched and the percent score drops accordingly

#### Scenario: Extra filler words in speech
- **WHEN** the spoken transcript contains extra words not in the reference
- **THEN** all reference words that are present are still reported matched

### Requirement: Account-backed shadowing progress
The app SHALL save signed-in learners' transcripts and word-match scores through the authenticated CMS API and restore server-confirmed phrase completion at 80 percent or higher. It MUST distinguish word matching from phonetic pronunciation assessment and immediate feedback from confirmed saved completion.

#### Scenario: Reopen a passed phrase
- **WHEN** a learner reopens a phrase with a saved score of at least 80 percent in the current reset generation
- **THEN** the app SHALL show a green passed check, the best saved score and latest saved transcript

#### Scenario: Failed save
- **WHEN** the API cannot acknowledge an attempt
- **THEN** the app SHALL retain the account-scoped pending attempt and show an explicit retry state without inventing a saved completion

### Requirement: Manual lesson completion and reset
The app SHALL provide Mark as done for an incomplete lesson and confirmed Reset progress for a completed lesson. Manual completion MUST NOT create phrase scores. Reset SHALL clear only current lesson completion and phrase passes while preserving server history, other lessons, XP and language level.

#### Scenario: Manual completion
- **WHEN** Mark as done is acknowledged by the server
- **THEN** the lesson SHALL show green completion with a manual completion label

#### Scenario: Reset confirmation
- **WHEN** a learner confirms Reset progress and the server acknowledges the operation
- **THEN** the lesson SHALL show incomplete current progress without restoring passes from old attempts

### Requirement: Case-independent spoken word matching
Shadowing scoring SHALL normalize both reference and recognized speech using Unicode case-insensitive folding, including German ß/SS expansions. Case-only differences MUST NOT lower the score or mark words unmatched. Normalization MUST preserve diacritics and MUST NOT modify the raw transcript retained for persistence.

#### Scenario: Uppercase and mixed-case speech
- **WHEN** reference and recognized speech differ only in uppercase, lowercase or mixed-case letters
- **THEN** the score SHALL be 100 percent and all words SHALL match

#### Scenario: German sharp S case expansion
- **WHEN** reference contains heißt or Straße and recognized speech contains HEISST or STRASSE respectively
- **THEN** their normalized tokens SHALL be identical and all reference words SHALL match

#### Scenario: Meaningful differences retained
- **WHEN** normalization processes umlauts and genuinely different words
- **THEN** it SHALL retain umlauts and existing scoring SHALL still mark genuinely different words unmatched
