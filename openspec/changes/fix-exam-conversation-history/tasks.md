# Tasks — fix-exam-conversation-history

## 1. Server history cap (chatty-pal)

- [x] 1.1 Add a `tailConversation(messages, limit = 20)` helper in `src/pages/api/bot.ts`: keep the last 20 messages, drop a leading orphan `assistant` message, apply after `dedupeLearnerTurn` in both exam and non-exam paths of `buildConversation`
- [x] 1.2 Server tests in `bot.test.ts`: 24-message history caps to 20; orphan-leading-assistant dropped; dedupe of identical trailing user turn still works; exam mode keeps server system instruction; non-exam mode keeps client system message

## 2. Client full history (chatty-pal-mobile)

- [x] 2.1 Remove the `suffix(6)` cap in `ChatEngine.buildBotMessages()`; keep the trailing-user-turn exclusion and the teacher/translation/suggestion filters
- [x] 2.2 iOS tests in `ExamConversationTests`/`ExamCampaignFlowTests`: a >6-turn mission sends the full user-turn sequence in `messages`; existing single-turn and dedupe tests still pass

## 3. Verification

- [x] 3.1 Backend: `npx jest src/pages/api/bot.test.ts src/pages/api/exam.test.ts` green
- [x] 3.2 iOS: build + full `chatty-palTests` suite green on the iPhone SE simulator
