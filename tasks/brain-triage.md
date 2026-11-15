# Task: brain-triage

Triages every new capture in the brain repo. Skill: `segoy-triage` (in the brain's `.claude/skills/`).

## Settings (claude.ai/code → Scheduled tasks → New)

| Setting | Value |
|---|---|
| Name | `brain-triage` |
| Repository | `<owner>/<brain>` only |
| Environment | Default |
| Model | Sonnet (M1-D4; try Haiku once triage is proven) |
| Trigger | GitHub event → `<owner>/<brain>` → Event: **Issues → opened** (not "All issue events") |
| Schedule | none (remove any default schedule) |
| Connectors | **remove all** (Advanced settings → Connectors). Brain tasks use none (architecture §5 rule 5) |
| Notifications | your choice; push on failure is useful |

## Prompt

```
Run the segoy-triage skill for the issue in the GitHub trigger context.
Follow .claude/skills/segoy-triage/SKILL.md exactly, including its preconditions.
```

## Notes
- Only issues you open yourself start this task. Issues created by a Claude session (for example through `segoy-capture`) do not, and the capture skill triages them in the same session instead (ADR-015).
- Triage writes no files (ADR-018). It comments, labels and, for duplicates, closes.
- Agents cannot create or edit this task; you create it by hand (spike S5). After creating it, open one test issue and check that a comment appears within a few minutes.
