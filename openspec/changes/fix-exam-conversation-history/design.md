# Design — fix-exam-conversation-history

## Problem

`ChatEngine.buildBotMessages()` keeps `messages.suffix(6)` and drops the trailing user turn. In a 10-turn speaking mission the model sees at most 5 history messages plus the current one — it loses the learner's earlier answers and repeats questions. The user reported the bot "zapomina kto co powiedział".

## Decision: full history from the client, cap owned by the server

- **Client (iOS)** sends every conversation turn of the current session (user + assistant only; teacher/translation/suggestion/system-local messages stay filtered). It continues to exclude the in-flight learner turn, which the server appends exactly once (`dedupeLearnerTurn` remains as defense in depth).
- **Server (bot API)** becomes the single owner of the history budget: after dedupe it keeps the most recent **20** conversation messages (10 turns) before the current learner message. The cap applies in exam and non-exam mode alike, so every caller gets the same bounded context.
- Roles stay `user`/`assistant`. In exam mode the server still replaces the client system message with the server-owned exam instruction, so the exam system prompt stays authoritative.

### Why not a larger client cap?

A client cap duplicates the budget logic in two places and still loses context in long missions. One cap, on the side that counts tokens, is simpler (KISS) and future-proofs other clients.

### Why 20 messages?

A1 mission turns are short (the bot is capped at 150 output tokens). 20 history messages + system instruction is well within gpt-4o-mini's context and covers a full speaking mission including the opening stage, while keeping cost and latency low.

## Contracts

### iOS `buildBotMessages()`

```
[system(persona.fullInstruction)] + all conversation turns (user/assistant), excluding the trailing user turn
```

No length cap. The existing filters for `teacher`, `translation`, `suggestion` roles are unchanged.

### Server `buildConversation(message, messages, exam)`

```
history = dedupeLearnerTurn(messages, message)
exam mode + known instruction:
  [system(serverInstruction)] + tail20(history minus system) + [user message]
otherwise:
  history + [user message]   (system history message from client kept, tail20 on conversation turns only)
```

`tail20` keeps the last 20 messages; if the kept window starts with an orphan `assistant` message (its user turn was cut), that leading `assistant` message is dropped to keep the sequence starting with `user`.

## Failure modes

- **Old client + new server**: client sends ≤6 messages — server cap is a no-op; behavior unchanged. Safe.
- **New client + old server**: server appends `message` and has no cap — works, but long missions consume more tokens. Acceptable during rollout; server and client ship together.
- **History contains only assistant turns** (e.g. after a reset): leading assistant is dropped, so the model never sees a reply with no preceding question.

## Testing

- iOS: mission with >6 turns sends the full user-turn sequence in `messages`; trailing-turn dedupe still holds.
- Server: 24-message history is capped to 20 with the orphan-assistant rule; exam mode keeps the server instruction; non-exam mode keeps client system message; dedupe still removes an identical trailing user turn.
