---
id: I-20261116-8
title: Go straight to the spec for small, clear changes
kind: plan
state: planned
visibility: shareable
created: 2026-11-16
updated: 2026-11-16
source: promoted
links: []
---
# Plan: Go straight to the spec for small, clear changes

## Assumptions
- PoC: not needed (existing repo)
- "Every question settled" means: each question ID in the latest `question` block has an owner answer (in an `answer` block or one free-text line), or the reply is `defaults`. Questions left out and filled by the "omitted takes its default" rule do not count as settled, so a partial reply never starts the spec (guess, spec Assumptions and criterion 2)
- "Nothing new is unclear" stays a condition: if the answers raise a costly new question, the skill asks it (round + 1) and the automatic path does not run, within the three-round limit (likely, spec Constraints)
- A `kind:task` issue is one carrying the `kind:task` label set by triage; no other signal is read (likely, spec In scope, `segoy-triage` step on labels)
- The spec's open question takes its default: an issue whose target is unclear still goes straight to the spec, since `segoy-spec` handles a missing target (likely, spec Open questions)
- The automatic path reuses the existing `/spec` hand-over (set `state:triaged`, then `segoy-spec` create mode, own comment only if `segoy-spec` stopped before a PR), so criterion 7's single-label and single-comment outcome comes from code that already exists (likely, `kit/brain/.claude/skills/segoy-respond/SKILL.md` step 4)
- `/plan` behaves like `/spec` today, so the answers-are-kept rule applies to both (firm, spec criterion 8)
- Protocol blocks and labels do not change; no Otak change (firm, spec Out of scope)
- The brain kit is not vendored into this repo's `.claude/`, so no `segoy sync .` is needed; brains pick the change up with `segoy sync` (firm, `.claude/skills/` lists only project skills)
- Skill behaviour has no executable harness here, so criteria 1–7 are proved by a hand-run dry run on fixture issues plus wording checks; the first live `kind:task` reply in the brain is the real test (likely, earlier plans in `docs/specs/`)

## Approach
Reorder `segoy-respond` steps 4 and 5 so answers are always read first and commands act on top of them. Step 4 keeps `/park`, `/unpark`, `/reject`, the Gate 1 and Gate 2 replies and `defaults` as they are. For `/spec` and `/plan` the text changes from "take defaults for any open questions" to "apply the reply's answers first (step 5); only questions left unanswered take their defaults". The sentence "it wins over answers" is removed for `/spec` and `/plan` and kept, reworded, for `/park`, `/unpark` and `/reject`.

Step 5 gains one bullet after "All questions settled": when the issue is labelled `kind:task`, every question of the latest round is settled by this reply (assumption above) and nothing new is unclear, do what `/spec` does in the same run. A `kind:idea` issue keeps today's behaviour: `state:triaged` and the hint that `/spec` starts the spec. The paused precondition and the claim-first label removal are untouched, so criterion 6 holds by the existing preconditions.

Docs and the task file restate the rule; a wording check and a dry-run fixture back the change, as `CLAUDE.md` asks for any changed skill.

## Components touched
- `kit/brain/.claude/skills/segoy-respond/SKILL.md`: steps 4 and 5, output contract.
- `docs/workflows.md`: the "Answering" paragraph and Flow B (spec) start condition.
- `tasks/brain-respond.md`: one line on the automatic path for `kind:task`.
- `CHANGELOG.md`: `Unreleased` → `Changed`.
- `tests/check-respond.sh` (new), `tests/run.sh`, `tests/fixtures/respond/**` (new).

## Task groups
### T1 Skill text
- Files: `kit/brain/.claude/skills/segoy-respond/SKILL.md`
- Steps:
  1. Step 4 opening: "Apply a command if there is one" — drop "(it wins over answers)"; add to `/park`, `/unpark`, `/reject` that the command applies whatever answers the reply holds.
  2. Step 4 `/spec` or `/plan`: "apply the reply's answers to the latest round first (step 5 rules); take defaults only for questions left unanswered; set `state:triaged`; then run `segoy-spec` in create mode". Keep the rest of the bullet.
  3. Step 5: new bullet "**Small, clear change**: the issue has `kind:task`, every question of the latest round is answered in this reply or the reply is `defaults`, and nothing new is unclear → do what `/spec` does (step 4) in this run; do not stop at `state:triaged`." Reword the existing settled bullet to say it applies to `kind:idea` and to `kind:task` with a partial reply.
  4. Output contract: "`/spec`, `/plan`, or a fully answered `kind:task`: whatever `segoy-spec` produces".
- Check: `grep -n 'wins over answers' kit/brain/.claude/skills/segoy-respond/SKILL.md` → no hit; `grep -c 'kind:task' …/SKILL.md` ≥ 2; `wc -l …/SKILL.md` ≤ 150; `scripts/segoy doctor --skills` → exit 0
- Covers criteria: 1, 2, 3, 4, 5, 6, 7, 8

### T2 Docs, task and changelog
- Files: `docs/workflows.md`, `tasks/brain-respond.md`, `CHANGELOG.md`
- Steps:
  1. `docs/workflows.md` "Answering": answers sent with a command are kept; a fully answered `kind:task` goes on to the spec without `/spec`. Flow B step 1 start condition: add "or a `kind:task` issue whose questions the owner fully answered".
  2. `tasks/brain-respond.md`: add the automatic path to the list of what the skill handles.
  3. `CHANGELOG.md` `Unreleased` → `Changed`: the two behaviour changes, with the idea ID; "run `segoy sync` in the brain".
- Check: `grep -n 'kind:task' docs/workflows.md tasks/brain-respond.md CHANGELOG.md` → one hit each
- Covers criteria: 1, 4, 8

### T3 Wording check and dry run
- Files: `tests/check-respond.sh` (new), `tests/run.sh`, `tests/fixtures/respond/` (five cases: `task-all-answered`, `task-partial`, `idea-all-answered`, `answers-plus-spec`, plus `park-plus-answers`), `tests/fixtures/respond/transcript.md`
- Steps:
  1. Each case: an issue fixture (labels, triage comment with a `question` block, owner reply) and the expected outcome (state label, whether `segoy-spec` runs, which answers reach the Q&A).
  2. Apply the edited skill by hand to each case and record the outcome in `transcript.md`, including a paused-brain case that exits quietly.
  3. `check-respond.sh`: asserts "wins over answers" is gone for `/spec`/`/plan` (8), the `kind:task` bullet exists (1, 3), the "left unanswered take their defaults" sentence exists (2, 4), `/park` and `/reject` still apply alongside answers (5), the paused precondition and claim-first lines are unchanged against `origin/main` (6, 7); and that every fixture case has a matching transcript entry. Wire it into `tests/run.sh`.
  4. Validate the `segoy` blocks in the fixtures with `scripts/segoy doctor --protocol`.
- Check: `tests/check-respond.sh` → exit 0; `tests/run.sh` → all pass; `shellcheck -x tests/*.sh` → clean
- Covers criteria: 1, 2, 3, 4, 5, 6, 7, 8

## Test plan
- Wording checks prove criterion 8 and that the skill states 1–7.
- The hand-run dry run proves 1 (`kind:task`, all answered → spec), 2 (partial → old behaviour), 3 (`kind:idea` → `state:triaged`), 4 (answers plus `/spec` keep the answers), 5 (`/park` plus answers parks), 6 (paused → nothing) and 7 (one state label, label removed, one comment).
- The Gate 2 PR names criteria 1, 4 and 7 as resting on the dry run; the first live `kind:task` reply in the brain is the real test.

## Risks
- A `kind:task` reply that answers loosely ("ok", "sure") starts a spec too early → only a per-question answer or explicit `defaults` counts as settled; the owner can still ask for changes on the spec PR.
- Reordering steps 4 and 5 breaks Gate 1 or Gate 2 replies → those bullets keep their text; the dry run covers `/park` with answers.
- The skill grows past 150 lines → one new bullet, two reworded ones; it is at 63 lines today.

## Rollout
Merge, then `segoy sync` in the brain (one sync PR). No task setting, label or protocol change.

## Size
S
