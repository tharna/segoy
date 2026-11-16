# Task: brain-respond (two tasks)

Continues an idea after you answer or give a command. Skill: `segoy-respond`.

**A task can have only one GitHub event trigger** (observed in M2 staging), so this is two tasks with the **same prompt**:
- `brain-respond`: Trigger 1 + Trigger 2 below (issues and the sweep).
- `brain-respond-pr`: Trigger 3 only (feedback on spec PRs). It fired in M2 T2.5 when the owner changed a label on a spec PR that carried `answered`. Whether the owner's first `answered` also started a run is not known (only the latest run is visible). The sweep in `brain-respond` also picks up spec PR feedback, as a safety net.

## Settings

| Setting | Value |
|---|---|
| Name | `brain-respond` |
| Repository | `<owner>/<brain>` only |
| Environment | Default |
| Model | Sonnet |
| Trigger 1 | GitHub event → `<owner>/<brain>` → Event: **Issues → labeled**, **Filter + → Label → `answered`** (required: without it every label a skill sets starts a run, ADR-015 amendment) |
| Trigger 2 | Schedule: **every 4 hours** (the sweep). Hourly is the platform minimum; use it if you often reply without the label |
| Trigger 3 (task `brain-respond-pr`) | GitHub event → `<owner>/<brain>` → **Pull request → labeled**, **Filter + → Label → `answered`** (spec PR feedback, M2) |
| Connectors | **remove all** |

## Prompt

```
Run the segoy-respond skill. If the GitHub trigger context names an issue or a PR,
handle it (event mode); otherwise run the sweep (sweep mode).
Follow .claude/skills/segoy-respond/SKILL.md exactly, including its preconditions.
When segoy-spec revises an open segoy:spec PR, you may push the revision to that PR's
own head branch in this repository. Never push to the default branch.
```

## Notes
- The label is what starts the task; a comment alone starts nothing (ADR-016). Otak adds the label for you. From GitHub mobile, add `answered` after replying.
- Labels set by skills (`state:*`, `kind:*`, `target:*`) also fire `issues.labeled` (observed in M1 staging). The filter matches when the item **has** the `answered` label, not only when `answered` is the label just added (M2 staging). So `segoy-respond` removes `answered` first, before changing any other label; otherwise its own label changes start a second run.
- The sweep exits without posting when there is nothing to do. Each sweep is still one short run on your plan, which is why the default is every 4 hours rather than hourly.
- The skill handles answers, `defaults`, `/park`, `/unpark`, `/reject`, confirmations of `me:` captures, `/spec` (runs `segoy-spec`, which opens the spec PR; answers in the same reply are kept), a fully answered `kind:task` issue (goes straight to `segoy-spec` without `/spec`) and comments on spec PRs (revised by `segoy-spec`). From M2 it writes files through `segoy-spec`, so the model matters more: keep Sonnet or use Opus.
