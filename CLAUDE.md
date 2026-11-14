# Segoy

Segoy is an open-source kit that turns Claude Code + GitHub into a personal idea-to-implementation pipeline. This repo is the generic tool. It is public. A separate private "brain" repo (the owner's is called Roke) holds everything personal.

The Android companion app, Otak, lives in its own repo; its spec is `docs/otak-app-spec.md` and the contract between skills and the app is `docs/protocol.md`. Any change to what a skill posts (comments, PR bodies, labels) must keep that protocol valid.

Read before working: `docs/prd.md`, `docs/architecture.md`, `docs/workflows.md`, `docs/brain-design.md`. Current milestone and tasks: `docs/bootstrap-plan.md`.

## Hard rules

1. **Nothing personal in this repo.** No names, e-mail addresses, private project names, preferences, or content from a brain repo. Examples use placeholders (`<owner>`, `I-20260101-1`, "example idea"). If personal information appears in a request, put it in the brain repo instead and say so.
2. **Never push to `main`. Never merge.** Work on `claude/<kind>-<slug>` branches and open PRs.
3. **Plan before building.** For anything beyond a trivial fix, write the plan (in the PR description or `docs/specs/<id>/plan.md`) and wait for approval.
4. **Thin triggers, fat skills.** Procedure goes in `kit/**/SKILL.md`. Files in `tasks/` only say which skill to run on which event, plus setup notes.
5. **Verify platform behaviour, do not assume it.** Claude Code cloud features change. If the docs here disagree with what you observe, stop and report; then fix the docs in the same PR as the code.
6. **Generic first.** Every value that differs per user comes from `.segoy/config.yml` in the target repo.

## Layout

- `design-system/` — the Segoy design system (tokens, brand book, `sg-` CSS components, `scripts/build.py`). Source of truth for every Segoy UI, including the Otak app. Do not add hues; add a component here before building it elsewhere.
- `kit/common/` — vendored into every repo (leak guard).
- `kit/project/` — vendored into project repos (implement, review, retro).
- `kit/brain/` — template for a brain repo (capture, triage, spec, plan, promote, knowledge, review).
- `tasks/` — scheduled-task prompts and setup instructions.
- `scripts/segoy` — `init brain`, `init project`, `sync`, `doctor`. POSIX shell, `git`, `gh`, `jq` only.
- `tests/` — fixtures and checks.
- `docs/` — design docs, ADRs (`docs/adr/`), pipeline output (`docs/specs/`, `docs/retros/`).
- `.claude/` — this repo's own vendored copy of the kit. Do not edit by hand; change `kit/` and run `scripts/segoy sync .`.

## Commands

- Build design system and check contrast: `python3 design-system/scripts/build.py` (`--check` to only check)
- Lint scripts: `shellcheck scripts/lib/*.sh tests/*.sh` (add `scripts/segoy` and `kit/**/*.sh` once they exist; CI picks them up automatically)
- Lint skills: `scripts/lib/lint-skills.sh` (frontmatter and required sections; `scripts/segoy doctor --skills` will wrap it from M1)
- Tests: `tests/run.sh`
- Sync kit into this repo: `scripts/segoy sync .`

(Commands appear as milestones deliver them; if one is missing, it has not been built yet.)

## Skill format

Every `SKILL.md`:

```markdown
---
name: <kebab-case>
description: <one sentence: when to use this skill>
---
## Inputs
## Preconditions (exit quietly if not met)
## Procedure (numbered, imperative, each step checkable)
## Output contract (files, labels, comments, PRs — exact names and formats)
## Stop conditions and budget
## Never
```

Keep skills under ~150 lines. Put long templates in sibling files and reference them. Write for a reader with no prior context: the skill runs in a fresh cloud session.

## Conventions

- Idea IDs `I-<yyyymmdd>-<n>`; decision IDs `D-<yyyymmdd>-<n>`.
- Branches `claude/<spec|plan|impl|retro|review|chore>-<id-or-slug>`.
- PR labels `segoy:spec|plan|impl|retro|review|knowledge`.
- Commits: `<id or area>: <imperative summary>`.
- Markdown: relative links, YAML frontmatter on pipeline files, no wiki-link syntax.
- ADRs: `docs/adr/NNN-title.md` with Context / Decision / Consequences / Revisit when.

## Definition of done for a PR here

- Shell passes shellcheck; skills pass the frontmatter lint; tests pass.
- A changed skill has an updated fixture or a dry-run transcript in the PR.
- Docs updated where behaviour changed.
- No personal data (the leak check passes).
- PR body: what, why, how verified, follow-ups.
