---
id: I-20261116-7
title: Brain-lint skill and weekly task
kind: plan
state: planned
visibility: shareable
created: 2026-11-16
updated: 2026-11-16
source: promoted
links: []
---
# Plan: Brain-lint skill and weekly task

## Assumptions
- PoC: not needed (existing repo)
- The skill is `segoy-lint` in `kit/brain/.claude/skills/segoy-lint/`; the task file is `tasks/brain-lint.md`. `segoy sync` already vendors new kit files into brains, so no sync change is needed (firm, spec; `scripts/lib/sync.sh`, `tests/check-sync.sh`)
- The mechanical checks (frontmatter, index drift, orphans, stale pages, wiki links) go into a deterministic POSIX shell helper `kit/common/.claude/scripts/brain-lint.sh` that prints one tab-separated finding per line. The skill calls it and only adds the judgement checks (contradictions, stuck ideas from GitHub). This keeps the small model on rails and makes criteria 3, 6, 7, 8, 9 testable on a fixture brain (likely, spec Constraints "runs on the small model"; `kit/common/.claude/scripts/` pattern)
- "Labelled for lint" (criterion 12) means a new label `segoy:lint`, added to `kit/brain/.segoy/labels.json` and used for both the report issue and the fix PR. `segoy sync` and `segoy init brain` already apply `labels.json`, so the label reaches the brain on the next sync. Protocol §2 gains the row (likely, spec criterion 12; `docs/protocol.md` §2; `scripts/lib/sync.sh` `apply_labels`)
- The report issue and the fix PR carry no new block kind: the issue body and the PR body end with one `run` block only (protocol §3.4). A `lint` block can come later if Otak needs one (likely, spec criteria 4 and 12; protocol §3.10)
- The report issue has no `state:*` label: `state:*` applies to idea issues only (protocol §2) (likely, protocol §2)
- Required frontmatter fields are those in `docs/brain-design.md` §3: `id` (except wiki pages), `title`, `kind`, `visibility`, `created`, `updated`, `source`, `links`, plus `state` for files in `ideas/`. Exempt: `log.md`, every `index.md`, `README.md`, `.segoy/`, `.claude/`, `.github/`, `inbox/`, and `knowledge/raw/` (raw files are immutable and have their own `url`/`author`/`captured` fields; a raw file missing those is reported, never fixed) (likely, `docs/brain-design.md` §3 and the raw-file rule)
- "Derivable from the file" (criterion 8): `title` from the first `# ` heading; `kind` from the folder (`ideas/`→`idea`, `decisions/`→`decision`, `ways/`→`way`, `self/`→`self`, `knowledge/wiki/`→`wiki`, `projects/`→`project`, `journal/`→`journal`); `visibility` = `private` (brain default; always `private` in `self/`); `created` from the file's first commit date; `id` from an `I-…`/`D-…` folder or file name; `links: []`. `source` and `state` are not derivable and are reported. The fix also sets `updated` to the run date (likely, spec criterion 8; brain rule "visibility defaults to private")
- For `self/` files the lint reads only the frontmatter block, never the body, and the report and PR name only paths and field names (firm, spec criterion 13; brain rule "self/ is always private")
- Index drift covers `ideas/index.md`, `decisions/index.md`, `projects/index.md` and `ways/index.md` (and `knowledge/wiki/index.md` if present): a row whose link target is missing, a file with no row, a row whose title or state differs from the file's frontmatter. The fix makes the row match the file; it never changes the file to match the row (likely, spec In scope 5)
- Orphan wiki page = a file under `knowledge/wiki/` that no index or other brain page links to by a relative link (likely, spec In scope 2)
- Stale wiki page = frontmatter `updated` more than 90 days before the run date; a missing `updated` is a frontmatter finding instead (firm, owner-stated, spec)
- Stuck idea uses the weekly review's rule: open idea issue, state not `done`, `parked` or `rejected`, latest `state:*` `labeled` event (GitHub `created_at`) more than 14 days before run time (likely, spec; `segoy-weekly-review` step 8)
- Contradictions: the small model compares claims only between pages that share a topic (same title words, mutual links, or same `links:` entries) across `knowledge/wiki/`, `ways/` and `decisions/`, and flags a pair with both statements quoted by `path:line`. It never edits either file. When unsure it flags with evidence rather than staying silent or guessing a resolution (firm, spec criterion 5 and Constraints)
- Schedule: Saturday 18:00 Europe/Helsinki, so lint precedes the Sunday weekly review (guess, spec open question default)
- An earlier open `Lint <date>` issue is closed as completed with a one-line comment linking the new one; when the run is clean, the earlier issue is left open for the owner (guess, spec open question default). An open `segoy:lint` PR from an earlier run blocks a second PR: the run comments `skipped` on it and still writes the report issue (likely, `segoy-weekly-review` precondition pattern)
- Model: Haiku, as `models.lint` in the brain config template (firm, brain; `kit/brain/.segoy/config.yml.tmpl`)
- Leak check: the issue body and PR body are written to scratch files and checked with `.claude/scripts/leak-guard.sh --denylist .segoy/denylist.txt` before posting; a finding drops the quoted text for that finding and replaces it with the path and line only (likely, spec criterion 13; `segoy-promote` step 5 pattern)

## Approach
Add one brain skill, `segoy-lint`, one helper script, one task file and one label. The helper `brain-lint.sh <brain-dir> [--today <date>] [--fix]` walks the brain and prints findings as `<check>\t<path>\t<detail>` lines for four mechanical checks: `frontmatter`, `index`, `orphan`, `stale`. With `--fix` it applies only the derivable frontmatter additions and index-row corrections, and prints what it could not fix as findings. The skill runs the pause check, runs the helper, adds stuck ideas (from GitHub label events) and contradictions (model judgement, quoted by location), then: no findings → nothing; findings → one `Lint <date>` issue labelled `segoy:lint`, grouped by check, ending with a `run` block; fixes → one `segoy:lint` PR on the assigned branch whose body lists each change and ends with a `run` block.

Splitting the work this way puts every rule that can be computed into a script with fixture tests, and leaves the model only the two jobs that need GitHub or judgement. The static check script asserts that each criterion is stated in the skill or task, as for the weekly review.

## Components touched
- `kit/brain/.claude/skills/segoy-lint/SKILL.md`: new skill; `report.md` (issue body template with sections per check and the `run` block); `pr-body.md` (fix PR template).
- `kit/common/.claude/scripts/brain-lint.sh`: new helper (POSIX sh, awk, sed, git; no network).
- `kit/brain/.segoy/labels.json`: add `segoy:lint`.
- `tasks/brain-lint.md`: new task setup.
- `docs/protocol.md` §2: `segoy:lint` on issues and PRs.
- `tests/check-lint.sh`, `tests/check-brain-lint-script.sh`, `tests/fixtures/lint/` (fixture brains `dirty/` and `clean/`), `tests/run.sh`.
- `.claude/` re-synced with `scripts/segoy sync .`.
- Docs: `docs/architecture.md` §4 `brain-lint` row (skill name, schedule, model, outputs), `docs/brain-design.md` skill table row, `docs/workflows.md` Lint line, `docs/bootstrap-plan.md` T5.2 progress, `CHANGELOG.md` Unreleased.

## Task groups
### T1 Helper `brain-lint.sh` and fixture brains
- Files: `kit/common/.claude/scripts/brain-lint.sh`, `tests/fixtures/lint/dirty/`, `tests/fixtures/lint/clean/`, `tests/check-brain-lint-script.sh`
- Steps:
  1. Fixture `dirty/`: one wiki page with no inbound link; one wiki page `updated` 120 days before the fixed test date; one idea file missing `kind` and `links` (derivable) and one decision missing `source` (not derivable); an `ideas/index.md` with one row whose file is missing, one idea folder with no row, one row with a wrong state; a raw file without frontmatter; a `self/` file missing `updated`; two wiki pages with conflicting claims (for the T3 dry run).
  2. Fixture `clean/`: same layout, no findings.
  3. Write the helper: parse frontmatter with awk; checks `frontmatter`, `index`, `orphan`, `stale` per the assumptions; exempt paths; `--today` for deterministic tests; `--fix` edits only frontmatter fields and index rows and sets `updated`; never reads past the frontmatter in `self/`; exit 0 clean, 1 findings, 2 usage error.
  4. Check script: on a copy of `dirty/`, expected findings per check; `--fix` changes only frontmatter and index files (`git diff --stat` on the copy), never `knowledge/raw/`, never a body line, leaves orphan, stale and non-derivable findings in place; on `clean/` no output, exit 0.
- Check: `sh tests/check-brain-lint-script.sh` → exit 0; `shellcheck -x kit/common/.claude/scripts/brain-lint.sh tests/check-brain-lint-script.sh` → clean
- Covers criteria: 3, 6, 7, 8, 9, 11

### T2 Skill `segoy-lint`, label and protocol row
- Files: `kit/brain/.claude/skills/segoy-lint/SKILL.md`, `report.md`, `pr-body.md`, `kit/brain/.segoy/labels.json`, `docs/protocol.md`
- Steps:
  1. Inputs: run date, the brain checkout, `.segoy/config.yml`, `.segoy/denylist.txt`, templates.
  2. Preconditions: open `segoy:paused` issue → stop, post nothing, change nothing.
  3. Procedure: run `brain-lint.sh` (report mode); collect stuck ideas from GitHub label events; check contradictions per the assumptions, quoting both statements by `path:line`, never editing either file; if nothing found, end with a one-line summary in the run output and open nothing; else write the issue body from `report.md` (sections Contradictions, Orphan pages, Stale pages, Frontmatter, Index drift, Stuck ideas; each finding with its path; run block last); if the helper's fix mode has changes, create the branch, run `brain-lint.sh --fix`, append one `log.md` line, commit, push, open one PR `Lint fixes <date>` labelled `segoy:lint` with body from `pr-body.md`; leak-check both bodies before posting; close an earlier open `Lint` issue as completed with a link to the new one.
  4. Output contract, stop conditions (about 40 tool calls; at most 30 contradiction pairs compared per run), Never (resolve a contradiction, delete, archive or rewrite a page, change idea states or labels, write outside the brain, merge, approve, push to the default branch, quote `self/` content, add `answered`).
  5. Add `segoy:lint` to `labels.json` and to protocol §2 (`segoy:<kind>` list, noting it is also used on the lint report issue).
- Check: `scripts/segoy doctor --skills` → exit 0; `wc -l SKILL.md` ≤ ~150; `kit/common/.claude/scripts/protocol.sh` on `report.md` and `pr-body.md` → exit 0, `run` block last; `jq . kit/brain/.segoy/labels.json` → valid; `tests/run.sh` (brain template check) → pass
- Covers criteria: 2, 3, 4, 5, 8, 9, 10, 11, 12, 13

### T3 Task `brain-lint`, checks and dry run
- Files: `tasks/brain-lint.md`, `tests/check-lint.sh`, `tests/run.sh`
- Steps:
  1. Task file in the style of `tasks/brain-weekly-review.md`: name `brain-lint`; repository the brain only; model Haiku; schedule weekly Saturday 18:00 Europe/Helsinki; no GitHub events; connectors removed; prompt that only names `segoy-lint` and the push rule (new branch in the brain only, never its default branch).
  2. `check-lint.sh` asserts by grep: 1 (skill name, schedule, Haiku in the task); 2 (pause precondition, "post nothing, change nothing"); 3 (no findings → no issue, no PR); 4 (`Lint <date>` title, sections per check, `run` block last in `report.md`); 5 (contradictions quoted by location, never resolved); 6, 7 (orphan, stale 90 days, not changed); 10 (14 days, state and age in `report.md`); 11, 12 (`segoy:lint`, one PR, `run` block last, Never list); 13 (leak-guard call, `self/` paths only).
  3. Dry run: run the skill by hand on a copy of `tests/fixtures/lint/dirty/` (no push, no GitHub writes; stuck ideas from a fixture label-event export), record the would-be issue body, PR diff and PR body in the PR, each criterion marked; run `leak-guard.sh` and `protocol.sh` on the bodies. A second dry run on `clean/` opens nothing; one with a `segoy:paused` fixture stops at once.
  4. Wire both check scripts into `tests/run.sh`.
- Check: `tests/run.sh` → all pass; `shellcheck -x tests/check-lint.sh` → clean; dry-run transcript in the PR covers criteria 2–13
- Covers criteria: 1, 2, 3, 4, 5, 6, 7, 10, 12, 13, 14

### T4 Sync and docs
- Files: `.claude/` (via `scripts/segoy sync .`), `docs/architecture.md`, `docs/brain-design.md`, `docs/workflows.md`, `docs/bootstrap-plan.md`, `CHANGELOG.md`
- Steps:
  1. `scripts/segoy sync .` so Segoy's own `.claude/` carries the new skill and script.
  2. Architecture §4 `brain-lint` row: Saturday 18:00 Europe/Helsinki, brain only, skill `segoy-lint`, model Haiku, outputs `Lint <date>` issue and `segoy:lint` PR; brain-design skill table names `segoy-lint`; workflows Lint line names the label; bootstrap-plan T5.2 notes lint built, ingest and query not; CHANGELOG Unreleased → Added.
- Check: `tests/run.sh` → all pass; `scripts/segoy doctor --skills` → exit 0; leak check in CI passes
- Covers criteria: 14

Coverage: 1 → T3; 2 → T2, T3; 3 → T1, T2, T3; 4 → T2, T3; 5 → T2, T3; 6 → T1, T3; 7 → T1, T3; 8 → T1, T2; 9 → T1, T2; 10 → T2, T3; 11 → T1, T2; 12 → T2, T3; 13 → T2, T3; 14 → T3, T4.

## Test plan
- Helper (T1): fixture tests prove each mechanical check finds exactly the planted problems (6, 7, 8, 9), that `--fix` touches only frontmatter and index rows and never raw files or bodies (8, 9, 11), and that a clean brain gives no output (3).
- Static (T3): `check-lint.sh` proves each criterion is stated where the agent reads it (1–13).
- Protocol: `report.md` and `pr-body.md` validate with `protocol.sh`, `run` block last (4, 12).
- Dry run on the fixture brains: one issue with every planted finding grouped by check (4), the contradiction flagged with both quotes and no edit (5), the stuck idea with state and age (10), one PR limited to frontmatter and index (8, 9, 11, 12), clean leak check with `self/` named by path only (13); clean brain opens nothing (3); paused brain stops (2).
- Regression: `tests/run.sh`, `scripts/segoy doctor --skills`, `shellcheck`, leak check in CI.
- After merge: the first live Saturday run is the real test; the owner judges the issue and PR.

## Risks
- Contradiction detection on a small model is noisy (false positives or misses) → limited to topic-sharing pairs, always quoted by location so the owner can dismiss quickly; never acts on them. If noise is high, a later idea can move this check to a larger model.
- `--fix` could damage files with unusual frontmatter → it edits only inside the first `---` block, adds fields, never removes or reorders existing ones; fixture tests cover a file with no frontmatter (reported, not fixed) and one with partial frontmatter.
- Overlap with the weekly review's stuck list → both use the same rule; the lint report lists them for completeness, the weekly review digest remains the place to act. Noted in docs.
- Closing the previous `Lint` issue may surprise the owner → it is a default from the spec's open question; the task notes say so, and the owner can change it at Gate 1.
- SKILL.md exceeds ~150 lines → templates in `report.md` and `pr-body.md`; mechanical rules live in the script.
- The new label only exists after `segoy sync` in the brain → rollout step; if the label is missing, the skill posts the report issue without it and says "run segoy sync" in the issue.

## Rollout
Merge, then `segoy sync` in the brain (kit-sync opens the PR, which also applies the `segoy:lint` label). The owner creates the `brain-lint` task by hand from `tasks/brain-lint.md` (agents cannot create tasks) and presses Run now once to see the first report.

## Size
M
