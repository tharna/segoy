# kit

Files that `scripts/segoy` vendors into other repos. Never edited in place in a target repo; change them here and run `scripts/segoy sync`.

- `common/` — vendored into every repo (leak guard). Milestone M2.
- `project/` — vendored into project repos (implement, review, retro). Milestone M3.
- `brain/` — template for a brain repo (capture, triage, spec, plan, promote, knowledge, review). Milestone M1.

Every skill follows the format in the root `CLAUDE.md` and must pass `scripts/lib/lint-skills.sh`.
