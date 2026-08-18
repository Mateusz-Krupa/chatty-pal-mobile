# Proposal — chat-generation-feedback

## Why

Between the end of a voice utterance and the bot's reply, the chat screen is dead: nothing indicates that transcription is running (new Whisper step) or that the bot is thinking (`isGenerating` is hard-coded to `false` in `ChatView`, so the existing "Thinking..." indicator in `ChatMessageList` never renders). Normal multi-second waits read as a freeze.

Companion web change (separate repo): the bot currently runs on the heavy `gpt-4o` model; `gpt-4o-mini` is sufficient for A1 conversation and roughly 2x faster.

## What changes

- Mobile: wire `isGenerating: engine.isGenerating` into `ChatMessageList`; add `ChatEngine.isTranscribing` exposed to the UI and a "Transcribing..." chip in `ChatView`.
- Web (`chatty-pal`): `src/pages/api/bot.ts` model `gpt-4o` → `gpt-4o-mini`.

## Impact

- Mobile: `ChatView.swift`, `ChatEngine.swift`.
- Web: `src/pages/api/bot.ts` (one line).
