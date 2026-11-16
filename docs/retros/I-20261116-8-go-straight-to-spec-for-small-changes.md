---
id: I-20261116-8
title: Go straight to the spec for small, clear changes
kind: retro
visibility: shareable
created: 2026-11-16
updated: 2026-11-16
source: "#51"
links: [../specs/I-20261116-8-go-straight-to-spec-for-small-changes/spec.md, ../specs/I-20261116-8-go-straight-to-spec-for-small-changes/plan.md]
---
# Retro: Go straight to the spec for small, clear changes (I-20261116-8)

Gate 1: [#42](https://github.com/tharna/segoy/pull/42) · Gate 2: [#51](https://github.com/tharna/segoy/pull/51) · Merged: 2026-11-16

## Planned vs built
- T1 Skill text: done ([#51](https://github.com/tharna/segoy/pull/51), commit edd5033), with one addition: step 5's opening also runs after `defaults`, so a `defaults` reply on a `kind:task` issue reaches the new bullet.
- T2 Docs, task and changelog: done, with one deviation (below).
- T3 Wording check and dry run: done, with one deviation (below). `tests/check-respond.sh` and `tests/fixtures/respond/transcript.md` were added.
- Criteria: 8 pass, 0 fail, 0 unclear (see the Gate 2 PR). Criteria 1, 4 and 7 rest on a hand-run dry run; the PR says the first live `kind:task` reply in the brain is the real test.

## What went wrong or was slow
- `docs/workflows.md` has two `kind:task` lines, while the plan's check said one hit each. Both lines were named in the plan's steps, so the check was wrong, not the change ([#51 deviations](https://github.com/tharna/segoy/pull/51)).
- The plan wanted the unchanged paused, claim-first and state-label lines checked against `origin/main`. That check would be trivially true after merge and fails in shallow CI checkouts, so the script pins the exact text instead ([#51 deviations](https://github.com/tharna/segoy/pull/51)).
- No revise rounds: one implement run, three commits, no review comments on either PR. Gate 2 was merged about four minutes after it opened.

## Review feedback
- None. Neither [#42](https://github.com/tharna/segoy/pull/42) nor [#51](https://github.com/tharna/segoy/pull/51) has owner review comments; both were merged.

## Proposed rule changes
- When a plan's check counts grep hits, run the grep on `main` while planning and write the expected count per file (evidence: [#51 deviations](https://github.com/tharna/segoy/pull/51)).
- When a plan needs a check that a line is unchanged, specify pinning its text, not a diff against `origin/main` (evidence: [#51 deviations](https://github.com/tharna/segoy/pull/51)).
- Open follow-ups in [#51](https://github.com/tharna/segoy/pull/51), for the owner to decide: set `target:` before handing over to `segoy-spec`; the output contract does not say the spec PR comment replaces the run comment on the spec path; no fixture covers a `defaults` reply on a `kind:task` issue.
