# Tasks — inline-context-corrections

## 1. Data model
- [x] 1.1 Add optional `correction: String?` to `ChatMessage` (Codable, decodes old history to `nil`).

## 2. Service
- [x] 2.1 Add `context:` parameter to `TeacherService.fixText`; send the recent turns in the `messages` array of the `/api/fix-text` body. Keep the existing single-argument behavior available for callers that pass no context.

## 3. Engine
- [x] 3.1 In `ChatEngine.fetchTeacherFix`, build context from the last 4 user/assistant messages (exclude system/teacher/translation/suggestion) and pass it to the service.
- [x] 3.2 In exam mode, attach the corrected text to the last learner message's `correction` (no `.teacher` append). In free chat, keep appending a `.teacher` message.
- [x] 3.3 No-op detection: if the corrected text diffs to only `.same` segments, do not store a correction.

## 4. Rendering
- [x] 4.1 In `MessageView`, render a compact diff row under a `.user` bubble when `message.correction != nil` (strikethrough original + highlighted fix, trailing-aligned). Reuse `TextDiffer`.

## 5. Tests
- [x] 5.1 Unit: exam mode → correction attached to learner message, no `.teacher` appended.
- [x] 5.2 Unit: corrected text identical to input → no correction stored.
- [x] 5.3 Unit: free chat → `.teacher` message appended (regression guard).
- [x] 5.4 Unit: correction request context excludes non-user/assistant roles and is bounded.

## 6. Validation
- [x] 6.1 Full iOS test suite green (`-only-testing:chatty-palTests`).
- [x] 6.2 Reviewer subagent scores code + view ≥ 4.5; apply required fixes.
