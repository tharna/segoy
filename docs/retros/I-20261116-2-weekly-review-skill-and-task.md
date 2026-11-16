---
id: I-20261116-2
title: Weekly review skill and task for the brain
kind: retro
visibility: shareable
created: 2026-11-16
updated: 2026-11-16
source: "#33"
links: [../specs/I-20261116-2-weekly-review-skill-and-task/spec.md, ../specs/I-20261116-2-weekly-review-skill-and-task/plan.md]
---
# Retro: Weekly review skill and task for the brain (I-20261116-2)

Gate 1: #32 · Gate 2: #33 · Merged: 2026-11-16

## Planned vs built
- T1 Protocol: define the `review` block: done ([#33](https://github.com/tharna/segoy/pull/33)).
- T2 Skill `segoy-weekly-review`: done.
- T3 Task `brain-weekly-review`: done; revised once after review (see below).
- T4 Checks and dry run: done, with deviations (below).
- T5 Docs: done. `tasks/README.md` left unchanged because it does not list tasks.
- Deviations listed in #33: `pr-body.md` is checked with `protocol.sh` directly (template placeholders are not JSON); dry-run output is committed as fixtures; `protocol.sh` also enforces at most 5 proposals and a `ways/` target; a second run in one week appends to the journal file.
- Criteria: 12 pass, 0 fail, 0 unclear (see [#33](https://github.com/tharna/segoy/pull/33)).

## What went wrong or was slow
- The verifier first marked criterion 4 (no activity and no drift: no PR) unclear: the skill counted a stuck idea as a reason to open a PR. The skill and the empty fixture were aligned with the spec in commit `0c000e5` ([#33](https://github.com/tharna/segoy/pull/33)).
- One revise round: the task Notes still said "nothing stuck" for an empty week. Fixed in `3932b52` ([comment](https://github.com/tharna/segoy/pull/33#issuecomment-6921308637)).
- Criteria 2, 4 and 11 were verified from the skill text and a hand-run dry run; no agent has run the skill live yet ([#33](https://github.com/tharna/segoy/pull/33)).
- shellcheck was not installed in the revise session; no shell files changed in that round ([comment](https://github.com/tharna/segoy/pull/33#issuecomment-6921308637)).
- Gate 2 was merged about 18 minutes after it opened.

## Review feedback
- One owner comment: the task Notes must define an empty week as "no activity, nothing to file and no drift", say stuck ideas alone open no PR, and drop "nothing stuck" ([comment](https://github.com/tharna/segoy/pull/33#issuecomment-6921267522)).
- No review threads on #33; the only comment on #32 is the implement run block ([comment](https://github.com/tharna/segoy/pull/32#issuecomment-6921016411)).

## Proposed rule changes
- When a skill states an exit condition, copy the spec's wording of it into every file that restates it (skill, task notes) in the same commit (evidence: [comment](https://github.com/tharna/segoy/pull/33#issuecomment-6921267522)).
- When a skill's behaviour is checked by a hand-run dry run only, state in the Gate 2 PR which criteria rest on it and that the first live run is the real test (evidence: [#33](https://github.com/tharna/segoy/pull/33)).
