# Task: brain-lint (one per owner)

Once a week, checks the brain's health: contradictions between pages, orphan and stale wiki pages, missing frontmatter, index drift and ideas stuck in a state. Every finding goes into one `Lint <date>` report issue; only missing frontmatter and index drift are fixed, in one `segoy:lint` PR. Skill: `segoy-lint`.

## Settings

| Setting | Value |
|---|---|
| Name | `brain-lint` |
| Repositories | `<owner>/<brain>` only |
| Environment | Default |
| Model | Haiku (`models.lint` in `.segoy/config.yml`) |
| Trigger | Schedule: weekly, **Saturday 18:00 Europe/Helsinki** (before the Sunday weekly review) |
| GitHub events | none |
| Connectors | **remove all** |

## Prompt

```
Run the segoy-lint skill: follow .claude/skills/segoy-lint/SKILL.md in the brain checkout
exactly. You may push only to a new claude/ branch in the brain; never to its default
branch, and never to any other repository.
```

## Notes
- A clean brain opens no issue and no PR, and posts nothing.
- A new `Lint <date>` issue closes the previous open one as completed, with a "Superseded by" comment. A clean week leaves the previous one open.
- The fix PR changes only frontmatter blocks (fields derivable from the file: `id`, `title`, `kind`, `visibility: private`, `created` from git, `links: []`, and `updated` set to the run date) and index rows. `source` and `state` are never guessed; they stay in the report for you.
- Contradictions are flagged with both statements quoted by `path:line` and never resolved. The small model can be noisy here; dismiss a false one by closing the issue.
- Stuck ideas use the weekly review's 14-day rule; the lint report lists them for completeness, the weekly review digest is where to act.
- While a lint PR is still open, the next run opens no second PR; it comments `skipped` on the open one and still writes the report.
- The `segoy:lint` label arrives with `segoy sync`. Without it the report issue says "Run segoy sync to add the segoy:lint label."
- Agents cannot create tasks: create this one by hand after `segoy sync` brings the skill into the brain, then press **Run now** once to see the first report.
