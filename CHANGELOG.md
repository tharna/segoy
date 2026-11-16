# Changelog

All notable changes to Segoy. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and versions follow [Semantic Versioning](https://semver.org/). Each version has a `v<x.y.z>` tag and a GitHub release. Before 1.0, a minor version may break things; the entry says how to move.

A version that needs more than `segoy sync` has a note in [`migrations/`](migrations/README.md); `segoy sync` lists the ones a repo has not had yet.

## Unreleased

### Added
- Brain skill `segoy-weekly-review` and task `tasks/brain-weekly-review.md` (Sunday 18:00 Europe/Helsinki): one `segoy:review` PR a week with the journal digest, notes filed to `knowledge/raw/`, decision records, parked and rejected idea stubs, state corrections, stuck ideas and at most five ways proposals; nothing in an empty week (I-20261116-2). Run `segoy sync` in the brain and create the task by hand.
- Protocol `review` block (§3.9), validated by `protocol.sh`.

### Changed
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
