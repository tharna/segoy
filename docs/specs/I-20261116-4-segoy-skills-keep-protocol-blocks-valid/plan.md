---
id: I-20261116-4
title: Kit skills keep their protocol blocks valid
kind: plan
state: planned
visibility: shareable
created: 2026-11-16
updated: 2026-11-16
source: promoted
links: []
---
# Plan: Kit skills keep their protocol blocks valid

## Assumptions
- PoC: not needed (existing repo)
- `protocol.sh` already rejects all three named mistakes: `target` with `/` (spec block), a `decision` block without `idea`, and it reads only one text at a time, so stale counts are caught by a recount rule in `segoy-spec`, not by the validator (firm, `kit/common/.claude/scripts/protocol.sh`)
- The open question takes its default: the check covers every text holding `segoy` blocks that a skill posts **or writes to a file** (likely, spec Open questions)
- Skills that post blocks, and so get the check: brain `segoy-gate-sync`, `segoy-onboard`, `segoy-plan` (its failure comment), `segoy-promote`, `segoy-respond`, `segoy-spec`, `segoy-triage`, `segoy-weekly-review`; common `segoy-sync`; project `segoy-implement`, `segoy-retro`. `segoy-capture` hands over to `segoy-triage` and posts no block itself, so it is left out (likely, `grep` of the kit)
- "Two attempts" means: after the first failed check, fix and re-check at most twice; if the third check still fails, post nothing. The `failed` run is reported in a comment that holds only a `run` block, itself checked first; that is the one post allowed after a failed check (guess, spec criterion 5)
- Examples in the templates sit inside four-backtick fences, which `protocol.sh` skips by design, and use `<…>` placeholders that are not valid JSON. Criterion 6 is checked by a test script that unwraps those fences and fills the placeholders with fixed sample values before running `protocol.sh`; `protocol.sh` itself is not changed (likely, spec Out of scope)
- The `subject` field in the decision-record **file** frontmatter (`segoy-weekly-review/records.md`) is a file field, not a block field, and stays (firm, spec In scope names only the block)
- The canonical wording copied verbatim into every skill that posts blocks (criterion 7): "**Check blocks before posting.** Write the comment, PR body or file to a scratch file and run `.claude/scripts/protocol.sh <file>`; post or commit it only if the script exits 0. On any other exit (1 = invalid block, 2 = usage error or missing `jq`), fix what it names and run it again, at most twice; if it still fails, post nothing and report a `failed` run in a comment holding only a `run` block." (likely, spec criteria 4, 5 and 7)
- The brain kit is not vendored into this repo's `.claude/`; the common and project kit are, so `scripts/segoy sync .` is run in the same commit as the wording change (firm, `.claude/skills/` lists `segoy-implement`, `segoy-retro`, `segoy-sync`)

## Approach
One commit puts the canonical "check blocks before posting" step into every skill that posts or writes `segoy` blocks, replacing the older, weaker wording (`segoy-promote` step 4 "or by hand", `segoy-triage` step 12 "if a check script is available", the `segoy-sync` and `segoy-weekly-review` one-liners). The same commit fixes `segoy-spec` itself: the `target` is the bare repo name, revise mode's `decision` block carries `idea` (with a template), and revise mode recounts `criteria`, `open_questions` and `private_blocks` from the pushed `spec.md` and edits the PR body's `spec` block to match.

A new test, `tests/check-kit-blocks.sh`, proves the rest: it runs `protocol.sh` over every kit file as is, then over unwrapped copies of every four-backtick example with placeholders filled, checks the canonical sentence is present in each listed skill, and runs the `segoy-spec` revise fixture (block fixtures that must fail; a revised `spec.md` with its PR body whose counts must match).

## Components touched
- `kit/brain/.claude/skills/segoy-spec/SKILL.md`: step 2/8 target wording, revise-mode `decision` block with `idea`, recount step, canonical check step.
- `kit/brain/.claude/skills/segoy-spec/templates.md`: `spec` block note "`target` is the repo name without owner, or `none`"; new "Revise comment" template with `decision` and `run` blocks.
- `SKILL.md` of `segoy-gate-sync`, `segoy-onboard`, `segoy-plan`, `segoy-promote`, `segoy-respond`, `segoy-triage`, `segoy-weekly-review` (brain), `segoy-sync` (common), `segoy-implement`, `segoy-retro` (project): canonical check step; old wording removed.
- `.claude/skills/{segoy-implement,segoy-retro,segoy-sync}/SKILL.md`: via `scripts/segoy sync .`.
- `kit/common/KIT.md`, `docs/protocol.md` (§1 validation line), `docs/workflows.md` where it mentions checking blocks, `CHANGELOG.md`.
- `tests/check-kit-blocks.sh`, `tests/fixtures/kit-blocks/**`, `tests/run.sh`.

## Task groups
### T1 Skills, templates and docs in one commit
- Files: the eleven `SKILL.md` files above, `segoy-spec/templates.md`, `kit/common/KIT.md`, `docs/protocol.md`, `docs/workflows.md`, `CHANGELOG.md`, the synced `.claude/skills/**`.
- Steps:
  1. `segoy-spec`: in step 8 Create say "`target` in the `spec` block is the repo name without owner (`<repo>`, never `<owner>/<repo>`), or `none`"; in Revise say the `decision` block has `idea` (the idea ID), `gate` `spec`, `outcome` `changed`, `reason`, and never `subject`; add Revise step "Recount from the pushed `spec.md`: `criteria` = numbered items under *Acceptance criteria*, `open_questions` = bullets under *Open questions* (0 for `none`), `private_blocks` = opening private-block markers; edit the PR body's `spec` block and the summary lines to match".
  2. `templates.md`: note under the PR body; add a "Revise comment" template (at most 5 bullets, `decision` block with `idea`, `run` block).
  3. Add the canonical sentence as a numbered step right before each skill's posting step, in each listed skill; delete the older check wording in `segoy-promote` step 4, `segoy-triage` step 12, `segoy-sync` step 2 and `segoy-weekly-review` step 13 (keeping their other content).
  4. `KIT.md`: drop "(M4)" and say every skill that posts blocks runs it first. `docs/protocol.md` §1 and `docs/workflows.md`: same rule, one line each. CHANGELOG `Unreleased` → `Changed`.
  5. `scripts/segoy sync .` and stage `.claude/`.
- Check: `scripts/segoy doctor --skills` passes; `wc -l kit/*/.claude/skills/*/SKILL.md` each ≤ 150; `git show --stat HEAD` lists every listed skill in one commit; `grep -rn '"subject"' kit/*/.claude/skills` → no hit inside a block; `grep -rn 'by hand\|if a check script is available' kit/*/.claude/skills/*/SKILL.md` → no hit about block checks.
- Covers criteria: 1, 2, 3, 4, 5, 7

### T2 Kit-wide block check and fixtures
- Files: `tests/check-kit-blocks.sh`, `tests/fixtures/kit-blocks/bad-target.md`, `bad-decision.md`, `revise/spec.md`, `revise/pr-body.md`, `revise/comment.md`, `tests/run.sh`.
- Steps:
  1. Part 1 (criterion 6): run `protocol.sh` on every `kit/**/*.md`; then for each file with four-backtick fences, write a copy with the ```` lines removed and placeholders filled by a fixed `sed` map (`<id>` → `I-20260101-1`, unquoted `<n>` → `1`, `<iso>` → `2026-01-01T00:00:00Z`, `<url>` → `https://example.com`, `<owner>/<…>` → `example/<…>`, `<S|M|L>` → `S`, `<firm|likely|guess>` → `likely`, other enum placeholders → their first option) and run `protocol.sh` on it. Every run must exit 0, and each run must report at least one block for the files known to hold them.
  2. Part 2 (criteria 4, 5, 7): the canonical sentence is found verbatim (`grep -F`) in each of the eleven skills; `segoy-capture` is not required.
  3. Part 3 (criteria 1, 2): `bad-target.md` (`"target": "example/repo"`) and `bad-decision.md` (`subject` and no `idea`) make `protocol.sh` exit 1; the `spec` and `decision` templates in `segoy-spec/templates.md`, filled, pass.
  4. Part 4 (criterion 3): a dry-run revise fixture: `revise/spec.md` after a revision that adds a criterion, removes an open question and adds a private block; `revise/pr-body.md` as the skill would leave it; the script recounts with `awk` and compares with the block's numbers; `revise/comment.md` passes `protocol.sh` and has `idea` in its `decision` block.
  5. Add the script to `tests/run.sh`.
- Check: `tests/check-kit-blocks.sh` → exit 0; `tests/run.sh` → all pass; `shellcheck -x tests/*.sh` → clean.
- Covers criteria: 1, 2, 3, 4, 5, 6, 7

## Test plan
- Part 1 of the new script proves criterion 6 over the whole kit in one run.
- Parts 2 and 3 prove the skills state criteria 1, 2, 4, 5 and 7 and that the validator refuses the two block mistakes.
- Part 4 proves the recount rule (criterion 3) on a dry-run artefact.
- The next live spec revise and Gate 1 promotion in a brain are the real test; the Gate 2 PR says so.

## Risks
- The placeholder map misses a new placeholder and an example fails → the script prints the file and line; extend the map rather than editing the example into something less readable.
- Eleven skills grow → the check step is one sentence; long templates stay in sibling files; all stay well under 150 lines.
- A run that cannot reach `jq` posts nothing at all → exit 2 is a failure by spec; the `failed` run comment tells the owner, and `segoy doctor` already checks `jq`.

## Rollout
Merge, then `segoy sync` in each brain and project repo (one sync PR each). No task setting changes.

## Size
M
