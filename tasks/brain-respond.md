# Task: brain-respond

Continues an idea after you answer or give a command. Skill: `segoy-respond`.

## Settings

| Setting | Value |
|---|---|
| Name | `brain-respond` |
| Repository | `<owner>/<brain>` only |
| Environment | Default |
| Model | Sonnet |
| Trigger 1 | GitHub event → `<owner>/<brain>` → Event: **Issues → labeled**, **Filter + → Label → `answered`** (required: without it every label a skill sets starts a run, ADR-015 amendment) |
| Trigger 2 | Schedule: **every 4 hours** (the sweep). Hourly is the platform minimum; use it if you often reply without the label |
| Trigger 3 | GitHub event → `<owner>/<brain>` → **Pull request → labeled**, **Filter + → Label → `answered`** (spec PR feedback, M2) |
| Connectors | **remove all** |

## Prompt

```
Run the segoy-respond skill. If the GitHub trigger context names an issue, handle
that issue (event mode); otherwise run the sweep (sweep mode).
Follow .claude/skills/segoy-respond/SKILL.md exactly, including its preconditions.
```

## Notes
- The label is what starts the task; a comment alone starts nothing (ADR-016). Otak adds the label for you. From GitHub mobile, add `answered` after replying.
- Labels set by skills (`state:*`, `kind:*`, `target:*`) also fire `issues.labeled` (observed in M1 staging). The filter keeps them from starting runs; if it is missing, each one costs a short run that exits quietly.
- The sweep exits without posting when there is nothing to do. Each sweep is still one short run on your plan, which is why the default is every 4 hours rather than hourly.
- The skill handles answers, `defaults`, `/park`, `/unpark`, `/reject`, confirmations of `me:` captures, `/spec` (runs `segoy-spec`, which opens the spec PR) and comments on spec PRs (revised by `segoy-spec`). From M2 it writes files through `segoy-spec`, so the model matters more: keep Sonnet or use Opus.
