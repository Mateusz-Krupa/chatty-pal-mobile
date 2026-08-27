## ADDED Requirements

### Requirement: Final speaking feedback
Campaign speaking practice SHALL request examiner feedback when the learner taps Finish practice, before allowing the learner to close the screen. The request SHALL not insert a synthetic learner message bubble into the visible transcript.

#### Scenario: Learner requests feedback
- **WHEN** the learner taps Finish practice during a speaking stage
- **THEN** the examiner returns an assessment as the final visible conversation message and the learner can then close practice

### Requirement: Structured factual feedback
The examiner assessment SHALL identify what the learner actually said, one concrete strength, one or two minimal contextual improvements, an honest PASS / BORDERLINE / NOT YET PASS practice verdict, and one next improvement. It SHALL not invent statements or present an official Goethe result.

#### Scenario: Learner made a grammatical error
- **WHEN** the learner requests feedback after an answer with a correctable grammatical error
- **THEN** the examiner shows the learner's intended statement and a minimal corrected alternative rather than rewriting the entire answer
