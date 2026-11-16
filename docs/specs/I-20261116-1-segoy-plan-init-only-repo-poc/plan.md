---
id: I-20261116-1
title: segoy-plan states that an init-only repo counts as new (PoC needed)
kind: plan
state: planned
visibility: shareable
created: 2026-11-16
updated: 2026-11-16
source: promoted
links: []
---
# Plan: segoy-plan states that an init-only repo counts as new (PoC needed)

## Assumptions
- PoC: not needed (existing repo)
- This is a wording clarification only; planning behaviour does not change (firm, owner-stated)
- "New project" means: the target repo is missing, or holds only the `segoy init project` scaffold and no commits of its own (firm, owner-stated)
- "No commits of its own" means no commits beyond the one(s) that added the init scaffold. The current test ("only the scaffold and no earlier plans in `docs/specs/`") stays as the practical check, since an init-only repo has no plans; the new wording names the rule it implements (likely, `kit/brain/.claude/skills/segoy-plan/SKILL.md`)
- "Missing" is kept in the wording as the spec asks, although a new repo is normally set up before its spec is merged (Flow G), so the plan step rarely sees it (likely, `docs/workflows.md`)
- Only `SKILL.md` of `segoy-plan` changes; `template.md`, Flow C in `docs/workflows.md` and the changelog are left as they are (spec criterion 4; DRY/YAGNI/KISS) (firm, spec)

## Approach
Rewrite the first sentence of step 4 ("PoC check") in `kit/brain/.claude/skills/segoy-plan/SKILL.md` so it states the rule explicitly: a target repo that is missing, or holds only the `segoy init project` scaffold with no commits of its own (and so no earlier plans in `docs/specs/`), counts as a new project and needs a PoC as its first task group. The two sub-bullets and the owner-skip clause stay as they are. The changed skill reaches brains through `segoy sync`.

## Components touched
- `kit/brain/.claude/skills/segoy-plan/SKILL.md`: step 4, first sentence reworded.

## Task groups
### T1 Reword the PoC check in segoy-plan step 4
- Files: `kit/brain/.claude/skills/segoy-plan/SKILL.md`
- Steps:
  1. Replace the first sentence of step 4 with wording that says: the project is new when the repo is missing, or holds only the `segoy init project` scaffold with no commits of its own (so no earlier plans in `docs/specs/`); a new project needs a PoC as its first task group, unless the owner asked to skip it in a comment on the spec PR or the idea's issue.
  2. Leave the "Needed" and "Not needed" sub-bullets and every other line unchanged.
- Check: `git diff --stat main` → one file, one or two lines; `scripts/segoy doctor --skills` → exit 0; `tests/run.sh` → all pass
- Covers criteria: 1, 4

### T2 Dry-run the reworded step
- Files: none committed; transcript in the PR body
- Steps:
  1. Apply the reworded step 4 to two cases: a repo freshly created by `segoy init project` (scaffold commit only), and this repo (commits of its own, earlier plans in `docs/specs/`).
  2. Record the outcome for each in the PR body: the first gets `T1 PoC: …`; the second gets `PoC: not needed (existing repo)` and no PoC task group.
- Check: the dry-run transcript shows a PoC `T1` for the init-only repo and a `PoC: not needed` line for the existing repo, matching the decision the unchanged wording gives
- Covers criteria: 2, 3

Coverage: 1 → T1; 2 → T2; 3 → T2; 4 → T1.

## Test plan
- Criterion 1: read the new step 4 in the diff.
- Criteria 2 and 3: the T2 dry run on an init-only repo and on this repo, compared with the old wording's outcome (same result = unchanged behaviour).
- Criterion 4: `git diff --stat` shows only `segoy-plan/SKILL.md` with wording changes.
- Regression: `scripts/segoy doctor --skills` and `tests/run.sh`; leak check in project CI.

## Risks
- "No commits of its own" read literally could exclude a repo whose only commit is the init scaffold made by the owner → the wording says "beyond the init scaffold", tied to the existing `docs/specs/` check.
- Wording drifts from Flow C in `docs/workflows.md` → Flow C already says "only the scaffold and no earlier plans", which stays consistent; no edit needed.

## Rollout
Merge, then run `segoy sync` in the brain so its vendored `segoy-plan` picks up the wording. No labels, tasks or protocol fields change.

## Size
S
