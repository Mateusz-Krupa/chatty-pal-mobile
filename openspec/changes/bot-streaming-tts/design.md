# Design — bot-streaming-tts

## BotStreamParser (pure)

```swift
enum BotStreamParser {
    static func delta(fromLine line: String) -> String?  // content of choices[0].delta.content
    static func isDone(_ line: String) -> Bool           // "data: [DONE]"
}
```
- Lines not starting with `data:` (comments/heartbeats/empty) → nil.
- `data: [DONE]` → isDone.
- JSON decode via `JSONSerialization` (no Codable schema needed): `choices[0].delta.content` may be absent (role-only chunks) → nil.

## UtteranceSplitter (pure)

```swift
struct UtteranceSplitter {
    mutating func feed(_ delta: String) -> [String]   // completed sentences
    mutating func finish() -> String?                 // leftover tail
}
```
- Buffer deltas; emit a sentence when a character in `.` `!` `?` (optionally followed by `"`, `'`, `)`) is followed by whitespace.
- Emitted sentences are trimmed and must contain at least one alphanumeric.
- Safety: buffer longer than 200 chars without a boundary → force-emit on the last whitespace.
- `finish()` emits the remaining non-empty tail.

## BotService streaming

`BotRequest` gains `stream: Bool = false` (encoded as `false` for one-shot — the route ignores it). 
```swift
func streamMessage(instruction:message:messages:) -> AsyncThrowingStream<String, Error>
```
- Builds the same request (same headers/cookies) with `stream: true`.
- `URLSession.shared.bytes(for:)`; check HTTP status (non-200 → `BotServiceError.httpError`); iterate `bytes.lines`, yield `BotStreamParser.delta` results, stop at `isDone`.
- `continuation.onTermination` cancels the underlying Task (client interrupt stops the network read).
- 404-on-non-default-base fallback is mirrored from `sendMessage` (try default base once).

## ChatEngine streaming flow

`requestBotResponse(for:)`:
1. State: `isGenerating = true`, `voiceState = .waitingForBot`; reset `streamBuffer`, `splitter`, `ttsQueue`, `streamFinished = false`.
2. For each delta: append to `streamBuffer`; the assistant bubble is appended on the first delta and then updated in place (`updateLastAssistantMessage` — no store save per delta, one save when the stream ends).
3. Each completed sentence from the splitter → `enqueueTTS`.
4. Stream ends: flush splitter tail, save, `isGenerating = false`, `streamFinished = true`, `pumpTTS()`.
5. Error: cancel, `isGenerating = false`; if no assistant bubble was created → fall back to the one-shot `sendMessage` (existing behavior, including its error message).

## TTS pump

- `ttsQueue: [String]`, `isTTSPumping: Bool`.
- `enqueueTTS(_:)` appends + pumps.
- `pumpTTS()`: guards `isTTSEnabled`, not pumping, queue non-empty → pop, `voiceState = .playingTTS`, synthesize, `playback.play`.
- `playback.onFinished` → new `playbackFinished()`: queue non-empty → pump next; else if `streamFinished` → `finishPlaybackPhase()` (existing: idle + hands-free resume).
- TTS disabled: pump drops the queue; when `streamFinished` → `finishPlaybackPhase()` (text-only turn still completes and resumes).
- `interrupt()` also clears `ttsQueue`, resets `streamFinished`/pump flags.
- `speak(_:)` (bubble tap): if `isGenerating` → `interrupt()` first, then play as today.

## Testing

- `BotStreamParser`: content chunk, role-only chunk (nil), `[DONE]`, comment/empty lines, malformed JSON.
- `UtteranceSplitter`: multi-sentence feed split across deltas, trailing quotes, no-punctuation tail via finish(), 200-char force split, empty/whitespace ignored.
- `ChatEngineTests` with `FakeStreamBot`: live bubble text equals concatenated deltas; TTS called per sentence in order; hands-free resume only after drain; stream error → one-shot fallback; interrupt mid-stream cancels (no further synth).
