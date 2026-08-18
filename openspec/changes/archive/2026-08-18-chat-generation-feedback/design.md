# Design — chat-generation-feedback

## isThinking wiring

`ChatMessageList` already renders `ProgressView("Thinking...")` when `isGenerating` is true. `ChatView` passes a hard-coded `false`. Change to `engine.isGenerating` (set true in `requestBotResponse`, false when the response lands or fails — already implemented in `ChatEngine`).

## Transcribing chip

`ChatEngine` gains `private(set) var isTranscribing = false`:
- set `true` in `finishUtterance` when a WAV capture exists (i.e. a Whisper round-trip is about to happen),
- set `false` once the transcription attempt completes (success or fallback), before `sendText`.

`ChatView` renders, in the slot where the listening indicator lives:
- recording → `ListeningIndicator` (unchanged)
- else transcribing → `ProgressView("Transcribing...")` chip with the same material background.

## Web bot model

`gpt-4o` → `gpt-4o-mini` in `bot.ts`. Same endpoint/params. Fallback semantics unchanged (500 → engine appends error message).
