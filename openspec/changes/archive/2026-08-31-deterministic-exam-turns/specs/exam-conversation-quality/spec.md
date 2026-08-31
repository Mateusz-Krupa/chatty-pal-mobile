## MODIFIED Requirements

### Requirement: Mission-appropriate bot response
For an exam mission, the bot SHALL respond in concise German at A1 level, remain in its assigned role, and continue the active task stage. It SHALL gently ask a learner who writes in English to try again in German. The examiner SHALL track facts the candidate has already provided in the conversation (name, origin, city, job or studies, family, hobbies, symptoms) and SHALL NOT ask again for information that the candidate already clearly stated; it SHALL briefly acknowledge it and move to the next unasked item. During the task, it SHALL NOT correct grammar, explain errors, or give feedback; it SHALL give corrections only when the learner explicitly requests the final feedback. The campaign client SHALL display a deterministic examiner greeting for each known lesson and stage before the learner's first answer. When the learner completes a task or requests feedback, the bot SHALL give a truthful practice assessment with a factual summary of what the learner said, one concrete strength, an example-by-example correction list (each entry quoting the learner's short original fragment and one minimal better alternative, up to 4 entries, most important first), a `PASS`, `BORDERLINE`, or `NOT YET PASS` verdict, and one concrete next improvement. The final feedback SHALL remain text-only and SHALL NOT be synthesized for playback. The assessment SHALL not claim to be an official Goethe result or invent learner statements.

#### Scenario: Practice turn before final feedback
- **WHEN** the learner gives an answer before requesting final feedback
- **THEN** the examiner continues the task without correction text or feedback in its own bubble, and the client shows an exam-ready A1 answer below the learner bubble

#### Scenario: New speaking stage
- **WHEN** the learner opens or refreshes a known campaign speaking stage
- **THEN** the client displays the stage's predefined examiner greeting before accepting the learner's first answer

#### Scenario: Final feedback requested
- **WHEN** the learner selects Finish & get feedback
- **THEN** the feedback remains visible as text and is not read through TTS
