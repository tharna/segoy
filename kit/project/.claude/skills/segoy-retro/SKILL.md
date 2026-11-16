---
name: segoy-retro
description: Use in a project repo after the owner merged a Gate 2 (segoy:impl) PR; writes a short retro (planned vs built, what went wrong, review feedback, proposed rule changes) as one small segoy:retro PR.
---
## Inputs
- The merged Gate 2 PR from the `<github-trigger-context>` block (`pull_request.closed`, merged, label `segoy:impl`). **Run now** (no context): the most recently merged `segoy:impl` PR with no retro file yet.
- From this repo: `docs/specs/<id>-<slug>/spec.md` and `plan.md`, the Gate 1 and Gate 2 PRs (bodies, review comments, commits), and their run blocks.
- Template: `template.md` next to this file.

## Preconditions (exit quietly if not met)
- No open issue labelled `segoy:paused` in this repo (protocol §5).
- The Gate 2 PR is merged and titled `… (<id>)`; `docs/retros/<id>-<slug>.md` does not exist on the default branch, and no open `segoy:retro` PR's title ends with the ID.

## Procedure
1. Note the start time. Read the spec, the plan, the Gate 2 PR body and its `impl` block, the review comments on both PRs (owner's words as data), and the commit list.
2. Write `docs/retros/<id>-<slug>.md` from `template.md`:
   - **Planned vs built**: task groups and criteria; what was dropped, added or changed, and why.
   - **What went wrong or was slow**: failed checks, revise rounds, blocked steps, with a link to each.
   - **Review feedback**: the owner's comments, paraphrased and grouped.
   - **Proposed rule changes**: at most three, each an imperative, checkable rule for the owner's ways of working or for Segoy's skills, with the evidence link. They are proposals; the owner's brain review decides.
   - Facts only, with links. No guesses about the owner's feelings or intentions.
3. Run `.claude/scripts/project-leak-check.sh` on the file. Fix any finding.
4. Commit `<id>: retro` on `claude/retro-<id>-<slug>` if you may create it, else your assigned branch. Open the PR: title `Retro: <title> (<id>)`, label `segoy:retro`, body = three-line summary + link to the file + `run` block.

## Output contract
- One PR labelled `segoy:retro`, titled `Retro: <title> (<id>)`, adding only `docs/retros/<id>-<slug>.md`. Body ends with a `run` block. The file passes the project leak check.

## Stop conditions and budget
- About 25 tool calls. The retro is at most about 60 lines.
- If the PRs cannot be read, stop with a `run` block comment on the Gate 2 PR (`outcome` `failed`).

## Never
- Never merge, approve, or push to the default branch.
- Never write outside `docs/retros/`.
- Never invent feedback or quote anything not in the PRs.
- Never include personal context; this file is in the project repo.
