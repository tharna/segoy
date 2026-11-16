---
id: I-20261116-3
title: Weekly review - no "proposed" marker in ways bullets
kind: retro
visibility: shareable
created: 2026-11-16
updated: 2026-11-16
source: "#36"
links: [../specs/I-20261116-3-weekly-review-no-proposed-marker-in-ways/spec.md, ../specs/I-20261116-3-weekly-review-no-proposed-marker-in-ways/plan.md]
---
# Retro: Weekly review - no "proposed" marker in ways bullets (I-20261116-3)

Gate 1: #35 · Gate 2: #36 · Merged: 2026-11-16

## Planned vs built
- T1 Skill, templates, task and docs in one commit: done, with deviations (below).
- T2 Checks and dry run: done; fixture run B now uses the `no-marker/` ways file.
- Deviations listed in [#36](https://github.com/tharna/segoy/pull/36): the Never list also says the step 9 cleanup is the only other edit to existing bullets; `records.md` avoids naming `(proposed)` a second time; the CHANGELOG entry and the `tests/run.sh` label were reworded.
- Criteria: 7 pass, 0 fail, 0 unclear (see [#36](https://github.com/tharna/segoy/pull/36)).

## What went wrong or was slow
- The verifier first rated criterion 6 (no marker, no cleanup edit) unclear: the skill only implied it. One fix round in the third commit stated it in step 9, so the canonical sentences and the no-marker sentence landed in different commits ([#36](https://github.com/tharna/segoy/pull/36)).
- Criteria 3 and 4 are verified on the fixture only; the brain still holds old-marker bullets, so the first live weekly review is the real test ([#36](https://github.com/tharna/segoy/pull/36)).

## Review feedback
- Gate 1: replaced rules are deleted in the same diff, with no strike-through in `ways/`, and the PR body and digest list what they replace ([comment](https://github.com/tharna/segoy/pull/35#issuecomment-6922714105)).
- Gate 2: no review comments; merged without revise rounds ([#36](https://github.com/tharna/segoy/pull/36)).

## Proposed rule changes
- When a verifier rates a criterion unclear because the skill only implies the behaviour, state it in the skill text before adding fixtures (evidence: [#36](https://github.com/tharna/segoy/pull/36)).
- For a skill change that must keep one wording in several files, add a check that finds the sentence verbatim in each file (evidence: criterion 7 in [#36](https://github.com/tharna/segoy/pull/36)).
