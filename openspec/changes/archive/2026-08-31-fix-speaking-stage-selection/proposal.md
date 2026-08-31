## Why

Selecting a speaking stage on the exam lesson card has no effect when practice starts: the screen always opens the first stage. Learners therefore cannot deliberately begin the family-speaking exercise or any other selected stage.

## What Changes

- Pass the stage selected on a speaking mission card into the speaking practice screen.
- Start the chat, greeting, and stage-specific storage with that selected stage.
- Add regression coverage for launching a non-first stage.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `exam-speaking-practice`: A speaking task starts the stage selected before navigation.

## Impact

- `chatty-pal/ExamCampaignViews.swift`
- `chatty-palTests/ExamCampaignFlowTests.swift`
