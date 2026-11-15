# Task: brain-plan-promote-<repo>

Turns a merged spec into the Gate 1 PR in one project repo. Skills: `segoy-plan`, then `segoy-promote` (both in the brain's `.claude/skills/`). **One task per project repo**, because a task's repositories are fixed when it is created.

## Settings

| Setting | Value |
|---|---|
| Name | `brain-plan-promote-<repo>` |
| Repositories | `<owner>/<brain>` **first**, then `<owner>/<repo>` |
| Environment | Default |
| Model | Opus (planning is the hardest step) |
| Trigger | GitHub event → `<owner>/<brain>` → **Pull request → closed**. Filters: **Is merged** = true; **Labels** contains `segoy:spec`; **Labels** contains `target:<repo>` |
| Schedule | none |
| Connectors | **remove all** |

## Prompt

```
Run segoy-plan for the merged spec PR in the GitHub trigger context, then segoy-promote
in this same run. Follow .claude/skills/segoy-plan/SKILL.md and
.claude/skills/segoy-promote/SKILL.md (in the brain checkout) exactly. The leak check
in segoy-promote step 5 is mandatory. You may push only to a new branch in <owner>/<repo>
for the Gate 1 PR; never to its default branch.
```

## Project repo, before its first promotion

1. The repo exists and is installed in the Claude GitHub App.
2. It has `.claude/scripts/leak-guard.sh` (from Segoy `kit/common`) and `.github/workflows/segoy-leak-check.yml` (from Segoy `kit/project`). `segoy init project` will do this from M3; until then copy both files by hand in a PR.
3. It has a `docs/specs/` folder (a `.gitkeep` is enough).

## Notes
- Hooks do not run in this two-repo session (ADR-017). The leak check therefore runs as a script step in `segoy-promote`, then again in the project's CI, and finally by you at Gate 1.
- The trigger fires when **you** merge the spec PR. Merges are owner actions; the agent never merges.
- If the spec was merged before this task existed, or a run failed, open the task and press **Run now**. Without a trigger context, `segoy-plan` picks the most recently merged `segoy:spec` PR for this repo that has no `segoy:plan` PR yet. The weekly review also lists ideas stuck in `specced`.
