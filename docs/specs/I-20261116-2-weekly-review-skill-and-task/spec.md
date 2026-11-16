---
id: I-20261116-2
title: Weekly review skill and task for the brain
kind: idea
state: specced
visibility: shareable
created: 2026-11-16
updated: 2026-11-16
source: promoted
links: []
---
# Spec: Weekly review skill and task for the brain

## Problem
Housekeeping in the brain has no routine owner. Notes that triage deferred are never filed, gate outcomes (parked, rejected, changed) leave no stubs or decision records, idea states can drift from reality, stuck ideas go unnoticed, and lessons from retros or repeated friction (triage misreads, extra question rounds) are not turned into proposals.

## Users and context
The brain owner, reviewing on a phone or desktop. The review runs unattended on a schedule and the owner accepts or rejects its output by merging or closing one PR.

## Outcomes
- Once a week the brain receives exactly one review PR, or none when there is nothing to propose.
- The owner can accept the whole review, or edit it, with ordinary PR review.
- No file in the brain changes without a merge.

## In scope
- A skill `segoy-weekly-review` and a scheduled task definition `brain-weekly-review` in the Segoy kit, with vendoring through `segoy sync`.
- One PR per run containing, as applicable:
  1. a journal digest for the period (`journal/`);
  2. notes filed into `knowledge/raw/` where triage deferred them (wiki pages are the ingest idea's job, not this review's);
  3. stubs for parked and rejected ideas, and decision records for gate outcomes;
  4. corrections of idea states that drifted from issue/PR reality;
  5. a list of stuck ideas (no state change beyond a threshold);
  6. `log.md` entries for the week's operations, filed in the same batch as the notes and stubs;
  7. proposed changes to `ways/` from retros and brain-side friction, each with evidence and marked `proposed`.
- Schedule: Sunday 18:00 Europe/Helsinki. Period: the 7 days ending at run time.

## Out of scope
- Merging, approving or closing anything; direct commits to the default branch.
- Applying ways changes outside the PR; writing to `self/` or inferring personal facts.
- Writing to any repository other than the brain.
- Changing existing skills' behaviour.

## Acceptance criteria
1. Given the task definition, when it is inspected, then it names the `segoy-weekly-review` skill and the schedule Sunday 18:00 Europe/Helsinki.
2. Given an open issue labelled `segoy:paused`, when the skill runs, then it posts and changes nothing.
3. Given activity in the 7 days before run time, when the skill runs, then it opens one PR labelled `segoy:review` whose body ends with a `run` block and whose changes are limited to the files in scope.
4. Given a week with no activity and no drift, when the skill runs, then it opens no PR.
5. Given a parked or rejected idea or a gate outcome with no decision record, when the skill runs, then the PR adds the stub or record with valid frontmatter and a source link, and appends a matching `log.md` entry.
6. Given notes filed into `knowledge/raw/`, when the PR is created, then no file under `knowledge/wiki/` is changed.
7. Given an idea whose `state` disagrees with its issue labels or PR status, when the skill runs, then the PR corrects the state and lists the correction in the digest.
8. Given ideas with no state change for more than 14 days, when the skill runs, then the digest lists them with their current state.
9. Given friction evidence (e.g. more than one question round, or a triage correction by the owner), when the skill proposes a `ways/` change, then it is written as a bullet marked `proposed` with a cited source, and no existing `ways/` rule is rewritten without the proposal being visible in the diff.
10. Given any run, when the PR is created, then the shareable parts pass the leak check and nothing from `self/` is copied outside it.
11. Given a run, when it finishes, then the agent has not merged, approved or pushed to the default branch.
12. Given the implementation, when reviewed, then it is a single PR in the Segoy repo that includes the skill, the task definition, and checks for criteria 1–11.

## Constraints
- The implementation must fit one PR. If the plan is sized L, split into separate ideas: digest and filing first, ways proposals second.
- Follows Segoy protocol (`segoy` blocks, labels carry state, one `state:*` per issue).
- Runs on the model configured for lint/respond-class tasks unless the plan argues otherwise.

## Open questions
None. The owner accepted the defaults for the three earlier questions; they are recorded as assumptions.

## Assumptions
- Work happens in the existing Segoy kit, so the PoC-first rule does not apply (likely, owner-stated)
- `ways/` changes are proposals in the PR, never applied directly (firm, owner-stated)
- The PR is the only output and is never merged by the agent (firm, owner-stated)
- The review PR is labelled `segoy:review` (likely, owner-stated default)
- Stuck threshold is 14 days without a state change (likely, owner-stated default)
- If the plan is size L, ways proposals are split into a follow-up idea (likely, owner-stated default)
