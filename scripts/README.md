# scripts

POSIX shell, `git`, `gh`, `jq` only.

GitHub from a cloud session (observed 2026-11-15):
- GraphQL is not reachable, so use `gh api` REST calls, not `gh issue` / `gh pr` / `gh label` subcommands.
- `gh auth status` reports the token as invalid, but REST calls work: the session proxy adds the credentials. Test access with `gh api user`, not `gh auth status`.
- On an HTTP error, `gh api` prints the response body (for example `"code":"already_exists"`) on **stdout** and only a one-line summary on stderr. Capture both when checking for a specific error.
- `GET repos/<o>/<r>/rules/branches/<b>` returns 403 "Upgrade to GitHub Pro" for a private repo on a free account: rulesets need GitHub Pro there (see T4.3).

- `segoy` — entry point. `init brain`, `init project`, `sync` and `doctor`. Run `scripts/segoy --help`.
- `lib/common.sh`, `lib/init.sh`, `lib/doctor.sh` — sourced by `segoy`.
- `lib/lint-skills.sh` — checks `SKILL.md` frontmatter and required sections (`segoy doctor --skills`).
- `lib/sync.sh` — `segoy sync`: update a repo's kit files from this Segoy.
- The `segoy` block validator lives in `kit/common/.claude/scripts/protocol.sh` (vendored everywhere; `segoy doctor --protocol` runs it).
