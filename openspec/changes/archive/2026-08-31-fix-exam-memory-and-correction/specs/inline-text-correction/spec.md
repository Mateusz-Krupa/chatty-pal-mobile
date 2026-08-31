## MODIFIED Requirements

### Requirement: Context-aware correction request
The app SHALL include recent conversation context in the correction request so the model can resolve context-dependent errors such as noun gender and word choice. The request SHALL use a general model with an explicit proofreader instruction that returns only the corrected final learner message. In exam speaking mode the correction SHALL be a stage-aware rewrite of the learner's own last utterance into a single correct, natural A1 response that fits the current task stage; it SHALL preserve the learner's intended meaning and SHALL NOT answer on the examiner's behalf or extend the examiner's line.

#### Scenario: Gender depends on an earlier mention
- **WHEN** the learner earlier mentions a feminine noun and then refers to it with a mismatched pronoun
- **THEN** the correction request includes that earlier mention and the returned correction uses the pronoun consistent with it

#### Scenario: Exam correction rewrites the learner's own utterance
- **WHEN** the learner answers an examiner question during a speaking stage and the exam-ready correction is requested
- **THEN** the returned inline text is a corrected, natural A1 version of the learner's own answer to that question, fitting the active stage, and not a continuation or replacement of the examiner's line

#### Scenario: Exam correction respects the current stage
- **WHEN** the active stage requires the learner to ask questions or describe a picture rather than answer a question
- **THEN** the correction request includes that stage so the rewritten learner text matches the expected task type instead of defaulting to "answer the examiner's question"
