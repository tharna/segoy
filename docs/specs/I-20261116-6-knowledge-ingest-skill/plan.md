---
id: I-20261116-6
title: Knowledge ingest skill
kind: plan
state: planned
visibility: shareable
created: 2026-11-16
updated: 2026-11-16
source: promoted
links: []
---
# Plan: Knowledge ingest skill

## Assumptions
- PoC: not needed (existing repo)
- The skill is named `segoy-ingest` and lives in `kit/brain/.claude/skills/`; the task file is `tasks/brain-ingest.md`. `segoy sync` already vendors new kit files into brains, and the `segoy:knowledge` label already exists, so neither sync nor labels change (firm, spec; `kit/brain/.segoy/labels.json`, `tests/check-sync.sh` "add" case)
- Trigger: `pull_request.closed` in the brain with the filter **Is merged** and **no label filter**, because the owner's own PRs that add raw files carry no label. The skill exits quietly (no comment, no `run` block, protocol §3.4) when the merged PR added no file under `knowledge/raw/`. This means every merged brain PR starts a short session (likely, spec In scope; `docs/architecture.md` §4)
- One PR per raw file, as the spec's open question proposes. A merged PR that added several raw files gives one ingest PR per file in the same run, at most 5 per run; the rest are picked up by Run now, which takes every raw file on the default branch that no ingest PR covers, oldest first, with the same cap (likely, spec Open questions default)
- "Covered" (criterion 6) means: a PR labelled `segoy:knowledge` in the brain, open or merged, whose title ends with `(<raw file stem>)`, for example `Ingest: <source title> (20261116-example-note)`. A closed, unmerged ingest PR counts as the owner rejecting it: the automatic trigger does not reopen it, and Run now skips it too unless the owner names the file in the prompt (guess, spec criterion 6)
- The source summary page goes to `knowledge/wiki/sources/<raw file stem>.md` (new folder in the brain template), page kind `source`. Other pages go to the existing `topics/`, `entities/` or `syntheses/` folders (likely, `docs/brain-design.md` §6)
- Every page the PR creates or updates cites the raw file by relative link (`../../raw/<file>`) in a `Sources` section and lists the raw path in frontmatter `links`. Updated pages keep their `id` and `created`; `updated` moves to the run date (likely, spec criterion 3; brain frontmatter rules)
- "Bears on" (criterion 4): before writing, the skill searches `knowledge/wiki/index.md`, page titles and page bodies for the source's main terms; a page whose topic or entity matches is updated, never duplicated. New pages are created only where no page matches (likely, spec criterion 4)
- Private content (criterion 7): a raw file with `visibility: private` in its frontmatter, or the parts of a raw file inside private blocks, are treated as private. Text derived from them goes inside private blocks (the brain's private markers) in the wiki pages. New pages default to `visibility: private` (brain rule). An existing page marked `shareable` that would take derived text runs `leak-guard.sh` after the change; a finding wraps that text in a private block, never drops it silently (likely, spec criterion 7; brain rule 7)
- The log line goes to the brain's root `log.md` in its existing format `<date> · <actor> · <operation> · <files>`, with operation `ingest` (firm, `kit/brain/log.md`)
- No new protocol block kind is needed: the PR body ends with a `run` block only (§3.4), validated by `protocol.sh` (likely, spec criterion 8; protocol §3.10 reserves no kind)
- Raw file names differ in the docs: `<yyyy-mm-dd>-<slug>.md` in `docs/brain-design.md` §6 and `<yyyymmdd>-<slug>.md` in the weekly review's `records.md`. The skill accepts any file under `knowledge/raw/` and uses its stem; reconciling the docs is left out of this plan (likely, path in this repo)
- Model: Sonnet, as for weekly review; the task file says so (guess)

## Approach
Add one brain skill, `segoy-ingest`, and one task file, `brain-ingest`. On a merged brain PR the skill lists the files that PR added under `knowledge/raw/`; on Run now it lists raw files not yet covered by an ingest PR. For each file (up to 5 per run) it creates one branch from the default branch, writes a source summary page, updates every existing wiki page the source bears on and creates pages only where none exists, adds new pages to `knowledge/wiki/index.md`, appends one `log.md` line, and opens one `segoy:knowledge` PR whose body ends with a `run` block. It never touches `knowledge/raw/`. A run that finds nothing to ingest exits quietly.

As with the weekly review, behaviour cannot be unit-tested end to end, so evidence is: a static check script asserting each criterion is stated where the agent reads it, the PR-body template validated by `protocol.sh`, and a dry run of the skill against a small fixture brain, with its output checked by the same script and recorded in the PR.

## Components touched
- `kit/brain/.claude/skills/segoy-ingest/SKILL.md`: new skill.
- `kit/brain/.claude/skills/segoy-ingest/pages.md`: source summary page, topic/entity page update rules, `Sources` section, frontmatter, index line, `log.md` line.
- `kit/brain/.claude/skills/segoy-ingest/pr-body.md`: PR body ending with a `run` block.
- `kit/brain/knowledge/wiki/sources/.gitkeep`: new folder in the brain template; `tests/check-brain-template.sh` lists it.
- `tasks/brain-ingest.md`: new task setup; `tasks/README.md` if it lists tasks.
- `tests/check-ingest.sh` (new), `tests/fixtures/ingest/` (fixture brain and dry-run output), wired into `tests/run.sh`.
- Docs: `docs/architecture.md` §4 task row, `docs/brain-design.md` skill table row (`ingest` trigger: merge of a PR adding raw files, plus Run now; not note capture) and §6 (`sources/` folder), `docs/workflows.md` (Flow B step 6 and the Ingest line: no ingest from note issues), `docs/bootstrap-plan.md` M5 T5.2 progress (ingest done, query and lint open), `CHANGELOG.md` Unreleased.

## Task groups
### T1 Skill `segoy-ingest`
- Files: `kit/brain/.claude/skills/segoy-ingest/SKILL.md`, `pages.md`, `pr-body.md`, `kit/brain/knowledge/wiki/sources/.gitkeep`, `tests/check-brain-template.sh`
- Steps:
  1. Inputs: the `<github-trigger-context>` (merged brain PR) or none (Run now); the brain checkout; `.segoy/config.yml`, `.segoy/denylist.txt`; templates next to the file.
  2. Preconditions (exit quietly, post nothing, change nothing): an open issue labelled `segoy:paused`; the trigger PR is not merged; the trigger PR added no file under `knowledge/raw/`; every candidate raw file is already covered (open or merged `segoy:knowledge` PR whose title ends with the file stem).
  3. Procedure per raw file, at most 5 per run: read it (never edit, move or delete anything under `knowledge/raw/`); find the pages it bears on (index, titles, bodies); write `knowledge/wiki/sources/<stem>.md` from `pages.md`; update each matching page in place with a `Sources` entry citing the raw path; create new topic or entity pages only where none matches; put text derived from private parts inside private blocks; add each new page to `knowledge/wiki/index.md`; append one `log.md` line; run `leak-guard.sh` on changed pages marked `shareable` and wrap any finding in a private block.
  4. Publish per file: branch from the default branch (the assigned `claude/*` branch for the first file, `claude/ingest-<stem>` for the rest, ADR-020), commit `ingest: <stem>`, push, open one PR `Ingest: <source title> (<stem>)` labelled `segoy:knowledge`, body from `pr-body.md` ending with a `run` block; validate the body with `.claude/scripts/protocol.sh`. Before staging, check `git diff --name-only` shows nothing under `knowledge/raw/`; if it does, stop with a `failed` run block in a comment on the trigger PR.
  5. Output contract, stop conditions (about 40 tool calls per file; 5 files per run), and Never (edit raw files, merge, approve, close PRs, push to the default branch, read `self/`, write outside `knowledge/wiki/` and `log.md`, add `answered`, open a second PR for a covered file, start from note issues).
  6. Add `knowledge/wiki/sources` to the template folder list in `tests/check-brain-template.sh`.
- Check: `scripts/segoy doctor --skills` → exit 0; `wc -l SKILL.md` ≤ ~150; `grep -v '^\`\`\`\`' pr-body.md | kit/common/.claude/scripts/protocol.sh -` → 1 block, exit 0; `tests/check-brain-template.sh` → pass
- Covers criteria: 1, 2, 3, 4, 5, 6, 7, 8, 9

### T2 Task `brain-ingest`
- Files: `tasks/brain-ingest.md`, `tasks/README.md` (if it lists tasks)
- Steps:
  1. Settings table in the style of `tasks/brain-plan-promote.md`: name `brain-ingest`, repositories the brain only, model Sonnet, trigger GitHub event → brain → Pull request → closed, filter **Is merged** = true, no label filter; no schedule; connectors removed.
  2. Prompt that only names the skill and the push rule ("Run the segoy-ingest skill for the merged PR in the GitHub trigger context, or with Run now for raw files not yet ingested … You may push only to new claude/ branches in the brain; never to its default branch.").
  3. Notes: most merged PRs add no raw file, and those runs exit quietly; Run now catches up on raw files added before the task existed; one PR per raw file; closing an ingest PR unmerged means "do not ingest", and Run now with the file named retries it.
- Check: `grep` for `segoy-ingest`, `Is merged`, `closed` in `tasks/brain-ingest.md` (part of T3's script)
- Covers criteria: 1, 9

### T3 Checks and dry run
- Files: `tests/check-ingest.sh`, `tests/fixtures/ingest/` (fixture brain: one existing topic page the source bears on, `knowledge/wiki/index.md`, `log.md`; one raw note with a private block; one raw file already covered by a fixture open ingest PR listing; a paused-issue listing), `tests/run.sh`
- Steps:
  1. `check-ingest.sh` part 1 asserts, by grep on the skill and task: 1 (task names the skill and the merged-PR trigger, label `segoy:knowledge`, one PR per file); 2 (raw files under Never); 3 (source summary page, `Sources` citation in `pages.md`); 4 (update before create); 5 (index line and `log.md` line formats); 6 (covered-file precondition); 7 (private blocks for private parts); 8 (`protocol.sh` call, `run` block last in `pr-body.md`); 9 (pause precondition, "post nothing").
  2. Run the skill by hand against the fixture brain (dry run: build the branch locally, do not push) and save the output under `tests/fixtures/ingest/dry-run/` with a `transcript.md`. Part 2 of the script checks that output: no path under `knowledge/raw/` changed (2); a `sources/` page exists and every changed page links the raw path (3); the existing topic page is changed and no second page with its title exists (4); every new page is in `index.md` and `log.md` gained exactly one line in the `date · actor · operation · files` form (5); the covered file got no output (6); `strip-private.sh` on each changed page leaves none of the fixture's private marker phrase (7); the PR body passes `protocol.sh` with a `run` block last (8). A second dry run with the paused listing produces no files and no body (9).
  3. Wire `check-ingest.sh` into `tests/run.sh`; `shellcheck -x` it.
- Check: `tests/run.sh` → all pass; `shellcheck -x tests/check-ingest.sh` → clean; dry-run transcript in the PR body marks criteria 1–9
- Covers criteria: 1, 2, 3, 4, 5, 6, 7, 8, 9

### T4 Docs
- Files: `docs/architecture.md`, `docs/brain-design.md`, `docs/workflows.md`, `docs/bootstrap-plan.md`, `CHANGELOG.md`
- Steps:
  1. Architecture §4: add the `brain-ingest` row (trigger, repos, skill, output).
  2. Brain design: `ingest` row trigger "merge of a PR adding files under `knowledge/raw/`, or Run now"; §6 mentions `wiki/sources/`.
  3. Workflows: Flow B step 6 and the Ingest line say ingest starts from the merge that adds the raw file, not from the note issue.
  4. Bootstrap plan T5.2: ingest done, query and lint still open. CHANGELOG Unreleased → Added: skill, task, `wiki/sources/`.
- Check: `tests/run.sh` → all pass; leak check in CI passes
- Covers criteria: 1

Coverage: 1 → T1, T2, T3, T4; 2 → T1, T3; 3 → T1, T3; 4 → T1, T3; 5 → T1, T3; 6 → T1, T3; 7 → T1, T3; 8 → T1, T3; 9 → T1, T2, T3.

## Test plan
- Static: `check-ingest.sh` part 1 proves each criterion is stated where the agent reads it (1–9).
- Protocol: `pr-body.md` validates with `protocol.sh` and ends with a `run` block (8).
- Dry run on the fixture brain: one PR's worth of files per raw file (1), raw untouched (2), summary page and citations (3), existing page updated, no duplicate (4), index and one log line (5), covered file skipped (6), private text only inside private blocks (7), valid body (8), paused fixture stops at once (9).
- Regression: `tests/run.sh`, `scripts/segoy doctor --skills`, `shellcheck`, leak check in CI.
- After merge: the first live run on a merged weekly review PR that files a note is the real test; the owner judges its PR at merge time.

## Risks
- Every merged brain PR starts a session (no path filter on the trigger) → the precondition exits in a few tool calls; if run caps bite, narrow the filter to `segoy:review` plus Run now in a later idea.
- "Bears on" is a judgement → the dry run shows update-over-create on a fixture; the owner sees every touched page in the PR.
- Two ingest PRs touch the same page or `index.md` and conflict → each branches from the default branch; the second one to merge needs a rebase, noted in the task file; the cap of 5 per run keeps this rare.
- Skill exceeds ~150 lines → page formats live in `pages.md`.
- Static grep checks prove wording, not behaviour → the dry-run output is checked by the same script; the first live PR is reviewed at merge.

## Rollout
Merge, then `segoy sync` in the brain (kit-sync opens the PR, which also adds `knowledge/wiki/sources/`). The owner creates the `brain-ingest` task by hand from `tasks/brain-ingest.md` (agents cannot create tasks) and presses Run now once to ingest raw files already in the brain.

## Size
M
