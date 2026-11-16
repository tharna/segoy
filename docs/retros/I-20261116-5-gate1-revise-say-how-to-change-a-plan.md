---
id: I-20261116-5
title: Gate 1 revise - say how to change a plan
kind: retro
visibility: shareable
created: 2026-11-16
updated: 2026-11-16
source: "#43"
links: [../specs/I-20261116-5-gate1-revise-say-how-to-change-a-plan/spec.md, ../specs/I-20261116-5-gate1-revise-say-how-to-change-a-plan/plan.md]
---
# Retro: Gate 1 revise - say how to change a plan (I-20261116-5)

Gate 1: [#38](https://github.com/tharna/segoy/pull/38) · Gate 2: [#43](https://github.com/tharna/segoy/pull/43) · Merged: 2026-11-16

## Planned vs built
- T1 Reword the Gate 1 revise path: done ([#43](https://github.com/tharna/segoy/pull/43), commit 4cfc47d).
- T2 Fixture and check: done, with two deviations (below).
- Criteria: 5 pass, 0 fail, 0 unclear (see the Gate 2 PR).

## What went wrong or was slow
- The plan's T1 check grep (`Gate 1.*answered|answered.*segoy:plan`) also matched the `segoy-implement` SKILL.md description of Gate 2 revise, which criterion 4 says must stay unchanged. The check script greps the exact old Gate 1 phrases instead ([#43 deviations](https://github.com/tharna/segoy/pull/43)).
- The leak guard flagged the documented private-block marker line in `docs/workflows.md`, a line the PR does not change. The check script runs it with the CI skip flag ([#43 deviations](https://github.com/tharna/segoy/pull/43)).
- No revise rounds: one implement run, two commits, no review comments on either PR.

## Review feedback
- None. Neither [#38](https://github.com/tharna/segoy/pull/38) nor [#43](https://github.com/tharna/segoy/pull/43) has owner review comments; both were merged.

## Proposed rule changes
- When a plan's check is a grep over `kit`, `tasks` or `docs`, run it against `main` while planning and list any expected hits, so the check cannot match text that must stay unchanged (evidence: [#43 deviations](https://github.com/tharna/segoy/pull/43)).
- When a plan adds a check that runs the leak guard, state the CI skip flags it needs (evidence: [#43 deviations](https://github.com/tharna/segoy/pull/43)).
- Follow-up outside the retro rules: `docs/otak-app-spec.md` still lists "Request changes (comment + `answered` label)" for Gate 1; the owner decides whether to open `plan.md` for editing or drop it ([#43 follow-ups](https://github.com/tharna/segoy/pull/43)).
