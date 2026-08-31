## MODIFIED Requirements

### Requirement: Mission-appropriate bot response
For an exam mission, the bot SHALL respond in concise German at A1 level, remain in its assigned role, and continue the active task stage. It SHALL gently ask a learner who writes in English to try again in German. The examiner SHALL track facts the candidate has already provided in the conversation (name, origin, city, job or studies, family, hobbies, symptoms) and SHALL NOT ask again for information that the candidate already clearly stated; it SHALL briefly acknowledge it and move to the next unasked item. When the learner completes a task or requests feedback, the bot SHALL give a truthful practice assessment with a factual summary of what the learner said, one concrete strength, an example-by-example correction list (each entry quoting the learner's short original fragment and one minimal better alternative, up to 4 entries, most important first), a `PASS`, `BORDERLINE`, or `NOT YET PASS` verdict, and one concrete next improvement. The assessment SHALL not claim to be an official Goethe result or invent learner statements.

#### Scenario: Learner requests detailed assessment
- **WHEN** the learner requests feedback after a speaking stage
- **THEN** the bot lists the learner's actual mistakes one by one, each as a quoted original fragment with a minimal better alternative

#### Scenario: Learner already stated a fact
- **WHEN** the candidate already stated their name, city, or job earlier in the conversation
- **THEN** the examiner does not ask for that information again and continues with the next unasked item
