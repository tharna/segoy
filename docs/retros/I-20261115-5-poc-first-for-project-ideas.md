---
id: I-20261115-5
title: PoC first for project-sized ideas
kind: retro
visibility: shareable
created: 2026-11-16
updated: 2026-11-16
source: "#22"
links: [../specs/I-20261115-5-poc-first-for-project-ideas/spec.md, ../specs/I-20261115-5-poc-first-for-project-ideas/plan.md]
---
# Retro: PoC first for project-sized ideas (I-20261115-5)

Gate 1: #16 · Gate 2: #22 · Merged: 2026-11-16

## Planned vs built
- T1 Add the PoC check to segoy-plan: done (step 4 in `segoy-plan/SKILL.md`; 3 commits on the PR).
- T2 Document the step and show it working: done (Flow C in `docs/workflows.md`; two dry runs, new-repo and existing-repo).
- T3 Record the rule in the owner's public ways: not in this repo by design; left for after merge.
- Changed: the `target none` reason was dropped from the `PoC: not needed` list, since `segoy-plan` stops before planning for that target ([#22](https://github.com/tharna/segoy/pull/22)).
- Added: a `- Judged:` line in the PoC task group of `template.md` ([#22](https://github.com/tharna/segoy/pull/22)).
- Criteria: 3 pass, 0 fail, 1 unclear (criterion 1, the ways bullet, lives outside this repo; see [#22](https://github.com/tharna/segoy/pull/22)).

## What went wrong or was slow
- shellcheck was not installed in the cloud environment, so it was not run; no shell file changed ([#22](https://github.com/tharna/segoy/pull/22)).
- The plan noted the spec said "No change to Segoy" while the owner asked for this step; the plan followed the request ([#16](https://github.com/tharna/segoy/pull/16)).
- The dry run found an edge case: a scaffold with no commits counts as a new project, but step 4 does not say so ([#22](https://github.com/tharna/segoy/pull/22)).
- No revise rounds and no failed checks: `doctor --skills` 0 problems, `tests/run.sh` 47 passed.

## Review feedback
- None. Neither PR has review comments or owner comments; #22 was merged about 11 minutes after it opened ([#22](https://github.com/tharna/segoy/pull/22)).

## Proposed rule changes
- State in `segoy-plan` step 4 that a scaffold with no commits counts as a new project (evidence: [#22](https://github.com/tharna/segoy/pull/22), follow-ups).
- When a plan task group falls outside the repo, list the matching acceptance criterion as "verified after merge" in the plan, so Gate 2 does not report it as unclear (evidence: [#22](https://github.com/tharna/segoy/pull/22), criterion 1).
