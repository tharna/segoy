# Changelog

All notable changes to Segoy. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and versions follow [Semantic Versioning](https://semver.org/). Each version has a `v<x.y.z>` tag and a GitHub release. Before 1.0, a minor version may break things; the entry says how to move.

A version that needs more than `segoy sync` has a note in [`migrations/`](migrations/README.md); `segoy sync` lists the ones a repo has not had yet.

## Unreleased

### Added
- Brain skill `segoy-weekly-review` and task `tasks/brain-weekly-review.md` (Sunday 18:00 Europe/Helsinki): one `segoy:review` PR a week with the journal digest, notes filed to `knowledge/raw/`, decision records, parked and rejected idea stubs, state corrections, stuck ideas and at most five ways proposals; nothing in an empty week (I-20261116-2). Run `segoy sync` in the brain and create the task by hand.
- Protocol `review` block (§3.9), validated by `protocol.sh`.
- Brain skill `segoy-ingest` and task `tasks/brain-ingest.md` (merged brain PR, plus Run now): one `segoy:knowledge` PR per new file under `knowledge/raw/`, with a source summary, updates to every wiki page the source bears on, new pages only where none exists, the wiki index and one `log.md` line; raw files are never changed (I-20261116-6). New template folder `knowledge/wiki/sources/`. Run `segoy sync` in the brain, create the task by hand and press Run now once to ingest raw files already there.
- Brain skill `segoy-lint`, task `tasks/brain-lint.md` (Saturday 18:00 Europe/Helsinki, Haiku) and helper `.claude/scripts/brain-lint.sh`: one `Lint <date>` report issue a week with contradictions (quoted, never resolved), orphan and stale wiki pages, missing frontmatter, index drift and stuck ideas, plus at most one `segoy:lint` PR that fixes only derivable frontmatter and index rows; nothing when the brain is clean (I-20261116-7). New label `segoy:lint`. Run `segoy sync` in the brain (it adds the label) and create the task by hand.

### Changed
- `segoy-respond` starts the spec in the same run when the owner fully answers a `kind:task` issue's questions (or replies `defaults`), with no `/spec` round; `kind:idea` issues still wait for `/spec`. Answers sent together with `/spec` or `/plan` are now applied, and only unanswered questions take defaults (I-20261116-8). Run `segoy sync` in the brain.
- Every kit skill that posts or writes `segoy` blocks has the same "Check blocks before posting" step: run `.claude/scripts/protocol.sh`, post only on exit 0, fix and re-check at most twice, else post only a `failed` `run` block. `segoy-spec` writes `target` without owner, gives its revise `decision` block `idea` (never `subject`) with a new *Revise comment* template, and recounts the PR body's `spec` block after a revision. `tests/check-kit-blocks.sh` checks every block example in the kit (I-20261116-4). Run `segoy sync` in the brain and project repos.
- Gate 1 PR text and `docs/workflows.md` say to edit `plan.md` in the PR or close it to replan; comment plus `answered` on a `segoy:plan` PR never started anything (I-20261116-5). Run `segoy sync` in the brain.
- `segoy-weekly-review` writes `ways/` proposals as final bullets with no `proposed` marker, since merging the review PR accepts them; the PR body and the digest list them as proposals, and a replaced rule is deleted in the same diff. Each run also removes a leftover `(proposed; ` marker from `ways/` bullets on the default branch and lists them in the digest under "Markers removed" (I-20261116-3). Run `segoy sync` in the brain; the next weekly review cleans the old markers.
- `segoy-plan` step 4 states that a target repo that is missing, or holds only the `segoy init project` scaffold with no commits of its own, counts as a new project and needs a PoC first (I-20261116-1; behaviour unchanged).

### Fixed
- `segoy sync --pr-footer` refuses a footer whose `segoy` blocks fail `protocol.sh`, and the `segoy-sync` skill lists every `run` field, after a sync PR carried `"type"` instead of `"kind"`.

## 0.1.0 - 2026-11-16

First version used end to end: an idea captured on a phone went through spec, plan (Gate 1), implementation (Gate 2) and retro.

### Added
- Brain kit (`kit/brain`): folder skeleton, labels, config, and the skills `segoy-capture`, `segoy-triage`, `segoy-respond`, `segoy-onboard`, `segoy-spec`, `segoy-plan`, `segoy-promote`, `segoy-gate-sync` (M1, M2).
- Project kit (`kit/project`): `CLAUDE.md` template with the brain's public ways, the skills `segoy-implement` and `segoy-retro`, the `implementer` and `verifier` agents, a leak-check commit hook and CI workflow (M3).
- Common kit (`kit/common`): `leak-guard.sh`, `strip-private.sh`, `protocol.sh`, and the `segoy-sync` skill.
- `scripts/segoy`: `init brain`, `init project`, `sync` (with `--pr`), `doctor` (`--offline`, `--skills`, `--protocol`).
- Protocol v1 (`docs/protocol.md`): labels and JSON `segoy` blocks `question`, `answer`, `run`, `spec`, `plan`, `decision`, `impl`.
- Scheduled-task setups in `tasks/`: triage, respond, plan-promote, gate-sync, implement, retro, kit-sync.
- Design system (`design-system/`): tokens, brand book, `sg-` CSS components, contrast check.
- ADRs 015–022 and the platform spike log (`docs/adr/`).
