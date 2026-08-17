# Chatty Pal Mobile — Rules for AI Agents

## OpenSpec (required)

ALWAYS use OpenSpec for any feature, refactor, or non-trivial change in this project:

1. Propose: `openspec new change <kebab-name>`, then create artifacts (proposal → design + specs → tasks) until `openspec status --change <name> --json` shows all done.
2. Implement: work through `openspec/changes/<name>/tasks.md`, check boxes `- [ ]` → `- [x]` as tasks complete.
3. Archive: when all tasks are done, `openspec archive <name>`.

Spec format: `### Requirement:` (SHALL/MUST) + `#### Scenario:` (exactly 4 hashes) with `- **WHEN**`/`- **THEN**`.
Instructions JSON: `openspec instructions <artifact> --change <name> --json | tail -n +2` (first line is not JSON).

## Build & Test

```bash
# Build (no signing)
xcodebuild -project chatty-pal.xcodeproj -scheme chatty-pal -configuration Debug \
  -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build

# Tests
xcodebuild -project chatty-pal.xcodeproj -scheme chatty-pal -configuration Debug \
  -destination 'platform=iOS Simulator,id=E62B27CA-23B1-4839-ABD7-82D93E8AC28F' \
  CODE_SIGNING_ALLOWED=NO -only-testing:chatty-palTests test
```

Run build after every code change; run tests after functional phases. Commit per phase.

## project.pbxproj

NOT a synchronized group — every new file needs 4 manual entries:
`PBXBuildFile`, `PBXFileReference`, group `children`, `PBXSourcesBuildPhase`.
Existing IDs are hex `AA0000000000000000000001`–`AA0000000000000000000030`; next free: `AA0000000000000000000031`.

## Swift 6.2 pitfalls

- `@ViewBuilder` only BEFORE the parameter name: `init(@ViewBuilder topContent: () -> TopContent)`.
- No default generic parameters on structs (`<T: View = EmptyView>` does not compile).
- `let x: String?` has no default in the memberwise initializer — use `var x: String? = nil` to make it optional in calls.
- `AVAudioPlayer(data:)` throws — wrap in do-catch even inside synchronous `MainActor.run` closures.
