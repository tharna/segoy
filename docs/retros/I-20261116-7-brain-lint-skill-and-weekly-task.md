---
id: I-20261116-7
title: Brain-lint skill and weekly task
kind: retro
visibility: shareable
created: 2026-11-16
updated: 2026-11-16
source: "#49"
links: [../specs/I-20261116-7-brain-lint-skill-and-weekly-task/spec.md, ../specs/I-20261116-7-brain-lint-skill-and-weekly-task/plan.md]
---
# Retro: Brain-lint skill and weekly task (I-20261116-7)

Gate 1: [#41](https://github.com/tharna/segoy/pull/41) · Gate 2: [#49](https://github.com/tharna/segoy/pull/49) · Merged: 2026-11-16

## Planned vs built
- T1 Helper `brain-lint.sh` and fixture brains: done, with deviations (below).
- T2 Skill `segoy-lint`, label `segoy:lint`, protocol row: done.
- T3 Task `brain-lint` and criteria checks, dry run on fixture brains: done; checks wired into `tests/run.sh`.
- T4 Docs and kit sync into `.claude`: done.
- Criteria: 14 pass, 0 fail, 0 unclear (see [#49](https://github.com/tharna/segoy/pull/49)). Criteria 2, 3 and 5 are model behaviour, checked as stated text plus a dry-run transcript, not end to end.
- Six deviations from the plan are listed in the PR body: `id` required only under `ideas/` and `decisions/`; wiki `kind` derived from the subfolder; `projects/` and `ways/` pages without an index row are report-only; orphan pages are listed under `## Unfiled` in the wiki index; the fix PR body does not name the report issue; the dry-run `fix.diff` omits the `log.md` hunk.

## What went wrong or was slow
- The plan required `id` on every non-wiki page, but the kit's `self/` and `ways/` templates have none, so the rule would have flagged every fresh brain ([#49 deviations](https://github.com/tharna/segoy/pull/49)).
- The leak guard's phone-number rule matches a diff line with `+` before an ISO date, so the `log.md` hunk had to be left out of `fix.diff`; this took a separate last commit ([cff0a3e](https://github.com/tharna/segoy/commit/cff0a3e73f224a7d954b94753001d8bf52f84170)).
- The plan's order of commits shows T2 to T4 before T1 on the branch history ([#49 commits](https://github.com/tharna/segoy/pull/49/commits)); the Gate 2 PR does not say why.
- No revise rounds: no review comments on either PR.

## Review feedback
- None. Neither [#41](https://github.com/tharna/segoy/pull/41) nor [#49](https://github.com/tharna/segoy/pull/49) has owner review comments; both were merged.

## Proposed rule changes
- When a plan makes a frontmatter field required, check it against every kit template that creates such a file and list the exceptions in the plan (evidence: [#49 deviations](https://github.com/tharna/segoy/pull/49)).
- When a plan adds a fixture that stores diffs, name how the leak guard treats `+<date>` lines, or tighten that rule in the same plan (evidence: [#49 follow-ups](https://github.com/tharna/segoy/pull/49)).
- Follow-ups for the owner, not rules: orphan rule ignoring index links once a page is under `## Unfiled`; first live Saturday run is the check on contradiction noise on the small model ([#49](https://github.com/tharna/segoy/pull/49)).
