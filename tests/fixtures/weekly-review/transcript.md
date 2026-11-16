# Dry run: segoy-weekly-review on the fixture brain

Executed by hand by the implementing session for I-20261116-2 and updated for I-20261116-3 (runs B–D), step by step from `kit/brain/.claude/skills/segoy-weekly-review/SKILL.md`. GitHub is simulated by `github/*.json`; nothing was pushed, opened, merged or posted. Run time 2026-01-04T16:00:00Z (Sunday 18:00 Europe/Helsinki), week 2026-W01, period 2025-12-28T16:00:00Z to 2026-01-04T16:00:00Z.

## Run A: `github/paused.json` (criterion 2)
- Precondition 1: issue #20 is open and labelled `segoy:paused` → stop at once.
- Branch: none. Files changed: none. Comments posted: none. PR: none.

## Run B: `github/empty.json` (criterion 4)
- Brain: `brain/` with `no-marker/brain/ways/public/principles.md` in place of its `ways/public/principles.md`, so no leftover marker makes the week non-empty.
- Preconditions: no pause issue, no open `segoy:review` PR → continue.
- Step 2: no issue has a label event or comment in the period; no note issues; no `decision` blocks; no parked or rejected issue; no `segoy:*` PR closed and no retro added in the period.
- Step 7: #3 label `state:specced` = file `specced`; #4 `state:needs-input` = index `needs-input` → no drift. #3 last changed 2025-12-28, before the period.
- Step 8 (state only): #4 `state:needs-input` since 2025-12-15 (20 days) is stuck, but a stuck idea alone does not make a week non-empty (spec criterion 4: no activity and no drift).
- Step 9 cleanup: no `ways/` bullet has a `(proposed; ` opening → nothing to clean.
- Step 3: empty week → no branch, no PR, no comment. Output: "2026-W01: nothing to review."

## Run C: `github/active.json` (criteria 3, 5–11)
- Preconditions: no pause issue, no open `segoy:review` PR → continue.
- Step 2: in the period: #3 (label event 2026-01-02), #5 (2025-12-30), #12 (created 2026-01-02); note #12 unfiled; comment 105 on #5 carries a `decision` block with no record; #5 is `state:parked` with no idea folder; project PR #9 merged 2026-01-03; retro `docs/retros/I-20251210-1-example.md` added 2026-01-03.
- Step 4: note #12 → `knowledge/raw/20260102-example-article-about-checklists.md` (verbatim). Nothing under `knowledge/wiki/`. (6)
- Step 5: comment 105 → `decisions/D-20251230-1.md` (gate `triage`, subject `I-20251220-1`, outcome `parked`, source = comment URL); row in `decisions/index.md`. (5)
- Step 6: #5 → `ideas/I-20251220-1-example-parked-idea/idea.md` (`state: parked`, source = issue URL); row in `ideas/index.md`. (5)
- Step 7: #3 label `state:planned`, file and index `specced` → both set to `planned`; listed under "State corrections". Label-vs-PR: spec PR #13 merged and #3 is `planned` → consistent, nothing under "Needs you". (7)
- Step 8: #4 `state:needs-input` since 2025-12-15T09:00Z → 20 days → listed with its state. (8)
- Step 9: retro "Proposed rule changes" → p1, a new final bullet in `ways/public/principles.md` ending `(source: …, 2026-01-04)` with no `proposed` marker; listed as `p1 (proposal)` in the PR body and the digest. (I-20261116-3 criteria 1, 2)
- Step 9 cleanup, reading `ways/**` as checked out at run start: one bullet in `ways/public/principles.md` opens its note with `(proposed; ` → rewritten to `(`, rest unchanged; listed under "Markers removed" with file and bullet text. `decisions/D-20251215-1.md` keeps its `(proposed)` generalisation and is not in the diff. (I-20261116-3 criteria 3, 4, 5)
- Step 10: seven `log.md` lines (file note, record decision, stub idea, fix state, propose way, clean marker, write digest). (5)
- Step 11: `journal/2026-W01.md` from `digest.md`.
- Step 12: `leak-guard.sh --denylist .segoy/denylist.txt ways/public/principles.md` (the only changed shareable file) → exit 0. No `self/` file read or written. (10)
- Step 13: branch built locally only; PR body in `pr-body.md` (`Closes #12`, `review` block, `run` block last); `protocol.sh pr-body.md` → 2 blocks ok. Would open `Review 2026-W01` labelled `segoy:review`. (3)
- Not done: no push, no PR opened, no merge, no approval, no label change, nothing written to the project. (11)

## Run D: `github/active.json` on the brain without a leftover marker (I-20261116-3 criterion 6)
- Brain: as in run B (`no-marker/brain/ways/public/principles.md`).
- Steps 2–8 as in run C. Step 9: p1 written as in run C; cleanup finds no `(proposed; ` opening → no cleanup edit, no `clean marker` log line, no "Markers removed" section.
- Changed `ways/` file and digest: `no-marker/dry-run/`; all other files as in `dry-run/`.

Files on the branch: see `dry-run/`. `tests/check-weekly-review.sh` re-checks all of the above.
