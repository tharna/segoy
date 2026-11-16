# Task: kit-sync (one per owner)

Keeps the Segoy kit in the brain and every project repo up to date: one sync PR per repo that is behind. Skill: `segoy-sync` (M4-D3: scheduled).

| Setting | Value |
|---|---|
| Repositories | `<owner>/segoy` (or wherever you get Segoy from) **plus** the brain and every project repo. Add new project repos here when you create them. |
| Model | Sonnet |
| Trigger | Schedule: weekly, for example Monday 07:40 in your time zone. Press **Run now** after merging a kit change you want sooner. |
| GitHub events / connectors | none / **remove all** |

## Prompt

```
Run the segoy-sync skill: follow .claude/skills/segoy-sync/SKILL.md in the Segoy
checkout exactly. Targets are every other checkout that has .segoy/manifest.json.
You may push only to new claude/ branches in the target repos, never to a default
branch, and never to the Segoy repo.
```

## Notes
- The task runs `scripts/segoy sync --pr` from the Segoy checkout. A repo that is up to date, paused (`segoy:paused` issue) or still has an open sync PR is skipped, so most weekly runs post nothing.
- A sync PR changes only kit-managed files (`.claude/`, `segoy-*` workflows, issue templates, `.segoy/labels.json`, and the brain's `CLAUDE.md`) plus `.segoy/version` and `.segoy/manifest.json`. Your config, denylist, notes and a project's `CLAUDE.md` are never touched.
- A file you changed in the repo is not overwritten: the new kit version lands next to it as `<file>.segoy-new`, and the PR says so. Merge what you want by hand and delete the `.segoy-new` file.
- Hooks do not run in multi-repo sessions (S7). The project commit hook does not run here either; the project's `segoy-leak-check` CI still checks the sync PR.
- Segoy's own `.claude/` is not synced by this task: Segoy PRs run `scripts/segoy sync --no-github .`, and its CI fails if they forget.
