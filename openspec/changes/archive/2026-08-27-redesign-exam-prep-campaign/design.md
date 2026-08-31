## Context

The iOS app already has a static Goethe A1 catalog, exercises, TTS, a transient speaking chat, writing correction, local completion state, a Leitner word-review queue, streaks, and a mature voice-chat engine. The current Exam Prep presentation is section-first and flat: vocabulary and grammar items are currently assigned to `Lesen`, while a unit may expose all of its content in one long detail view.

`ChatEngine` owns the mobile voice experience, including streaming, speech recognition, TTS, barge-in, teacher correction, and reply suggestions. The web `/api/bot` endpoint is a thin proxy to a chat-completions model. It currently accepts client-composed history and appends the submitted user message again, which can duplicate the latest turn. Existing tests cover chat and voice mechanics but not conversational quality against exam scenarios.

The change introduces a campaign without replacing these working foundations. It targets German A1 and Goethe A1 task practice first; it does not attempt to become a multi-language course platform.

## Goals / Non-Goals

**Goals:**

- Turn Exam Prep into a fixed-order campaign of short, complete, phone-friendly lessons.
- Make vocabulary, grammar, exercises, speaking, and review serve a named lesson objective.
- Preserve the existing Chatty visual language while making progress feel like a game campaign: zones, missions, checkpoints, stars, and a final mock exam.
- Make exam speaking behavior controlled by an explicit mission contract and verifiable with scenario tests.
- Keep existing chat, TTS, voice, teacher feedback, word review, and local progress working throughout migration.

**Non-Goals:**

- Rebuild the general Chatty Pal conversation experience in this change.
- Add a new third-party gamification, analytics, or learning-management dependency.
- Replicate or redistribute proprietary Goethe course material; all new content will be original while matching public A1 skill and task formats.
- Require login or server persistence for campaign progress in the first release.
- Produce a production score that claims to be an official Goethe result.

## Decisions

### 1. Model Exam Prep as a campaign, not a list of section-tagged units

Introduce a campaign model with an explicit `order`, `zone`, `lesson`, `checkpoint`, prerequisite state, and final mock-exam node. A lesson owns its goal, supporting vocabulary/grammar, exercises, speaking task when applicable, and completion rules. The course home renders this ordered route rather than deriving navigation exclusively from `ExamSection`.

Six thematic zones will provide a sensible initial route: first contact, everyday life, shopping and services, practical travel/appointments, exam skills, and final preparation. Exact content remains data-driven so it can grow beyond the initial path.

Alternative considered: keep the four exam-section cards and add more categories. This would organize material but still leave a learner to decide an effective sequence. The campaign meets the fixed-order requirement and gives checkpoints a clear purpose.

### 2. Keep vocabulary and grammar as lesson support, with separately truthful labels

Vocabulary and grammar remain first-class content but are no longer represented as reading units. The lesson interface can expose them as preparation tabs or steps; the catalog retains an exam-skill classification only for material that actually exercises Lesen, Hören, Schreiben, or Sprechen.

Alternative considered: create separate, free-browse Vocabulary and Grammar campaign branches. This would recreate the content-dump problem. Supporting material belongs to the mission that uses it, while word review remains the cross-course revision surface.

### 3. Use one focused mission flow per lesson

Each lesson follows the same progression: mission briefing and can-do goal, concise preparation, guided practice, an exam-style task, contextual conversation when relevant, then a completion screen. The flow uses small steps and clear progress rather than a scroll view containing every possible content type.

Completion records both finishing state and earned stars. Stars are evidence of activity and mastery, not a hard gate: a learner may continue after completing the core mission and can replay it to improve. Checkpoints require completion of prior missions but permit retries without punishment.

Alternative considered: make every lesson mandatory and require a passing score to unlock the next one. This risks trapping beginners; fixed order is useful, but mandatory perfect performance is not.

### 4. Reuse existing mobile primitives and visual language

The campaign will reuse `ChattyTheme`, existing card styling, `ExamTTS`, `ChatEngine`, `TransientChatStore`, `WordReviewStore`, `LearningStatsStore`, and `ExamProgressModel` as much as possible. New presentation is a route/map and mission-state layer above those primitives, not a separate design system.

The game-inspired vocabulary is limited to comprehensible learning metaphors: zones, missions, stars, checkpoints, and a final mock exam. It will not add unrelated currencies, loot boxes, countdown pressure, or decorative mechanics that conceal learning state.

### 5. Treat bot behavior as an API contract with testable scenarios

The client will send an exam conversation mode, active lesson identifier, task stage, and latest learner turn. The server will own the authoritative system instructions for exam modes, construct one non-duplicated conversation history, and return a typed response containing the assistant text plus optional mission-state metadata.

The first contract will support concise A1 German, role consistency, task-stage continuation, graceful English handling, and bounded feedback. Curated scenario fixtures will test these rules through a deterministic fake provider and, separately, a manually or scheduled live-model evaluation. Existing streaming remains the delivery mechanism.

Alternative considered: only tune the existing prompt in `ChatEngine`. This cannot reliably fix client/server history inconsistencies or provide a stable quality gate before prompt/model changes.

### 6. Preserve local progress and migrate it safely

Campaign state extends the existing UserDefaults-backed completion model. Existing completed `ExamUnit` identifiers remain recognized and map to their corresponding migrated lessons where possible. Unknown or removed identifiers are retained but ignored in visible campaign counts. A versioned progress payload allows adding checkpoint and star state without losing earlier completion data.

Alternative considered: reset all existing Exam Prep progress. This is simpler, but it discards user effort and is unnecessary for a local migration.

## Risks / Trade-offs

- [A large content rewrite delays visible product value] → Deliver one complete zone and one checkpoint as the reference vertical slice before migrating the full catalog.
- [Fixed order feels restrictive to experienced learners] → Show the route and lock forward missions until prerequisites are complete, but always allow replay of unlocked material and word review independently.
- [Gamification can become visually noisy or childish] → Use progression only to communicate learning state; validate the design on small screens and with Dynamic Type.
- [LLM output is variable] → Use concise server-owned contracts, scenario fixtures, response bounds, and a fallback/error state rather than relying on an untested prompt.
- [Moving prompts server-side can change existing behavior] → Scope the new contract to exam modes first and retain existing general-chat behavior.
- [Legacy completion data does not map perfectly to the new campaign] → Preserve source identifiers, map known ones explicitly, and never delete stored progress during migration.
- [Additional server calls affect perceived latency] → Keep existing streaming for the main response and make optional feedback or suggestions non-blocking.

## Migration Plan

1. Add the campaign data model and versioned local progress reader that understands existing completed unit IDs.
2. Build the campaign home and one complete lesson/checkpoint path behind the Exam Prep entry point; validate rendering, VoiceOver, Dynamic Type, and phone layouts.
3. Add the exam conversation request contract and remove duplicate latest-message forwarding before enabling mission chat for the new path.
4. Migrate existing original content into ordered lessons incrementally, mapping prior completion IDs as each lesson is released.
5. Enable final mock exam only after all its prerequisite mission types are available.
6. Roll back by routing Exam Prep to the existing catalog while retaining the progress payload; no destructive migration is required.

## Open Questions

- Which visual expression is preferred for the first release: a compact vertical route or a richer zone-map presentation? Both use the same campaign model.
- Which exact current Goethe A1 model test/version will be the source of truth for time limits and task templates before final content authoring?
- Is contextual speaking mandatory for every mission, or only for lessons whose can-do goal requires spoken production?
- What star thresholds communicate success without falsely suggesting an official exam score?
