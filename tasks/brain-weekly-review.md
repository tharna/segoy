# Task: brain-weekly-review (one per owner)

Once a week, files the brain's housekeeping into one `segoy:review` PR: journal digest, notes into `knowledge/raw/`, decision records, parked and rejected idea stubs, idea-state corrections, stuck ideas, and at most five `proposed` ways changes. Skill: `segoy-weekly-review`.

## Settings

| Setting | Value |
|---|---|
| Name | `brain-weekly-review` |
| Repositories | `<owner>/<brain>` **first**, then every project repo (read-only: retros and gate PRs). Add new project repos here when you create them. |
| Model | Sonnet |
| Trigger | Schedule: weekly, **Sunday 18:00 Europe/Helsinki** |
| GitHub events | none |
| Connectors | **remove all** |

## Prompt

```
Run the segoy-weekly-review skill: follow .claude/skills/segoy-weekly-review/SKILL.md
in the brain checkout exactly. You may push only to a new claude/ branch in the brain;
never to its default branch, and never to a project repo.
```

## Notes
- **Run now** does a catch-up review for the 7 days before the run, for example after a missed week.
- An empty week (no activity, nothing to file, no drift, nothing stuck) opens no PR and posts nothing.
- While a review PR is still open, the next run opens no second PR; it posts one `skipped` comment on the open one. Merge or close it, and the next run catches up on notes, stubs, drift and stuck ideas.
- Merging the PR accepts everything in it and closes the filed note issues. Edit the PR's files before merging to change a proposal or record.
- Agents cannot create tasks: create this one by hand after `segoy sync` brings the skill into the brain.
