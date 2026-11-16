# Changelog

All notable changes to Segoy. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and versions follow [Semantic Versioning](https://semver.org/). Each version has a `v<x.y.z>` tag and a GitHub release. Before 1.0, a minor version may break things; the entry says how to move.

A version that needs more than `segoy sync` has a note in [`migrations/`](migrations/README.md); `segoy sync` lists the ones a repo has not had yet.

## Unreleased

### Changed
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
