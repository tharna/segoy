---
name: segoy-promote
description: Use right after segoy-plan in the brain-plan-promote task; strips private content, runs the mandatory leak check, and opens the Gate 1 PR (segoy:plan) in the project repo, then updates the idea's brain issue.
---
## Inputs
- From `segoy-plan`: idea ID and slug, the brain and project checkout paths, the spec path (brain), the scratch plan path.
- The brain's `.segoy/denylist.txt` and `.segoy/config.yml`.
- Scripts in the brain: `.claude/scripts/strip-private.sh`, `.claude/scripts/leak-guard.sh`.
- Template: `pr-body.md` next to this file.

## Preconditions (exit quietly if not met)
- No open issue labelled `segoy:paused` in the brain or the project (protocol §5).
- Both scripts exist and are executable in the brain checkout. If not, **stop** (no quiet exit): comment on the idea's issue with a `run` block, `outcome` `failed`, next "owner: run segoy init brain to restore the kit scripts".
- No open `segoy:plan` PR for this ID in the project.

## Procedure
1. Note the start time. Let `B` be the brain path, `P` the project path, `D` = `docs/specs/<id>-<slug>` inside `P`.
2. **Strip.** `B/.claude/scripts/strip-private.sh <spec>` → `P/D/spec.md`, and the same for the scratch plan → `P/D/plan.md`. Each run prints `removed N private block(s)`; their sum is `omitted_private`. If either run fails (unbalanced markers), stop: comment on the brain issue (`outcome` `stopped`, next "owner: fix the private markers in the spec").
3. **Rewrite for the project**, in `P/D/` only:
   - frontmatter `visibility: shareable`, `source: promoted`, `links: []`, `state` (`specced` for spec, `planned` for plan);
   - remove every remaining link or path into the brain (`ideas/`, `self/`, `ways/`, `decisions/`, `knowledge/`, `journal/`), replacing it with a plain statement or with `brain`;
   - no mention of the brain repo's name or URL.
4. **Write the PR body** from `pr-body.md` into a scratch file, ending with the `plan` block (protocol §3.6, `checks` `{"leak-check": "pass"}`) and a `run` block.
5. **Leak check (mandatory, never skip).** Run
   `B/.claude/scripts/leak-guard.sh --denylist B/.segoy/denylist.txt P/D/spec.md P/D/plan.md <pr-body file>`.
   - Exit 0 → continue.
   - Any finding → **do not commit or push anything to the project.** Delete `P/D/`. Comment on the **brain** issue: which file and rule, and the line numbers the guard printed. Never the matched text. Set `state:needs-input`, `run` block with `outcome` `stopped` and `checks` `{"leak-check": "fail"}`. End the run.
6. **Check blocks before posting.** Write the comment, PR body or file to a scratch file and run `.claude/scripts/protocol.sh <file>`; post or commit it only if the script exits 0. On any other exit (1 = invalid block, 2 = usage error or missing `jq`), fix what it names and run it again, at most twice; if it still fails, post nothing and report a `failed` run in a comment holding only a `run` block.
7. **Publish.** In `P`: commit `D/` with message `<id>: plan` on `claude/plan-<id>-<slug>` if you may create it, else your assigned branch (ADR-020). Push. Open the PR: title `Plan: <title> (<id>)`, label `segoy:plan`, body from step 4. Never merge it.
8. **Update the brain issue** (the idea's issue, found by ID in its triage comment):
   - one comment: the Gate 1 PR link; the private side (D1): the omitted private items summarised in a few bullets, which stays in the brain; a `run` block with `checks` `{"leak-check": "pass"}`;
   - labels: remove the current `state:*` and add `state:promoted`.

## Output contract
- Project repo: exactly one new PR labelled `segoy:plan`, titled `Plan: <title> (<id>)`, adding only `docs/specs/<id>-<slug>/spec.md` and `plan.md`; body from `pr-body.md` ending with valid `plan` and `run` blocks. All of it passed the leak check with the brain's denylist.
- Brain: one comment on the idea's issue; `state:promoted`. On a failed leak check: nothing in the project, a `stopped` comment, `state:needs-input`.

## Stop conditions and budget
- About 25 tool calls. Never retry a failed leak check by weakening the text automatically more than once. If a reword is needed, reword once, re-run the check, and stop if it still fails.
- If the push or PR creation fails twice, stop with a `failed` run block on the brain issue.

## Never
- Never skip, shorten or work around step 5. Never push anything to the project before it passes.
- Never print, quote or paraphrase a leak-guard finding's matched text, a denylist term, or `self/` content anywhere outside the brain.
- Never write in the project outside `docs/specs/<id>-<slug>/`. Never push to the project's default branch, merge, or approve.
- Never mention the brain repo's name, URL or paths in the project.
- Never add the `answered` label or any label meant to start a step.
