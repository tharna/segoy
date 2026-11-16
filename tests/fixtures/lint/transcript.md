# segoy-lint dry run (I-20261116-7)

Done by hand on copies of the fixture brains, following `kit/brain/.claude/skills/segoy-lint/SKILL.md` step by step. Run time 2026-01-10T16:00:00Z, run date 2026-01-10. GitHub state from `github/*.json`. No GitHub writes: no push, no PR opened, no merge, no approval. The would-be bodies are in `dry-run/`.

## Run A (findings): `dirty/` with `github/run.json`

1. Preconditions: no open `segoy:paused` issue → continue.
2. `brain-lint.sh --today 2026-01-10 .` on a git copy (one commit dated 2025-12-01): exit 1, the 11 lines in `dirty/expected-report.txt`. Seven end in ` (fixable)`.
3. Stuck ideas: issue #2 (I-20251202-1) `state:needs-input` since 2025-12-21T10:00:00Z → 20 days, listed. #3 changed 2026-01-05 (5 days), not stuck. #1 is `state:done` and closed, excluded.
4. Contradictions: `knowledge/wiki/entities/example-tool-x.md` and `knowledge/wiki/topics/example-tool-x-storage.md` share the title words "Example tool X" and link each other. Line 15 of each makes incompatible claims about the storage format → flagged with both quotes by `path:line`. Neither file edited. Other pairs sharing a topic: none conflicting.
5. Findings exist → continue.
6. Fix PR: no open `segoy:lint` PR. `brain-lint.sh --today 2026-01-10 --fix .` printed 8 `fixed` lines and left the decision's `missing source`, the raw file, the orphan and the stale page (exit 1). One `log.md` line appended. Scope check: `git diff --cached --name-only` = `ideas/I-20251201-1-example-idea-one/idea.md`, `ideas/index.md`, `knowledge/wiki/index.md`, `log.md`, `self/goals.md`: only files named by `fixed` lines plus `log.md`, nothing under `knowledge/raw/`. The appended line: `2026-01-10 · segoy-lint · fix frontmatter and index · ideas/I-20251201-1-example-idea-one/idea.md, self/goals.md, ideas/index.md, knowledge/wiki/index.md`; its hunk is left out of `dry-run/fix.diff` because a diff's leading `+` before a date matches the leak guard's phone-number rule. Diff: `dry-run/fix.diff` (frontmatter lines and index rows only; `self/goals.md` gains one frontmatter line, its body is not in the diff). Would commit `lint: fixes 2026-01-10` and open PR `Lint fixes 2026-01-10` (#11 in this dry run), labelled `segoy:lint`, body `dry-run/pr-body.md`.
7. Report issue: body `dry-run/report.md`, title `Lint 2026-01-10`, label `segoy:lint`, no `state:*` label (#12 in this dry run).
8. `self/`: only `self/goals.md` appears, by path and field name; the marker phrase planted in its body appears nowhere in the output.
9. Leak check: `leak-guard.sh --denylist kit/brain/.segoy/denylist.txt` on both bodies → exit 0.
10. Blocks: `protocol.sh` on both bodies → exit 0, one `run` block each, last.
11. Earlier open issue #9 `Lint 2026-01-03` would be closed as completed with "Superseded by #12" and a `run` block.
12. Summary: 12 findings (1 contradiction, 1 orphan, 1 stale, 5 frontmatter, 4 index, 1 stuck); PR #11, issue #12.

## Run B (paused): `dirty/` with `github/paused.json`

Run B (paused): stopped at the precondition. Files changed: none. Comments posted: none. Issue: none. PR: none.

## Run C (clean): `clean/` with `github/run.json` minus issue #2's stale label (no stuck ideas)

Run C (clean): brain-lint.sh exit 0, no stuck ideas, no contradictions → no issue, no PR, no comment. The earlier `Lint` issue #9 is left open.
