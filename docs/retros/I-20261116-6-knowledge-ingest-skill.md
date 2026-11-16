---
id: I-20261116-6
title: Knowledge ingest skill
kind: retro
visibility: shareable
created: 2026-11-16
updated: 2026-11-16
source: "#47"
links: [../specs/I-20261116-6-knowledge-ingest-skill/spec.md, ../specs/I-20261116-6-knowledge-ingest-skill/plan.md]
---
# Retro: Knowledge ingest skill (I-20261116-6)

Gate 1: [#39](https://github.com/tharna/segoy/pull/39) · Gate 2: [#47](https://github.com/tharna/segoy/pull/47) · Merged: 2026-11-16

## Planned vs built
- T1 Skill `segoy-ingest`: done, with two changes (below).
- T2 Task `brain-ingest`: done. `tasks/README.md` lists no tasks, so it was not changed.
- T3 Checks and dry run: done (`tests/check-ingest.sh`, fixture and transcript); `tests/check-kit-blocks.sh` also lists `segoy-ingest`, which the plan did not name.
- T4 Docs: done.
- Criteria: 9 pass, 0 fail, 0 unclear (see the Gate 2 PR). Evidence is static checks and a hand dry run; the first live PR is the real test.

## What went wrong or was slow
- `leak-guard.sh` flags the private block markers themselves, so a shareable page with a private block never passed. Step 3.9 now strips private blocks first ([#47 deviations](https://github.com/tharna/segoy/pull/47)).
- The plan's scope check, `git diff --name-only`, does not see new files. The verifier found it; step 3.10 now stages first and runs `git diff --cached --name-only` ([#47 deviations](https://github.com/tharna/segoy/pull/47)).
- The plan's T1 template check (strip fences, pipe to `protocol.sh -`) fails on placeholders; the template is checked as the weekly review's is ([#47 deviations](https://github.com/tharna/segoy/pull/47)).
- No revise rounds: one implement run, five commits, no comments on either PR.

## Review feedback
- None. Neither [#39](https://github.com/tharna/segoy/pull/39) nor [#47](https://github.com/tharna/segoy/pull/47) has owner review comments; both were merged.

## Proposed rule changes
- When a plan's check relies on a git or script behaviour (diff of new files, leak guard on markers), try it once on a fixture while planning (evidence: [#47 deviations](https://github.com/tharna/segoy/pull/47)).
- Reconcile the raw file name formats (`<yyyy-mm-dd>-<slug>` vs `<yyyymmdd>-<slug>`) in a follow-up spec, as the skill now accepts both (evidence: [#47 follow-ups](https://github.com/tharna/segoy/pull/47)).
