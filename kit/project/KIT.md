# kit/project

Vendored into project repos by `segoy init project` (on top of `kit/common`):

- `CLAUDE.md.tmpl` → `CLAUDE.md`, filled with the repo name and the brain's `ways/public/` (`--ways`), leak-checked before it is written. An existing `CLAUDE.md` is never touched.
- `.claude/settings.json` + `.claude/hooks/leak-check-commit.sh`: blocks a `git commit` whose staged files fail the leak check (single-repo sessions only; hooks do not run with two repos).
- `.claude/scripts/project-leak-check.sh`: `leak-guard.sh` with this repo's `leak_skip_rules` / `leak_exclude` from `.segoy/config.yml`. Used by the hook and the workflow.
- `.github/workflows/segoy-leak-check.yml`: the same check on every PR (ADR-017 layer 2).
- `.segoy/labels.json`, `.segoy/config.yml.tmpl`, `docs/specs/`, `docs/retros/`.
- Skills (`segoy-implement`, `segoy-retro`) and agents (`implementer`, `verifier`) arrive in M3 PR 2.
