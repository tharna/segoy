# Task: project-retro (one per project repo)

Writes the retro after you merge a Gate 2 PR. Skill: `segoy-retro`.

| Setting | Value |
|---|---|
| Repository | `<owner>/<repo>` only |
| Model | Sonnet |
| Trigger | GitHub event → `<owner>/<repo>` → **Pull request → closed**; filters **Is merged** = true, **Labels** contains `segoy:impl` |
| Schedule / connectors | none / **remove all** |

## Prompt

```
Run the segoy-retro skill for the merged segoy:impl pull request in the GitHub
trigger context; without a context, use its Run now rule.
Follow .claude/skills/segoy-retro/SKILL.md exactly. Push only to a new claude/ branch.
```

## Notes
- The retro is a small PR (`segoy:retro`) adding `docs/retros/<id>-<slug>.md`. Merge it when it reads right.
- The brain learns from it later (weekly review, M5).
