# Task: brain-respond

Continues an idea after you answer or give a command. Skill: `segoy-respond`.

## Settings

| Setting | Value |
|---|---|
| Name | `brain-respond` |
| Repository | `<owner>/<brain>` only |
| Environment | Default |
| Model | Sonnet |
| Trigger 1 | GitHub event → `<owner>/<brain>` → Event: **Issues → labeled**. Add a filter on the label `answered` if the form offers one; the skill checks the label either way |
| Trigger 2 | Schedule: **every 4 hours** (the sweep). Hourly is the platform minimum; use it if you often reply without the label |
| Connectors | **remove all** |

## Prompt

```
Run the segoy-respond skill. If the GitHub trigger context names an issue, handle
that issue (event mode); otherwise run the sweep (sweep mode).
Follow .claude/skills/segoy-respond/SKILL.md exactly, including its preconditions.
```

## Notes
- The label is what starts the task; a comment alone starts nothing (ADR-016). Otak adds the label for you. From GitHub mobile, add `answered` after replying.
- Every label change fires the trigger. The skill exits quietly unless `answered` is on the issue, so other labels cost one short run each.
- The sweep exits without posting when there is nothing to do. Each sweep is still one short run on your plan, which is why the default is every 4 hours rather than hourly.
- In M1 the skill handles answers, `defaults`, `/park`, `/unpark`, `/reject` and confirmations of `me:` captures. `/spec` and `/plan` are acknowledged; the spec step arrives in M2.
