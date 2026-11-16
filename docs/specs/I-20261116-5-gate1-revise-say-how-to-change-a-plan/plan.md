---
id: I-20261116-5
title: Gate 1 revise - say how to change a plan
kind: plan
state: planned
visibility: shareable
created: 2026-11-16
updated: 2026-11-16
source: promoted
links: []
---
# Plan: Gate 1 revise - say how to change a plan

## Assumptions
- PoC: not needed (existing repo)
- Wording only: no plan-revision mode, no new label, task or skill step (firm, spec Constraints)
- Closing a Gate 1 PR already leads to a replan choice: `brain-gate-sync-<repo>` asks in the brain whether to replan, park or reject. The new wording points at that path and changes nothing about it (firm, `kit/brain/.claude/skills/segoy-gate-sync/SKILL.md` step 3)
- The canonical Gate 1 sentence, used verbatim in the promote template and in `docs/workflows.md`: "To change the plan, edit `plan.md` in this PR (commit to its branch), or close the PR to replan. A comment alone starts nothing." (likely, spec Outcomes)
- The places in the kit and its docs that restate the Gate 1 revise path are exactly two: `kit/brain/.claude/skills/segoy-promote/pr-body.md` line 21 and `docs/workflows.md` Flow D step 4. `tasks/project-implement.md`, `segoy-implement` and `docs/protocol.md` §5 already describe revise mode for `segoy:impl` only (likely, `grep -rn answered kit tasks docs`)
- The brain kit is not vendored into this repo's `.claude/` (only project skills are), so no `segoy sync .` is needed; brains get the new template with `segoy sync` (firm, `ls .claude/skills`)
- Gate 2 text (`segoy-implement/pr-body.md` in `kit/project/` and `.claude/`, and `docs/workflows.md` Flow D Gate 2 step) is not touched (firm, spec Out of scope)

## Approach
Replace the one Gate 1 sentence in the promote PR body template with the canonical sentence, and rewrite the Gate 1 step in `docs/workflows.md` so it lists merge (approve), edit `plan.md` in the PR (revise) and close (replan, park or reject via gate-sync), dropping the claim that the project-side implement task listens for `answered` on `segoy:plan` PRs. While there, the same step's contradictory "A close fires nothing" sentence goes, since gate-sync fires on close. Add a CHANGELOG line.

Because the change touches a skill template, a fixture and a check script prove it: a rendered example Gate 1 PR body in `tests/fixtures/promote/` and `tests/check-gate1-wording.sh`, run by `tests/run.sh`.

## Components touched
- `kit/brain/.claude/skills/segoy-promote/pr-body.md`: Gate 1 line.
- `docs/workflows.md`: Flow D Gate 1 step.
- `CHANGELOG.md`: `Unreleased` → `Changed` entry.
- `tests/fixtures/promote/pr-body.md` (new): example Gate 1 PR body rendered from the template, with valid `plan` and `run` blocks.
- `tests/check-gate1-wording.sh` (new), `tests/run.sh` (if it lists checks explicitly).

## Task groups
### T1 Reword the Gate 1 revise path
- Files: `kit/brain/.claude/skills/segoy-promote/pr-body.md`, `docs/workflows.md`, `CHANGELOG.md`.
- Steps:
  1. In `pr-body.md`, replace "To change something, comment and add the label `answered`. Close to reject." with the canonical sentence, so the line reads: "**Gate 1.** Merge to approve: implementation starts from this plan. To change the plan, edit `plan.md` in this PR (commit to its branch), or close the PR to replan. A comment alone starts nothing."
  2. In `docs/workflows.md` Flow D step 4, describe: merge (approve; fires `project-implement` and `brain-gate-sync-<repo>`); revise by the canonical sentence; close (fires `brain-gate-sync-<repo>`, which asks in the brain: replan, park or reject). Remove "comments and adds `answered` (revise)", the sentence about the project-side `implement` task listening for `answered` on `segoy:plan` PRs, and "A close fires nothing; …".
  3. CHANGELOG `Unreleased` → `Changed`: "Gate 1 PR text and `docs/workflows.md` say to edit `plan.md` in the PR or close it to replan; comment plus `answered` on a `segoy:plan` PR never started anything (I-20261116-5). Run `segoy sync` in the brain."
- Check: `grep -rn 'answered' kit/brain/.claude/skills/segoy-promote/pr-body.md` → no hit; `grep -rnE 'Gate 1.*answered|answered.*segoy:plan' kit tasks docs/workflows.md` → no hit; `grep -cF 'To change the plan, edit \`plan.md\` in this PR' kit/brain/.claude/skills/segoy-promote/pr-body.md docs/workflows.md` → 1 each; `git diff origin/main -- kit/project .claude` → empty; `git diff origin/main -U0 -- docs/workflows.md` touches only the Gate 1 step; `scripts/segoy doctor --skills` → pass.
- Covers criteria: 1, 2, 3, 4

### T2 Fixture and check
- Files: `tests/fixtures/promote/pr-body.md`, `tests/check-gate1-wording.sh`, `tests/run.sh`.
- Steps:
  1. Fixture: an example Gate 1 PR body for "example idea" `I-20260101-1`, filled from the new template, ending with valid `plan` and `run` blocks.
  2. Check script asserts: the fixture and the template contain the canonical sentence and no `answered` (criterion 1); `docs/workflows.md` Gate 1 step contains the canonical sentence and no `answered` or `implement` revise claim (criterion 2); the old-wording grep over `kit tasks docs/workflows.md` is empty (criterion 3); the Gate 2 line in both `segoy-implement/pr-body.md` copies and the Gate 2 step in `docs/workflows.md` still read as on `main` (criterion 4, fixed strings in the script); `leak-guard.sh` on the changed files exits 0 (criterion 5).
  3. Wire it into `tests/run.sh` if checks are listed there.
- Check: `tests/check-gate1-wording.sh` → exit 0; `tests/run.sh` → all pass; `shellcheck -x tests/*.sh` → clean; `scripts/segoy doctor --protocol tests/fixtures/promote/pr-body.md` → valid; `kit/common/.claude/scripts/leak-guard.sh` (or its path in `kit/common`) on every changed file → exit 0.
- Covers criteria: 1, 2, 3, 4, 5

## Test plan
- Criterion 1: template and fixture grep in T1 and T2.
- Criterion 2: Gate 1 step grep in T1; check script in T2.
- Criterion 3: old-wording grep over `kit`, `tasks`, `docs/workflows.md` (T1 check, T2 script).
- Criterion 4: empty `git diff` for `kit/project` and `.claude`; Gate 2 fixed strings in the T2 script.
- Criterion 5: leak guard on changed files in T2, plus the repo's CI leak check on the PR.

## Risks
- `docs/otak-app-spec.md` still lists "Request changes (comment + `answered` label)" for Gate 1 plan approvals. It is app design, outside the kit, and the spec limits scope to the kit and `docs/workflows.md`, so it is left as is → follow-up: decide whether Otak's Gate 1 "Request changes" opens the PR's `plan.md` for editing or is removed.
- Editing `plan.md` on the PR branch from a phone is awkward on GitHub mobile → the close-to-replan path is the phone-friendly alternative; both are named.
- Brains keep the old template until `segoy sync` → CHANGELOG says so; the kit-sync task opens the sync PR.

## Rollout
Merge the Gate 2 PR, then `segoy sync` (or the kit-sync task) in the brain. No migration note, no task change.

## Size
S
