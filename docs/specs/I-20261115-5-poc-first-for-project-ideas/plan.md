---
id: I-20261115-5
title: PoC first for project-sized ideas
kind: plan
state: planned
visibility: shareable
created: 2026-11-15
updated: 2026-11-15
source: promoted
links: []
---
# Plan: PoC first for project-sized ideas

## Assumptions
- **Scope differs from the spec text.** The spec says "No change to Segoy". Before merging the spec, the owner commented "target segoy, add workflow step to check the need of poc" and set the target to this repo; the spec text was not revised. This plan follows the comment: it adds a PoC check step to the `segoy-plan` skill. If the spec text should win instead, close this PR (likely, owner-stated)
- "New project" at plan time means: the target repo holds only the `segoy init project` scaffold and no earlier plans in `docs/specs/`. A new repo is set up before its spec is merged (Flow G), so "the repo does not exist" cannot be the test (guess, `docs/workflows.md`)
- The PoC can be skipped when the owner says so in a comment on the spec PR; the plan then records "PoC skipped (owner)". This takes the spec's open question default (likely, spec)
- The rule bullet in the owner's public ways of working is a separate one-line change in the brain, not part of this PR (likely, brain)
- Keep it minimal: one step in one skill, one line in its template, one line in the workflow doc (firm, brain)

## Approach
`segoy-plan` gets one decision before it writes task groups: does this idea need a PoC? If the target is a new project (and the owner did not ask to skip it), `T1` becomes a PoC task group: titled `PoC: <assumption>`, naming the riskiest assumption of the spec, one short task, nothing beyond what tests that assumption. Otherwise the plan says in one assumption line why no PoC is needed. The plan template and the Flow C description in `docs/workflows.md` mention the step. Nothing else in the pipeline changes: the PoC is an ordinary first task group, so `implement` and multi-PR plans already handle it.

## Components touched
- `kit/brain/.claude/skills/segoy-plan/SKILL.md`: new procedure step "PoC check" before writing the plan; output contract and stop conditions mention it.
- `kit/brain/.claude/skills/segoy-plan/template.md`: a `PoC:` assumption line and a note that `T1` is the PoC when one is needed.
- `docs/workflows.md`: Flow C, plan step, one sentence on the PoC check.

## Task groups
### T1 Add the PoC check to segoy-plan
- Files: `kit/brain/.claude/skills/segoy-plan/SKILL.md`, `kit/brain/.claude/skills/segoy-plan/template.md`
- Steps:
  1. Add a step after "Consult before assuming": decide whether a PoC is needed. Needed when the target repo holds only the init scaffold and no earlier `docs/specs/` plans, unless the owner asked to skip it on the spec PR or issue.
  2. When needed: `T1` is titled `PoC: <riskiest assumption>`, states the assumption it tests and how the result is judged, fits one short task, and adds no feature beyond that assumption. Later task groups depend on it.
  3. When not needed: one assumption line `PoC: not needed (<existing repo | target none | owner skipped>)`.
  4. Add the `PoC:` line and the `T1` note to `template.md`; add the PoC to the coverage check before handover.
  5. Keep the skill under ~150 lines and in the required section format.
- Check: `scripts/segoy doctor --skills` → exit 0; `wc -l kit/brain/.claude/skills/segoy-plan/SKILL.md` → under 150
- Covers criteria: 2, 3, 4

### T2 Document the step and show it working
- Files: `docs/workflows.md`; dry-run transcript in the PR body
- Steps:
  1. Add one sentence to Flow C step 2 (plan) on the PoC check.
  2. Dry-run the changed skill on two example specs: one targeting a freshly scaffolded repo, one targeting an existing repo. Put both resulting plan headers (assumptions and `T1`) in the PR body.
- Check: `tests/run.sh` → all pass; the dry run for the new repo has `T1 PoC: …` naming one assumption with a single short task; the dry run for the existing repo has a `PoC: not needed` line and no PoC task group
- Covers criteria: 2, 3, 4

### T3 Record the rule in the owner's public ways (outside this repo)
- Files: none in this repo; one bullet in the brain's public principles
- Steps: after this PR merges, the owner (or a brain session) adds the bullet "Plans for ideas targeting a new repo start with a minimal PoC as their first milestone" with source and date.
- Check: the bullet is present in the brain's public ways with `(source: …, <date>)`
- Covers criteria: 1

Coverage: 1 → T3; 2 → T1, T2; 3 → T1, T2; 4 → T1, T2.

## Test plan
- Skill format: `scripts/segoy doctor --skills` (frontmatter, required sections).
- Regression: `tests/run.sh`.
- Behaviour: the two dry runs in T2 prove criteria 2, 3 and 4 (PoC first and minimal for a new repo; none for an existing repo). Criterion 1 is checked in the brain after rollout.
- Leak check passes on the PR (project CI).

## Risks
- "New project" detection is heuristic → if it misfires, the owner sees the `PoC:` line at Gate 1 and can comment; the rule is easy to tighten later.
- The merged spec text and this plan disagree on whether Segoy changes → stated as the first assumption so Gate 1 decides it.
- A PoC that grows into the full build → the step caps it at one short task and one assumption.

## Rollout
Merge this PR, then run `scripts/segoy sync` in the brain so its vendored `segoy-plan` picks up the step. Add the ways bullet (T3) in the brain. No new labels, tasks or protocol fields.

## Size
S
