---
id: I-20261116-3
title: Weekly review - no "proposed" marker in ways bullets
kind: plan
state: planned
visibility: shareable
created: 2026-11-16
updated: 2026-11-16
source: promoted
links: []
---
# Plan: Weekly review - no "proposed" marker in ways bullets

## Assumptions
- PoC: not needed (existing repo)
- The marker in use is the one `records.md` defines: `(proposed; source: <…>, <date>)`. Cleanup matches only the exact `(proposed; ` opening of the source note and rewrites it to `(` (so `(proposed; source: X, d)` becomes `(source: X, d)`); other forms such as `(proposed)` are left alone. This takes the spec's open-question default (likely, spec Open questions)
- Cleanup reads `ways/**` on the default branch as checked out at run start, before the run's own edits, so bullets written in the same PR are never touched (likely, spec Out of scope)
- A replaced rule keeps its strike-through, but its trailing note becomes `(replaced by the next bullet)` instead of `(replaced by the proposal below)`, so a merged file carries no proposal wording at all (guess, spec criterion 1)
- Leftover markers count as something to file, like state drift: a week with only cleanup to do still opens the review PR. A week with no markers and nothing else stays empty (guess, spec "each run removes" and criterion 6)
- The protocol `review` block is unchanged: `proposals[]` already lists the proposals; cleaned bullets are listed only in the digest and counted in the PR body. No app change (likely, `docs/protocol.md` §3.9)
- Decision-record *Generalisation* (`(proposed)` in `records.md`, `docs/brain-design.md`, `kit/brain/CLAUDE.md`) is not touched (firm, spec Out of scope)
- The canonical wording, copied verbatim into the skill, the task and `docs/workflows.md` (criterion 7): "Write each proposal as a final `ways/` bullet with its cited source and no `proposed` marker; merging the review PR accepts it. List each one as a proposal in the PR body and the digest." and "Remove a leftover `(proposed; ` marker from `ways/` bullets already on the default branch, keep the rest of the bullet, and list each one in the digest." (likely, spec criterion 7)
- The brain kit is not vendored into this repo's `.claude/`, so no `segoy sync .` is needed; brains pick the change up with `segoy sync` (firm, `.claude/skills/` lists only project skills)

## Approach
Change the weekly-review kit in one commit: the proposal format in `records.md` loses the `proposed; ` prefix; step 9 of `SKILL.md` states the new rule and gains a cleanup sub-step for leftover markers on the default branch; the output contract, "Never" list and empty-week rule follow; `digest.md` gains a "Markers removed" section and labels each proposal; `pr-body.md` lists each proposal under a "Proposals (merge accepts them)" heading. The task file, `docs/workflows.md` Flow E step 7 and the CHANGELOG restate the rule with the same sentences.

Behaviour is checked as before: `tests/check-weekly-review.sh` asserts the wording in each file, and the fixture brain gets a `ways/` bullet with a leftover marker and a decision record with a `(proposed)` generalisation, with the expected dry-run output beside it.

## Components touched
- `kit/brain/.claude/skills/segoy-weekly-review/SKILL.md`: step 3 (cleanup counts as work), step 9 (new rule and cleanup), step 10 (`log.md` op `clean marker`), output contract, Never list.
- `kit/brain/.claude/skills/segoy-weekly-review/records.md`: proposal and replacement formats without `proposed`; `log.md` op list.
- `kit/brain/.claude/skills/segoy-weekly-review/digest.md`: proposals labelled as proposals; new "Markers removed" section.
- `kit/brain/.claude/skills/segoy-weekly-review/pr-body.md`: per-proposal list and a cleaned-markers count.
- `tasks/brain-weekly-review.md`, `docs/workflows.md`, `CHANGELOG.md`: same wording.
- `tests/check-weekly-review.sh`, `tests/fixtures/weekly-review/**`: updated checks and dry run.

## Task groups
### T1 Skill, templates, task and docs in one commit
- Files: the four `segoy-weekly-review` files, `tasks/brain-weekly-review.md`, `docs/workflows.md`, `CHANGELOG.md`.
- Steps:
  1. `records.md`: proposal format `- <rule> (source: <…>, <run date>)`; replacement `- ~~<old rule> (source: …)~~ (replaced by the next bullet)`; add `clean marker` to the `log.md` ops.
  2. `SKILL.md` step 9: replace "marked `proposed`, with a cited source" by the first canonical sentence; add sub-step "Cleanup" with the second canonical sentence, reading the default branch before any edit of this run and matching only `(proposed; `; never touch `decisions/`.
  3. `SKILL.md` step 3: leftover markers count like drift. Output contract: `ways/**` (new bullets, replaced-rule strike-throughs, removed leftover markers). Never list: "Never rewrite or delete an existing `ways/` rule without a visible replacement bullet in the same diff, listed as a proposal in the PR body and digest."
  4. `digest.md`: `## Proposed ways changes` items read `- p1 (proposal) → …`; new `## Markers removed` with `- <ways/ file>: <bullet text after cleanup>`, left out when empty.
  5. `pr-body.md`: after the summary lines, `**Proposals** (merge accepts them)` with one `- p1 (proposal) → <file>: <rule>` per proposal, and "Markers removed: <n>" in the summary; filled example updated.
  6. Task file and `docs/workflows.md` Flow E step 7: replace "marked `proposed`" with the canonical sentences; CHANGELOG `Unreleased` → `Changed` entry.
- Check: `grep -rn 'proposed; ' kit/brain/.claude/skills/segoy-weekly-review tasks docs/workflows.md` → no hit except inside the cleanup rule's `(proposed; ` match text; `grep -c '(proposed)' kit/brain/.claude/skills/segoy-weekly-review/records.md` → 1 (generalisation unchanged); `git show --stat HEAD` lists all restating files in one commit; `wc -l SKILL.md` ≤ 150; `scripts/segoy doctor --skills` passes.
- Covers criteria: 1, 2, 3, 4, 5, 6, 7

### T2 Checks and dry run
- Files: `tests/check-weekly-review.sh`, `tests/fixtures/weekly-review/brain/ways/public/principles.md`, `tests/fixtures/weekly-review/brain/decisions/` (an existing record with `(proposed)` generalisation), `tests/fixtures/weekly-review/dry-run/**`, `tests/fixtures/weekly-review/pr-body.md`, `transcript.md`.
- Steps:
  1. Fixture brain: add one bullet `- <rule>. (proposed; source: example, 2025-12-01)` and one decision record with a `(proposed)` generalisation.
  2. Dry run: new proposal bullet without marker; the old bullet with only `proposed; ` removed; decision record byte-identical; digest lists the proposal as `(proposal)` and the cleaned bullet under "Markers removed"; PR body lists the proposal.
  3. Second fixture case (no marker in the brain): dry-run digest has no "Markers removed" section and `ways/` diff has no cleanup line.
  4. `check-weekly-review.sh`: criterion 1 (new `>` lines in the `ways` diff contain no `proposed`), 2 (`(proposal)` in digest and PR body), 3 (the one `<`/`>` pair differs only by `proposed; `), 4 (digest lists file and bullet), 5 (`cmp` on the decision record), 6 (no-marker case), 7 (canonical sentences found verbatim in SKILL, task and workflows). Update the old criterion-9 checks that expected `(proposed; source: <`.
- Check: `tests/check-weekly-review.sh` → exit 0; `tests/run.sh` → all pass; `shellcheck -x tests/*.sh` → clean; `scripts/segoy doctor --protocol tests/fixtures/weekly-review/pr-body.md` → valid.
- Covers criteria: 1, 2, 3, 4, 5, 6, 7

## Test plan
- Static wording checks prove criterion 7 and that the skill states criteria 1–6.
- The fixture dry run proves 1 (no marker on new bullets), 2 (proposals listed in PR body and digest), 3 (only the prefix removed, source note kept), 4 (digest lists cleaned bullets), 5 (decision record unchanged) and 6 (no-marker case makes no edit).
- The first live weekly run in the brain is the real test for 3 and 4, since the brain already holds bullets with the old marker; the Gate 2 PR says so.

## Risks
- A broader match removes text that is not a marker → match only the exact `(proposed; ` opening; the test asserts the diff differs only by that prefix.
- The skill grows past 150 lines → cleanup is two lines in step 9; formats live in `records.md`.
- Existing brains keep old-format bullets until the next review → that is what the cleanup is for; CHANGELOG says so.

## Rollout
Merge, then `segoy sync` in the brain (one sync PR). The next weekly run removes the old markers and lists them in its digest. No task setting changes.

## Size
S
