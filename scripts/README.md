# scripts

POSIX shell, `git`, `gh`, `jq` only. Note: GitHub GraphQL is not reachable from cloud sessions, so use `gh api` REST calls, not `gh issue`/`gh pr`/`gh label` subcommands.

- `segoy` — entry point (`init brain`, `init project`, `sync`, `doctor`). Milestones M1–M4.
- `lib/lint-skills.sh` — checks `SKILL.md` frontmatter and required sections. Used by CI; `segoy doctor --skills` will wrap it.
