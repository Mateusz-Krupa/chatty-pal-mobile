## Why

The examiner currently generates its first greeting through the model, requests an inline teacher correction after every learner turn, and queues the final feedback for TTS. This makes the welcome inconsistent, interrupts practice with corrections, and unnecessarily reads a long feedback message aloud.

## What Changes

- Seed each campaign speaking stage with a deterministic, role-appropriate examiner greeting instead of a model-generated opening.
- Show an inline exam-ready A1 answer below each learner bubble, based on the latest examiner question and learner facts; keep examiner bubbles focused on conducting the task.
- Do not synthesize or play the final exam-feedback response.
- Tell the server examiner prompt not to correct language during the task.

## Impact

- Mobile: `ChatEngine.swift`, `ExamCampaignViews.swift`, and tests.
- Backend: `src/pages/api/exam.ts` and instruction tests; deploy required.
