# Task: brain-gate-sync-<repo>

Records your Gate 1 and Gate 2 decisions in the brain when you merge or close a `segoy:plan` or `segoy:impl` PR in a project repo. Skill: `segoy-gate-sync`. **One task per project repo**, like `brain-plan-promote-<repo>`.

## Settings

| Setting | Value |
|---|---|
| Name | `brain-gate-sync-<repo>` |
| Repositories | `<owner>/<brain>` **first**, then `<owner>/<repo>` |
| Model | Sonnet |
| Trigger | GitHub event → **`<owner>/<repo>`** (the project, not the brain) → **Pull request → closed**. Filter: **Labels** is one of `segoy:plan`, `segoy:impl` (if the form only takes one value, use two tasks, one per label). No "Is merged" filter: closing without merging must fire too |
| Schedule | none |
| Connectors | **remove all** |

## Prompt

```
Run the segoy-gate-sync skill for the closed pull request in the GitHub trigger context.
Follow .claude/skills/segoy-gate-sync/SKILL.md (in the brain checkout) exactly.
Change only the idea's issue in the brain; never write to <owner>/<repo>.
```

## Notes
- Gate 1 merged → `state:building` (and `project-implement` fires on the same merge). Gate 2 merged → `state:done`, brain issue closed (and `project-retro` fires).
- Gate 2 closed without merging → the brain issue asks: `retry`, `park` or `reject`.
- Merged or closed a Gate 1 PR before this task existed, or a run failed? Press **Run now**: it catches up on every closed `segoy:plan` PR whose idea is still `promoted`.
- Closing without merging → the brain issue asks you: `replan`, `park` or `reject`. Answer and add `answered`. For `replan`, press **Run now** on `brain-plan-promote-<repo>` when asked.
