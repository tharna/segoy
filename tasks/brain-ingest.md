# Task: brain-ingest (one per owner)

Turns each new file under `knowledge/raw/` into one `segoy:knowledge` PR in the brain: a source summary page, updates to every wiki page the source bears on (new pages only where none exists), the wiki index and one `log.md` line. Skill: `segoy-ingest`.

## Settings

| Setting | Value |
|---|---|
| Name | `brain-ingest` |
| Repositories | `<owner>/<brain>` only |
| Environment | Default |
| Model | Sonnet |
| Trigger | GitHub event → `<owner>/<brain>` → **Pull request → closed**. Filters: **Is merged** = true; **no label filter** (the owner's own PRs that add raw files carry no label) |
| Schedule | none |
| Connectors | **remove all** |

## Prompt

```
Run the segoy-ingest skill for the merged PR in the GitHub trigger context, or with Run now
for raw files not yet ingested. Follow .claude/skills/segoy-ingest/SKILL.md in the brain
checkout exactly. You may push only to new claude/ branches in the brain; never to its
default branch.
```

## Notes
- Every merged brain PR starts a short session. Most add no file under `knowledge/raw/`; those runs exit quietly and post nothing.
- One PR per raw file, at most 5 per run. A merge that adds more leaves the rest for **Run now**, which also catches up on raw files added before this task existed (oldest first, same cap).
- The weekly review files notes into `knowledge/raw/`; merging the review PR starts ingest. Note issues themselves never start it.
- Closing an ingest PR unmerged means "do not ingest this source": no later run retries it. To retry, press Run now with the raw file named in the prompt, for example "… Run now for `knowledge/raw/<file>.md`".
- Two open ingest PRs may touch the same page or `knowledge/wiki/index.md`; the second one to merge then needs its conflict resolved (edit in the PR, or close it and Run now with the file named).
- Agents cannot create tasks: create this one by hand after `segoy sync` brings the skill into the brain.
