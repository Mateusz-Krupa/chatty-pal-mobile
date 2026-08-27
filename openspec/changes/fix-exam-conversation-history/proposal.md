## Why

During exam speaking missions the bot forgets what the learner said earlier in the same mission: it asks questions it already asked or ignores answers the learner gave. Root cause: the mobile client truncates the conversation history to the last 6 messages before sending it to the bot API, so in any mission longer than a few turns the early context (and the learner's earlier turns) is silently dropped.

## What Changes

- The mobile client sends the full mission conversation history (user + assistant turns) instead of the last 6 messages. The client still omits the in-flight learner turn (the server appends it once) and still drops non-conversation message kinds (teacher/translation/suggestion).
- The bot API becomes the single owner of the history cap: it dedupes the learner turn and keeps only the most recent 20 conversation messages before constructing the request. This bounds the token budget server-side for every caller, exam and non-exam alike.
- History roles remain explicit `user` / `assistant` so the model always knows who said what.

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `exam-conversation-quality`: the conversation contract now requires the full mission history to reach the model (bounded server-side), so the bot can track which answers the learner already gave within one mission.

## Impact

- iOS: `chatty-pal-mobile/chatty-pal/ChatEngine.swift` (`buildBotMessages`), iOS contract tests (`ExamConversationTests`, `ExamCampaignFlowTests`).
- Web: `chatty-pal/src/pages/api/bot.ts` (`buildConversation`), `chatty-pal/src/pages/api/bot.test.ts`, `exam.test.ts`.
- No API shape change: same `messages` + `message` fields; only the history length and cap location change. No dependencies.
