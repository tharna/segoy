---
id: I-20261116-4
title: Kit skills keep their protocol blocks valid
kind: retro
visibility: shareable
created: 2026-11-16
updated: 2026-11-16
source: "#45"
links: [../specs/I-20261116-4-segoy-skills-keep-protocol-blocks-valid/spec.md, ../specs/I-20261116-4-segoy-skills-keep-protocol-blocks-valid/plan.md]
---
# Retro: Kit skills keep their protocol blocks valid (I-20261116-4)

Gate 1: #37 · Gate 2: #45 · Merged: 2026-11-16

## Planned vs built
- Skill, template and doc changes (one commit, 9d9f497): done. All 11 posting skills have the same "Check blocks before posting" step; `segoy-spec` fixes `target`, the revise `decision` block and the PR body recount.
- `tests/check-kit-blocks.sh`: done; checks 15 kit files and 14 filled examples, mutation-tested.
- Criteria: 7 pass, 0 fail, 0 unclear (see [#45](https://github.com/tharna/segoy/pull/45)).
- Deviations listed in [#45](https://github.com/tharna/segoy/pull/45): one extra fixture (`revise/pr-body-stale.md`); `segoy-plan` check scoped to its failure comment; `segoy-triage` keeps the check as step 12 with step 11 deferring posting; later steps renumbered and in-file references updated.

## What went wrong or was slow
- Nothing failed or needed a revise round; Gate 2 was merged about four minutes after it opened ([#45](https://github.com/tharna/segoy/pull/45)).
- Criteria 1–5 and 7 are about skill instructions, so the evidence is skill text, fixtures and a dry run. The live test is the next spec revise and Gate 1 promotion in a brain ([#45](https://github.com/tharna/segoy/pull/45)).
- Open follow-up: `segoy-sync` writes its footer before the `migrate` lines are known (step 3.6); unchanged by this PR ([#45](https://github.com/tharna/segoy/pull/45)).

## Review feedback
- Gate 1 and Gate 2: no review comments on either PR ([#37](https://github.com/tharna/segoy/pull/37), [#45](https://github.com/tharna/segoy/pull/45)).

## Proposed rule changes
- After merging a kit skill change, run `segoy sync` in the brain and project repos before the next scheduled run (evidence: follow-ups in [#45](https://github.com/tharna/segoy/pull/45)).
- When a skill must post checked blocks in several places, compose the whole text first and post only after the check step (evidence: the `segoy-triage` step 11/12 deviation in [#45](https://github.com/tharna/segoy/pull/45)).
