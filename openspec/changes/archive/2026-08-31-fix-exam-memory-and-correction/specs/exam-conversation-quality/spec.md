## MODIFIED Requirements

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
