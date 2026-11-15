# Task: brain-gate-sync-<repo>

Records your Gate 1 decision in the brain when you merge or close a `segoy:plan` PR in a project repo. Skill: `segoy-gate-sync`. **One task per project repo**, like `brain-plan-promote-<repo>`.

## Settings

| Setting | Value |
|---|---|
| Name | `brain-gate-sync-<repo>` |
| Repositories | `<owner>/<brain>` **first**, then `<owner>/<repo>` |
| Model | Sonnet |
| Trigger | GitHub event → **`<owner>/<repo>`** (the project, not the brain) → **Pull request → closed**. Filter: **Labels** contains `segoy:plan`. No "Is merged" filter: closing without merging must fire too |
| Schedule | none |
| Connectors | **remove all** |

## Prompt

```
Run the segoy-gate-sync skill for the closed pull request in the GitHub trigger context.
Follow .claude/skills/segoy-gate-sync/SKILL.md (in the brain checkout) exactly.
Change only the idea's issue in the brain; never write to <owner>/<repo>.
```

## Notes
- Merging = Gate 1 approved → the brain issue moves to `state:building`. In M3, `project-implement` fires on the same merge.
- Closing without merging → the brain issue asks you: `replan`, `park` or `reject`. Answer and add `answered`. For `replan`, press **Run now** on `brain-plan-promote-<repo>` when asked.
