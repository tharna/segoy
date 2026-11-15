# Tasks: project-implement and project-implement-pr (one pair per project repo)

Build the approved plan after Gate 1, and revise the Gate 2 PR on your comments. Skill: `segoy-implement` (in the project's `.claude/skills/`, from `segoy init project`). A task takes one GitHub event, so these are **two tasks with the same prompt**.

## Settings

| Setting | `project-implement` | `project-implement-pr` |
|---|---|---|
| Repository | `<owner>/<repo>` only (never the brain, ADR-008) | same |
| Model | Opus (M3-D5) | Opus |
| Trigger | GitHub event → `<owner>/<repo>` → **Pull request → closed**; filters **Is merged** = true, **Labels** contains `segoy:plan` | GitHub event → `<owner>/<repo>` → **Pull request → labeled**; filter **Labels** contains `answered` |
| Schedule | none | none |
| Connectors | **remove all** | **remove all** |

## Prompt (both)

```
Run the segoy-implement skill for the pull request in the GitHub trigger context
(build mode for a merged segoy:plan PR, revise mode for a segoy:impl PR labelled
answered). Without a trigger context, use its Run now rule.
Follow .claude/skills/segoy-implement/SKILL.md exactly. You may push to a new
claude/ branch, and, in revise mode, to that PR's own head branch. Never push to
the default branch.
```

## Notes
- Single-repo session: the commit hook's leak check runs on every commit.
- The verifier subagent runs on Sonnet (`.claude/agents/verifier.md`); change it there if it misses things.
- Merged a Gate 1 PR before the task existed? Press **Run now** on `project-implement`.
- If CI fails on the Gate 2 PR, comment "fix CI" (or what you see) and add `answered` (M3-D3).
