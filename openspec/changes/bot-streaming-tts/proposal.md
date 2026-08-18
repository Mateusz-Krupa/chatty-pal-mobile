# Proposal — bot-streaming-tts

## Why

A voice turn currently waits for the *entire* bot completion before synthesizing speech: VAD (1.8s) + transcription (1–2s) + full bot reply (2–6s) + TTS (1–3s). With streaming, the bot text starts arriving ~0.5s after the transcription, and TTS can play the first sentence while the rest is still being generated — cutting ~4–7s off the perceived reply time.

## What changes

- New pure, testable pieces: `BotStreamParser` (SSE `data:` line → text delta) and `UtteranceSplitter` (delta buffer → complete sentences for TTS).
- `BotServicing` gains `streamMessage(...) -> AsyncThrowingStream<String, Error>`; `BotService` implements it via `URLSession.bytes` and parses SSE lines.
- `ChatEngine.requestBotResponse` streams: the assistant bubble fills live, each completed sentence is enqueued to a sequential TTS pump (synthesize next sentence while the current one plays). Hands-free resume fires only after the stream ends AND the TTS queue drains.
- **Fallback**: if the streaming request fails (e.g. web not deployed yet), the engine transparently retries with the existing one-shot `sendMessage` path — chat never breaks.
- Tapping a message's speaker button cancels any in-flight generation first.

## Impact

- New files: `BotStream.swift`, `UtteranceSplitter.swift` + tests (pbxproj 61–68).
- Touched: `BotService.swift`, `ChatEngineDependencies.swift` (protocol), `ChatEngine.swift`, `ChatEngineTests.swift` (fake stream bot).
- Companion web change: `bot-streaming-route` (separate repo/change).
