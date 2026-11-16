---
id: I-20261116-2
title: Weekly review skill and task for the brain
kind: plan
state: planned
visibility: shareable
created: 2026-11-16
updated: 2026-11-16
source: promoted
links: []
---
# Plan: Weekly review skill and task for the brain

## Assumptions
- PoC: not needed (existing repo)
- The skill is named `segoy-weekly-review` and lives in `kit/brain/.claude/skills/`; the task file is `tasks/brain-weekly-review.md`. `segoy sync` already vendors new kit files into brains, so no sync change is needed (firm, spec; `scripts/lib/sync.sh`, `tests/check-sync.sh` "add" case)
- The `segoy:review` label already exists in the brain label set, so no label change is needed (firm, `kit/brain/.segoy/labels.json`)
- The PR body ends with a `review` block (protocol §3.9 outline: `week`, `proposals[{id, text, target}]`, `stats`) and then a `run` block. This plan fixes the `review` fields in a new protocol §3.9 entry and teaches `protocol.sh` to validate them, because a skill that emits a reserved kind must define it in the milestone that first emits it (likely, `docs/protocol.md` §3.9)
- Issue labels are the source of truth for an idea's state (protocol §2). "Correcting a drifted state" means: change `state:` in `idea.md`/`spec.md` frontmatter and `ideas/index.md` to match the issue label, inside the PR. Where the label itself disagrees with PR reality (for example `promoted` while the Gate 1 PR is merged), the skill does not change the label (only owner actions move an idea); it lists the mismatch in the digest under "Needs you" (likely, protocol §2; brain rule "only owner actions move an idea forward")
- Notes are open issues labelled `kind:note`. The PR saves each verbatim to `knowledge/raw/<yyyymmdd>-<slug>.md` and lists `Closes #<n>` in its body, so the owner's merge closes the note issues and nothing closes before the merge (likely, `docs/workflows.md` Flow B step 6)
- Decision records come from `decision` blocks (protocol §3.7) in agent comments on brain issues that have no `decisions/D-*.md` with the same `subject` yet; parked and rejected stubs are `idea.md` files with `state: parked|rejected` for ideas that never got an idea folder (likely, `docs/brain-design.md` record-decision row)
- "Stuck" = an open idea issue in a state other than `done`, `parked`, `rejected` whose latest `state:*` `labeled` event is more than 14 days before run time, measured with GitHub's `created_at` times, never timestamps inside `segoy` blocks (likely, spec; `docs/architecture.md` §4 notes)
- When an open `segoy:review` PR from an earlier run exists, the new run opens no second PR; it posts one comment with a `run` block (`outcome` `skipped`, next "owner: merge or close review #<n>") on that PR. State-based items (notes, stubs, drift, stuck) are caught up by the next run after the owner acts; the 7-day digest window is not widened (guess, spec "exactly one review PR")
- Ways proposals are appended as new bullets ending `(proposed; source: <link>, <date>)`; changing an existing rule is done as a new `proposed` bullet next to it plus a strike-through marker on the old one, never a silent edit. At most five proposals per run (likely, spec criterion 9; `docs/workflows.md` Flow E)
- The task mounts the brain first and then every project repo, read-only, so retros (`docs/retros/`) and gate PRs can be read; it pushes only to a new branch in the brain (likely, `tasks/kit-sync.md` pattern)
- The skill never reads `self/`. Goal-aware suggestions ("top three next ideas") stay with M6 (T6.2) and are out of this spec's scope (firm, spec Out of scope; `docs/bootstrap-plan.md` M6)
- Model: Sonnet, as for respond-class tasks; the plan sees no reason to differ (likely, spec Constraints)
- The leak check runs on every changed file whose frontmatter says `visibility: shareable` and on everything under `ways/public/`. A finding drops that item from the PR and the digest says "1 item withheld by the leak check (file, line)", never the matched text (likely, spec criterion 10; segoy-promote step 5 pattern)

## Approach
Add one brain skill, `segoy-weekly-review`, and one task file. The skill is a read-mostly sweep over the brain's issues, PRs and files plus the project repos' retros and gate PRs. It builds one branch with every proposed file change, writes `journal/<yyyy>-W<ww>.md` as the digest (what moved, state corrections, stuck ideas, items that need the owner, ways proposals, stats), appends one `log.md` line per filed item, runs the leak check on shareable files, and opens one `segoy:review` PR whose body ends with a `review` block and a `run` block. A run with no activity and no drift opens nothing. Long templates (digest, PR body, decision record, stub, raw note) go in sibling files so `SKILL.md` stays under ~150 lines.

Because a skill's behaviour cannot be unit-tested end to end, the checks are: a static check script that asserts each criterion is stated in the skill or task (pause check, label, empty-week exit, no `knowledge/wiki/` writes, `proposed` marker, leak check, never merge), protocol fixtures for the new `review` block, the PR-body template validated by `protocol.sh`, and a dry-run transcript of the skill against a small fixture brain, recorded in the PR.

## Components touched
- `kit/brain/.claude/skills/segoy-weekly-review/SKILL.md`: new skill.
- `kit/brain/.claude/skills/segoy-weekly-review/`: `digest.md` (journal template), `pr-body.md` (PR body with `review` and `run` blocks), `records.md` (decision record, idea stub, raw note and `log.md` line formats).
- `tasks/brain-weekly-review.md`: new task setup (Sunday 18:00 Europe/Helsinki, Sonnet, brain first then project repos, connectors removed, prompt naming the skill).
- `docs/protocol.md`: `review` block moves from §3.9 outline to a defined kind with a field table and example.
- `kit/common/.claude/scripts/protocol.sh`: validate `review` fields; `.claude/` re-synced with `scripts/segoy sync .`.
- `tests/fixtures/protocol/valid.md`, `invalid.md`: `review` cases. `tests/run.sh`: new message checks, block count.
- `tests/check-weekly-review.sh` (new) and `tests/fixtures/weekly-review/` (small fixture brain for the dry run); wired into `tests/run.sh`.
- Docs: `docs/workflows.md` Flow E step 3 (match the spec's scope: no `projects/` edits or goal-based suggestions now), `docs/architecture.md` §4 task row (skill name, schedule, repos), `docs/brain-design.md` skill table row, `docs/bootstrap-plan.md` T5.1 progress, `CHANGELOG.md` Unreleased, `tasks/README.md` if it lists tasks.

## Task groups
### T1 Protocol: define the `review` block
- Files: `docs/protocol.md`, `kit/common/.claude/scripts/protocol.sh`, `tests/fixtures/protocol/valid.md`, `tests/fixtures/protocol/invalid.md`, `tests/run.sh`, `.claude/scripts/protocol.sh` (via sync)
- Steps:
  1. In `docs/protocol.md` add §3.9 `review` (M5) with fields: `week` (`<yyyy>-W<ww>`), `period` (`{"from", "to"}` ISO 8601), `proposals` (array, may be empty; each `id` `p1…`, `text`, `target` = a `ways/` path, `source`), `filed` (object of counts: `notes`, `decisions`, `stubs`, `state_fixes`), `stuck` (array of idea IDs), `stats` (object); move the remaining outlines to §3.10.
  2. Add the `review` validation to `protocol.sh` in the same style as `plan`/`impl` (required fields, types, unique proposal ids, `week` format).
  3. Add one valid and one invalid `review` block to the fixtures; add the new messages to the `protocol reports:` loop and update the valid block count.
  4. `scripts/segoy sync .` so Segoy's own `.claude/` matches.
- Check: `tests/run.sh` → all pass, including the new `protocol reports:` lines and "examples in docs/protocol.md pass"
- Covers criteria: 3, 12

### T2 Skill `segoy-weekly-review`
- Files: `kit/brain/.claude/skills/segoy-weekly-review/SKILL.md`, `digest.md`, `pr-body.md`, `records.md`
- Steps:
  1. Inputs: run time, `.segoy/config.yml`, the brain checkout, mounted project checkouts. Period = 7 days ending at run time.
  2. Preconditions: no open `segoy:paused` issue in the brain (protocol §5) → exit, post nothing; an open `segoy:review` PR → one `skipped` run comment on it, no new PR.
  3. Procedure, in order: collect (brain issues and comments with `created_at` in the period, label events, merged/closed `segoy:*` PRs in brain and projects, retros in `docs/retros/`); file notes to `knowledge/raw/` (never `knowledge/wiki/`); write decision records `decisions/D-<yyyymmdd>-<n>.md` and parked/rejected stubs with full frontmatter and a source link; reconcile `state:` in idea files and `ideas/index.md` to issue labels, listing each fix; list stuck ideas (> 14 days, with current state); list label-vs-PR mismatches under "Needs you"; propose at most five `ways/` bullets marked `proposed` with a cited source (retros' proposed rule changes, decision generalisations, brain-side friction: more than one question round, owner corrections of triage); append one `log.md` line per filed item; write `journal/<yyyy>-W<ww>.md` from `digest.md`.
  4. Empty week: no activity in the period and nothing to file, fix or propose → no branch, no PR, no comment.
  5. Leak check: `.claude/scripts/leak-guard.sh --denylist .segoy/denylist.txt` on shareable changed files and `ways/public/` changes; drop findings as in the assumptions.
  6. Publish: commit on the assigned `claude/*` branch (ADR-020), push, open one PR `Review <yyyy>-W<ww>` labelled `segoy:review`, body from `pr-body.md` (`Closes #n` for notes, `review` block, `run` block). Validate the blocks with `protocol.sh`.
  7. Output contract, stop conditions (about 60 tool calls; at most 20 items filed per run, rest next week), and Never (merge, approve, close PRs, push to default branch, read or write `self/`, write `knowledge/wiki/`, write to project repos, change `state:*` labels, add `answered`, rewrite an existing `ways/` rule silently).
- Check: `scripts/segoy doctor --skills` → exit 0; `wc -l SKILL.md` ≤ ~150; `grep -v '^\`\`\`\`' pr-body.md | kit/common/.claude/scripts/protocol.sh -` → 2 blocks, exit 0
- Covers criteria: 2, 3, 4, 5, 6, 7, 8, 9, 10, 11

### T3 Task `brain-weekly-review`
- Files: `tasks/brain-weekly-review.md`, `tasks/README.md` (if it lists tasks)
- Steps:
  1. Settings table in the style of `tasks/kit-sync.md`: name, repositories (brain first, then each project repo), model Sonnet, trigger Schedule weekly Sunday 18:00 Europe/Helsinki, no GitHub event, connectors removed.
  2. Prompt that only names the skill and the push rule ("Run the segoy-weekly-review skill … You may push only to a new branch in the brain; never to its default branch, and never to a project repo.").
  3. Notes: Run now for a catch-up; what an empty week looks like.
- Check: `grep -q 'segoy-weekly-review' tasks/brain-weekly-review.md && grep -q "Sunday 18:00" tasks/brain-weekly-review.md && grep -q "Europe/Helsinki" tasks/brain-weekly-review.md` → exit 0 (part of T4's script)
- Covers criteria: 1

### T4 Checks and dry run
- Files: `tests/check-weekly-review.sh`, `tests/fixtures/weekly-review/` (fixture brain: one note issue export, one parked idea without a stub, one decision block without a record, one idea with drifted frontmatter state, one idea stuck 20 days, one retro with a proposed rule), `tests/run.sh`
- Steps:
  1. `check-weekly-review.sh` asserts, by grep on the skill and task: criterion 1 (skill name, schedule, time zone in the task); 2 (pause precondition, "post nothing"); 3 (label `segoy:review`, `run` block last in `pr-body.md`); 4 (empty-week exit, "no PR"); 5 (records with frontmatter and source, `log.md` line); 6 (`knowledge/wiki/` under Never); 7 (state fix listed in digest); 8 (14 days, current state in `digest.md`); 9 (`proposed` marker and source in `records.md`/`SKILL.md`); 10 (leak-guard call, `self/` under Never); 11 (never merge, approve, push to default branch).
  2. Run the skill by hand against the fixture brain (dry run: build the branch locally, do not push) and record the transcript: the files it would add, the digest, and the PR body, with each criterion marked. Run `leak-guard.sh` on the dry-run output.
  3. Wire `check-weekly-review.sh` into `tests/run.sh`; `shellcheck -x` it.
- Check: `tests/run.sh` → all pass; `shellcheck -x tests/check-weekly-review.sh` → clean; dry-run transcript in the PR body covers criteria 2–11
- Covers criteria: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12

### T5 Docs
- Files: `docs/workflows.md` (Flow E step 3), `docs/architecture.md` §4 row, `docs/brain-design.md` skill table, `docs/bootstrap-plan.md` M5 T5.1, `CHANGELOG.md`
- Steps:
  1. Flow E step 3: describe what the skill does now (spec scope), and mark `projects/` updates and goal-based suggestions as later (M6).
  2. Architecture row: skill `segoy-weekly-review`, schedule Sunday 18:00, repos brain + projects (read-only).
  3. CHANGELOG Unreleased → Added: skill, task, `review` block.
- Check: `tests/run.sh` → all pass; leak check in CI passes
- Covers criteria: 12

Coverage: 1 → T3, T4; 2 → T2, T4; 3 → T1, T2, T4; 4 → T2, T4; 5 → T2, T4; 6 → T2, T4; 7 → T2, T4; 8 → T2, T4; 9 → T2, T4; 10 → T2, T4; 11 → T2, T4; 12 → T1, T4, T5 (one PR containing skill, task and checks).

## Test plan
- Static: `check-weekly-review.sh` proves each criterion is stated where the agent reads it (criteria 1–11).
- Protocol: fixtures prove `review` blocks validate and malformed ones fail; `pr-body.md` validates (criterion 3).
- Dry run on the fixture brain: shows one PR's worth of files limited to scope (3), stub and record with frontmatter and `log.md` line (5), no `knowledge/wiki/` change (6), a state fix listed (7), a stuck idea listed (8), a `proposed` ways bullet with source (9), a clean leak check (10), nothing pushed or merged (11). A second dry run on an empty fixture opens nothing (4). A fixture with a `segoy:paused` issue stops at once (2).
- Regression: `tests/run.sh`, `scripts/segoy doctor --skills`, `shellcheck`, leak check in CI.
- After merge: the first live Sunday run in the brain is the real test; the owner judges its PR at merge time.

## Risks
- Skill exceeds ~150 lines given seven duties → templates and record formats move to sibling files; the procedure lists duties as short steps.
- Plan comes out larger than one PR → it is sized M; if implementation shows it is L, the spec's split applies (digest and filing first, ways proposals second) and the implementer stops and says so rather than shipping half.
- Static grep checks prove wording, not behaviour → the dry-run transcript on a fixture brain is the behaviour evidence; the first live run is reviewed at merge.
- An unmerged review PR blocks later reviews and the 7-day digest of that week is lost → the skip comment tells the owner; state-based items catch up; widening the window is left for a later idea.
- Reading every project repo may hit the tool budget → only `segoy:*` PRs closed in the period and new files in `docs/retros/` are read.
- Weekly scheduled runs and trigger caps: if the run is dropped, nothing is lost but a week's digest → Run now catches up.

## Rollout
Merge, then `segoy sync` in the brain (kit-sync opens the PR). The owner creates the `brain-weekly-review` task by hand from `tasks/brain-weekly-review.md` (agents cannot create tasks), adding the brain and each project repo, and presses Run now once to see the first review PR.

## Size
M
