# inline-text-correction Specification

## Purpose
Context-aware, minimal inline correction under learner messages in exam speaking practice; free chat keeps its teacher bubble.

## Requirements

### Requirement: Inline correction under learner message
During exam speaking practice, when a learner message has a correction, the app SHALL display that correction inline, associated with the learner's own message, rather than as a separate teacher bubble. The correction SHALL render the changed portion with the original word struck through and the corrected word highlighted.

#### Scenario: Learner message has a fixable error
- **WHEN** a learner sends a German message during exam speaking and the correction service returns a different corrected version
- **THEN** the app shows the correction attached to the learner's message with the original fragment struck through and the fix highlighted, and does not add a separate teacher message to the transcript

#### Scenario: Correction is visible on reload
- **WHEN** the learner reopens the same speaking stage that was already practiced
- **THEN** previously corrected learner messages still show their inline correction

### Requirement: No correction for correct messages
When the correction service returns text that is not meaningfully different from what the learner sent, the app SHALL NOT attach or display a correction for that message, in either exam or free-chat mode.

#### Scenario: Learner message is already correct
- **WHEN** a learner sends a message and the correction service returns the same text
- **THEN** the app does not attach a correction to that message and the transcript shows it unchanged

### Requirement: Context-aware correction request
The app SHALL include recent conversation context in the correction request so the model can resolve context-dependent errors such as noun gender and word choice. The request SHALL use a general model with an explicit proofreader instruction that returns only the corrected final learner message.

#### Scenario: Gender depends on an earlier mention
- **WHEN** the learner earlier mentions a feminine noun and then refers to it with a mismatched pronoun
- **THEN** the correction request includes that earlier mention and the returned correction uses the pronoun consistent with it

### Requirement: Free chat keeps teacher bubble
Free (non-exam) chat SHALL continue to present corrections as a separate teacher message bubble, unchanged by this capability.

#### Scenario: Free chat correction
- **WHEN** a learner sends a message in free chat and the correction service returns a different corrected version
- **THEN** the app appends a separate teacher message with the correction, as before
