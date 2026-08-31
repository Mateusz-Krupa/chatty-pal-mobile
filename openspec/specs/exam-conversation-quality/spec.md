# exam-conversation-quality Specification

## Purpose
exam-conversation-quality requirements (synced from redesign-exam-prep-campaign).
## Requirements
### Requirement: Exam conversation contract
The exam conversation API SHALL accept an explicit exam mode, lesson identifier, task stage, learner message, and one non-duplicated conversation history. The server SHALL own the authoritative instruction for each exam mode.

#### Scenario: Learner sends one conversation turn
- **WHEN** the learner sends a message during an exam mission
- **THEN** the model receives that learner message exactly once in the constructed conversation history

#### Scenario: Client supplies an exam mode
- **WHEN** the client requests an exam-speaking turn for a known lesson and task stage
- **THEN** the server applies the matching exam instruction rather than accepting a client-provided persona as authoritative

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

### Requirement: Conversation quality scenarios
The project SHALL maintain curated conversation scenarios for each supported exam mode and evaluate role adherence, A1 language, task continuation, response length, and English handling before changing the exam conversation contract or prompt.

#### Scenario: Contract test runs
- **WHEN** a developer runs the exam conversation contract test suite
- **THEN** deterministic provider fixtures verify the request shape and expected state transitions without calling a live model

#### Scenario: Live-model evaluation runs
- **WHEN** a configured live-model evaluation is run against the scenario set
- **THEN** each response is recorded with the scenario identifier and pass/fail rubric results for human review

### Requirement: Full mission conversation history
The exam conversation API SHALL receive the full conversation history of the current session from the client and SHALL keep the most recent 20 conversation messages (plus the server-owned system instruction and the current learner message) when constructing the model request. The client SHALL send every user and assistant turn of the session, in order, with explicit roles, and SHALL NOT truncate the conversation history on the device. In exam mode the API SHALL preserve a leading assistant opener from the kept window so the model can see the examiner's seeded opening line; the orphan-reply drop (removing a leading assistant whose matching user turn was cut) applies only to non-exam conversations.

#### Scenario: Long mission keeps early learner turns
- **WHEN** a learner has exchanged more than 10 turns in one speaking mission and sends another message
- **THEN** the model request contains the 20 most recent conversation messages before the current learner message

#### Scenario: Learner answers stay attributed
- **WHEN** the learner gives several answers earlier in the same mission
- **THEN** each answer that falls inside the kept window is visible to the model with role "user" and the examiner replies with role "assistant"

#### Scenario: Client sends the full session history
- **WHEN** the mobile client sends a message during an exam mission
- **THEN** its `messages` payload contains every user and assistant turn of the session except the in-flight learner turn, without a device-side length cap

#### Scenario: Seeded examiner opener is preserved
- **WHEN** a fresh exam mission's only prior history is the client-seeded examiner greeting (a leading assistant turn) and the learner sends their first message
- **THEN** the model request includes that greeting as an assistant turn so the examiner continues from it instead of introducing itself again

#### Scenario: Non-exam capped window does not start with an orphan reply
- **WHEN** a non-exam 20-message window begins with an assistant message whose matching user turn fell outside the window
- **THEN** the API drops that leading assistant message before sending the request to the model

