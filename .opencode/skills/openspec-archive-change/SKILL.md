---
name: openspec-archive-change
description: Archive a completed change in the experimental workflow. Use when the user wants to finalize and archive a change after implementation is complete.
license: MIT
compatibility: Requires openspec CLI.
metadata:
  author: openspec
  version: "1.0"
  generatedBy: "1.3.0"
---

Archive a completed change in the experimental workflow.

**Input**: Optionally specify a change name. If omitted, check if it can be inferred from conversation context. If vague or ambiguous you MUST prompt for available changes.

**Steps**

1. **If no change name provided, prompt for selection**

   Run `openspec list --json` to get available changes. Use the **AskUserQuestion tool** to let the user select.

   Show only active changes (not already archived).
   Include the schema used for each change if available.

   **IMPORTANT**: Do NOT guess or auto-select a change. Always let the user choose.

2. **Check artifact completion status**

   Run `openspec status --change "<name>" --json` to check artifact completion.

   Parse the JSON to understand:
   - `schemaName`: The workflow being used
   - `artifacts`: List of artifacts with their status (`done` or other)

   **If any artifacts are not `done`:**
   - Display warning listing incomplete artifacts
   - Use **AskUserQuestion tool** to confirm user wants to proceed
   - Proceed if user confirms

3. **Check task completion status**

   Read the tasks file (typically `tasks.md`) to check for incomplete tasks.

   Count tasks marked with `- [ ]` (incomplete) vs `- [x]` (complete).

   **If incomplete tasks found:**
   - Display warning showing count of incomplete tasks
   - Use **AskUserQuestion tool** to confirm user wants to proceed
   - Proceed if user confirms

   **If no tasks file exists:** Proceed without task-related warning.

4. **Assess delta spec sync state**

   Check for delta specs at `openspec/changes/<name>/specs/`. If none exist, proceed without sync prompt.

   **If delta specs exist:**
   - Compare each delta spec with its corresponding main spec at `openspec/specs/<capability>/spec.md`
   - Determine what changes would be applied (adds, modifications, removals, renames)
   - Show a combined summary before prompting

   **Prompt options:**
   - If changes needed: "Sync now (recommended)", "Archive without syncing"
   - If already synced: "Archive now", "Sync anyway", "Cancel"

   If user chooses sync, use Task tool (subagent_type: "general-purpose", prompt: "Use Skill tool to invoke openspec-sync-specs for change '<name>'. Delta spec analysis: <include the analyzed delta spec summary>"). Proceed to archive regardless of choice.

5. **Reflect and update project memory** *(learning trigger — runs before the move, so `learnings.md` travels into the archive with the change)*

   **a. Ensure the memory store exists.** If `openspec/memory/` is missing, create it with one file per category, each starting with a `# <Category>` header: `architecture.md`, `conventions.md`, `pitfalls.md`, `decisions.md`, `workflows.md` (plus an `index.md` table of contents). This is self-bootstrapping — every archived change leaves the project a little smarter.

   **b. Gather reflection evidence** — small but strong: `proposal.md`, `design.md`, `tasks.md`, the change's specs, the final git diff for this change, the changed-file list, `notes.md` if present (decisions captured during implementation), and any test/validation results. Do NOT dump the whole session.

   **c. Write `openspec/changes/<name>/learnings.md`** (it moves into the archive). Answer concisely:
   - Intent vs final outcome; plan vs reality
   - Problems / wrong turns, and the corrections that worked
   - Decisions made and why; user corrections to how the work was done
   - Classify each learning: **local** (one-off — do not promote) / **project** (reusable knowledge) / **procedural** (repeatable how-to)
   - **Memory impact**: one line per memory retrieved during this change — did it actually help (how?) or was it noise? Write `memory impact: none retrieved` if retrieval was skipped or empty. This is the ground truth for measuring whether the memory system pays off.

   **d. Propose project-memory operations.** For each *project* / *procedural* learning, pick one: `ADD` · `UPDATE` (new evidence or refinement of an existing entry) · `MERGE` (consolidate overlapping entries) · `IGNORE`. Prefer compression over appending. Use the `## <ID>: <title>` entry format from the category files. Every promoted entry MUST carry `**Evidence:**` (this archive's path) and `**Last verified:**` (today's date).
   - Before proposing `ADD`: run `search_memory` with the candidate's learning text (limit 3). If an existing entry is a close match, propose `UPDATE`/`MERGE` of that entry instead of a new `ADD`.
   - Never promote: one-off details, secrets/tokens, tool noise, or anything the final code contradicts.
   - If a learning contradicts an existing entry, mark it `CONFLICT` and propose an UPDATE for review — do not silently overwrite.

   **e. Show the diff and confirm.** Present the proposed changes (`learnings.md` + `openspec/memory/*.md`) as a normal file diff and ask: **`Apply? [yes / edit / no]`**. Apply only what the user accepts. Committed memory is picked up by the qdrant reindex (git hook or manual), so the next change retrieves it.

6. **Perform the archive**

   Create the archive directory if it doesn't exist:
   ```bash
   mkdir -p openspec/changes/archive
   ```

   Generate target name using current date: `YYYY-MM-DD-<change-name>`

   **Check if target already exists:**
   - If yes: Fail with error, suggest renaming existing archive or using different date
   - If no: Move the change directory to archive

   ```bash
   mv openspec/changes/<name> openspec/changes/archive/YYYY-MM-DD-<name>
   ```

7. **Display summary**

   Show archive completion summary including:
   - Change name
   - Schema that was used
   - Archive location
   - Whether specs were synced (if applicable)
   - Note about any warnings (incomplete artifacts/tasks)

**Output On Success**

```
## Archive Complete

**Change:** <change-name>
**Schema:** <schema-name>
**Archived to:** openspec/changes/archive/YYYY-MM-DD-<name>/
**Specs:** ✓ Synced to main specs (or "No delta specs" or "Sync skipped")

All artifacts complete. All tasks complete.
```

**Guardrails**
- Reflection (step 5) runs before the move and is never skipped silently. If nothing is worth promoting, still write `learnings.md` and report "no project-memory changes".
- Memory promotion is gated by the user (`Apply? [yes/edit/no]`) — never auto-commit memory changes without showing the diff.
- Always prompt for change selection if not provided
- Use artifact graph (openspec status --json) for completion checking
- Don't block archive on warnings - just inform and confirm
- Preserve .openspec.yaml when moving to archive (it moves with the directory)
- Show clear summary of what happened
- If sync is requested, use openspec-sync-specs approach (agent-driven)
- If delta specs exist, always run the sync assessment and show the combined summary before prompting
