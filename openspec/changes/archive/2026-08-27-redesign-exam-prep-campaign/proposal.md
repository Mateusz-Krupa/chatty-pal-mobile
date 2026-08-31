## Why

Exam Prep A1 currently presents a flat catalog that mixes vocabulary, grammar, exam tasks, and free-form speaking practice. Learners cannot see a clear route from their first lesson to exam readiness, while the existing voice chat and review features are underused as part of a coherent learning experience.

The app needs a guided, game-inspired Goethe A1 campaign: short complete missions in a fixed order, frequent evidence of progress, and exam-specific practice that feels approachable rather than like a content dump.

## What Changes

- Replace the flat Exam Prep section browser with a linear Goethe A1 campaign organized into ordered thematic zones, lessons, and checkpoint missions.
- Make each lesson a complete learning loop: clear can-do goal, focused preparation, interactive exercises, optional or required contextual speaking practice, and an outcome screen with recommended review.
- Align course content to the four Goethe A1 exam skills while keeping vocabulary and grammar as supporting material rather than presenting them as reading units.
- Add meaningful game-style progress: visible route, lesson status, earned stars, checkpoints, and a final full mock exam. Learners may revisit completed lessons but progress in order through the campaign.
- Make speaking practice context-aware for the active mission and verify its behavioral quality with deterministic request tests and a curated set of conversation scenarios.
- Preserve and integrate existing streaming chat, voice input, TTS, teacher feedback, word review, streaks, and local progress rather than replacing them.
- Refresh Exam Prep screens around the existing Chatty visual language so the course is polished, playful, accessible, and easy to operate on a phone.

## Capabilities

### New Capabilities
- `exam-campaign`: A fixed-order, game-inspired Goethe A1 course with zones, lessons, checkpoints, lesson unlocking, and campaign completion.
- `exam-mission-experience`: A focused lesson flow that combines preparation, exercises, contextual conversation, completion feedback, and review recommendations.
- `exam-conversation-quality`: Server-owned exam conversation modes and quality scenarios that ensure the bot remains helpful, concise, level-appropriate, and in the active exam role.

### Modified Capabilities
- `exam-prep`: Replace the flat section-first home experience with campaign navigation and correctly separate supporting vocabulary and grammar from exam skills.
- `exam-exercises`: Support lesson-scoped exercise sequencing, mastery outcomes, and checkpoint assessment behavior.
- `exam-speaking-practice`: Bind speaking sessions to explicit mission goals and Goethe A1 task stages rather than a generic free-form scenario.
- `exam-progress`: Persist campaign state, lesson completion, stars, checkpoints, and final mock-exam readiness alongside existing completion state.
- `word-review`: Add eligible lesson vocabulary to the existing word-review loop when a learner completes a mission.

## Impact

- iOS: `ExamA1Catalog.swift`, `ExamA1Content.swift`, `ExamPrepViews.swift`, `ChatEngine.swift`, chat views, local progress stores, and the existing word-review integration.
- Web backend: `src/pages/api/bot.ts` and related bot request contracts will need a controlled exam-conversation path and tests; the current duplicate user-message contract must be removed.
- Tests: expand existing iOS state/voice tests with campaign and mission tests, and add backend conversation-contract and scenario coverage.
- No new third-party dependency is required.
