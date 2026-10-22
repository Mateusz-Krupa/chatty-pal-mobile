# Validation

- Simulator Debug build + full chatty-palTests: PASS, 281 tests, 0 failures, 0 skips. Verified with xcresulttool using Run-chatty-pal-2026.10.22_13-04-09-+0200.xcresult.
- New regression coverage: bidirectional lowercase/uppercase/mixed case, German ß/SS/ẞ, exact token normalization, umlaut preservation and genuinely different words.
- Strict OpenSpec change validation: PASS.
- Existing WordReview Swift 6 isolation warning is unrelated to this change.
- Mark as done remains persisted through CMS complete() setting completed_at and completion_source=manual; no API or database changes needed.
- No production actions or push performed.
- Generic simulator Debug build (arm64/x86_64): PASS.
- Independent reviewer: approved 4.8/5, no required fixes. Active-session gpt-6.1-sol fallback used because preferred reviewer endpoint was unavailable; reviewer inspected diff/source/specs but did not rerun tests. Optional explicit expected-token assertion deferred because existing token-equality and score assertions cover behavior.
