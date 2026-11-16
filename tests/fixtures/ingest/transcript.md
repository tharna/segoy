# Dry run: segoy-ingest on the fixture brain

Executed by hand by the implementing session for I-20261116-6, step by step from `kit/brain/.claude/skills/segoy-ingest/SKILL.md`. GitHub is simulated by `github/*.json`; nothing was pushed, opened, merged or posted. Run time 2026-01-02T10:00:00Z.

## Run A: `github/paused.json` (criterion 9)
- Precondition 1: issue #20 is open and labelled `segoy:paused` → stop at once.
- Branch: none. Files changed: none. Comments posted: none. PR: none.

## Run B: `github/no-raw.json` (quiet exit)
- Preconditions: no pause issue; trigger PR #15 is merged but added no file under `knowledge/raw/` → exit quietly.
- Branch: none. Files changed: none. Comments posted: none. PR: none. Output: "PR #15 added no raw file; nothing to ingest."

## Run C: `github/merged.json` (criteria 1–8)
- Preconditions: no pause issue; PR #14 merged and added `knowledge/raw/20260101-example-article-about-checklists.md` (status `added`); no `segoy:knowledge` PR title ends with `(20260101-example-article-about-checklists)` → one candidate. (1, 6)
- Step 2: 1 candidate, under the cap of 5.
- Step 3.1: read the raw file; frontmatter `shareable`, so only its private block is private. Nothing under `knowledge/raw/` written. (2, 7)
- Step 3.2: `knowledge/wiki/index.md` and titles list "Checklists" (`topics/checklists.md`), which matches the source's main topic → bears on it. No page for the named checklist tool. (4)
- Step 3.3: wrote `knowledge/wiki/sources/20260101-example-article-about-checklists.md` (kind `source`, `Sources` section links `../../raw/20260101-example-article-about-checklists.md`). (3)
- Step 3.4: updated `topics/checklists.md` in place: new paragraph, a `Sources` line for the raw file, raw path added to `links`, `id` and `created` kept, `updated` 2026-01-02. No second checklists page. (3, 4)
- Step 3.5: created `entities/example-checklist-tool.md`, `visibility: private`, citing the raw file. (3)
- Step 3.6: the private part (household budget) appears only inside `<!-- private -->` blocks, in the source page and the topic page. (7)
- Step 3.7: `knowledge/wiki/index.md` gained the entity line under "Working practices" and the source line under a new "Sources" heading; the topic line stays. (5)
- Step 3.8: one `log.md` line: `2026-01-02 · segoy-ingest · ingest 20260101-example-article-about-checklists · <5 files>`. (5)
- Step 3.9: `strip-private.sh topics/checklists.md | leak-guard.sh --denylist .segoy/denylist.txt -` (the only changed shareable page) → exit 0. Running `leak-guard.sh` on the page without stripping flags the private block markers themselves, which is why the step strips first.
- Step 3.10: changed files: `knowledge/wiki/sources/20260101-example-article-about-checklists.md`, `knowledge/wiki/topics/checklists.md`, `knowledge/wiki/entities/example-checklist-tool.md`, `knowledge/wiki/index.md`, `log.md`; nothing under `knowledge/raw/`. (2)
- Step 3.11: PR body in `pr-body.md`; `protocol.sh pr-body.md` → 1 block ok, `run` last. (8)
- Step 3.12: would commit `ingest: 20260101-example-article-about-checklists` on the assigned branch and open `Ingest: Example article about checklists (20260101-example-article-about-checklists)` labelled `segoy:knowledge`. (1)
- Not done: no push, no PR opened, no merge, no approval, no label change.

## Run D: `github/run-now.json` (criteria 1, 6)
- Preconditions: no pause issue; no trigger context → Run now. Raw files on the default branch: `20251220-example-covered-note` (covered by open PR #11, title ends with `(20251220-example-covered-note)`) → skipped; `20260101-example-article-about-checklists` → uncovered.
- Steps 2–3: one candidate, same output as run C. The covered note got no files and no PR. (6)

Files on the branch: see `dry-run/`. `tests/check-ingest.sh` re-checks all of the above.
