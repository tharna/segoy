#!/bin/sh
# shellcheck disable=SC2016  # backticks in patterns are literal Markdown, not shell.
# check-gate1-wording.sh — the Gate 1 PR text and docs/workflows.md say how to
# change a plan (edit plan.md in the PR, or close it to replan), the old
# comment-plus-answered wording is gone, and Gate 2 text is unchanged
# (I-20261116-5). Run from the repo root. Prints one line per problem; exit 1 if any.
set -u
T=kit/brain/.claude/skills/segoy-promote/pr-body.md
F=tests/fixtures/promote/pr-body.md
W=docs/workflows.md
guard=kit/common/.claude/scripts/leak-guard.sh
SENT='To change the plan, edit `plan.md` in this PR (commit to its branch), or close the PR to replan. A comment alone starts nothing.'
fail=0
bad() { echo "FAIL $*"; fail=1; }

for f in "$T" "$F" "$W"; do
  [ -f "$f" ] || { bad "missing $f"; exit 1; }
done

# The Gate 1 step in docs/workflows.md ("4. **Gate 1**").
gate1=$(grep -F '**Gate 1**' "$W")
[ "$(printf '%s\n' "$gate1" | grep -c .)" -eq 1 ] || bad "criterion 2: expected one Gate 1 step in $W"

# 1: template and rendered fixture carry the sentence and no answered.
for f in "$T" "$F"; do
  grep -qF -- "$SENT" "$f" || bad "criterion 1: $f lacks the Gate 1 sentence"
  ! grep -q 'answered' "$f" || bad "criterion 1: $f mentions answered"
done

# 2: workflows Gate 1 step: same sentence, no answered, no implement revise claim.
printf '%s\n' "$gate1" | grep -qF -- "$SENT" || bad "criterion 2: $W Gate 1 step lacks the Gate 1 sentence"
! printf '%s\n' "$gate1" | grep -q 'answered' || bad "criterion 2: $W Gate 1 step mentions answered"
! printf '%s\n' "$gate1" | grep -qF 'implement` task' || bad "criterion 2: $W Gate 1 step says the implement task revises"
! printf '%s\n' "$gate1" | grep -qF 'A close fires nothing' || bad "criterion 2: $W Gate 1 step says a close fires nothing"

# 3: the old Gate 1 revise wording is gone from kit, tasks and workflows.
for old in 'comments and adds `answered` (revise)' \
           'also listens for `answered` on `segoy:plan` PRs' \
           'Merge to approve: implementation starts from this plan. To change something, comment'; do
  hits=$(grep -rnF -- "$old" kit tasks "$W")
  [ -z "$hits" ] || bad "criterion 3: old wording remains: $hits"
done

# 4: Gate 2 text reads as before.
G2PR='**Gate 2.** Merge to accept. To change something, comment and add the label `answered`. Close to reject.'
G2W='3. **Gate 2**: owner reviews and merges. To ask for changes, including a CI failure: comment and add the label `answered`, which fires `project-implement-pr` (revise mode, pushes to the same PR). Merging fires `project-retro` and `brain-gate-sync-<repo>` (brain issue → `done`, closed). Closing without merging asks in the brain: retry, park or reject.'
for f in kit/project/.claude/skills/segoy-implement/pr-body.md .claude/skills/segoy-implement/pr-body.md; do
  grep -qxF -- "$G2PR" "$f" || bad "criterion 4: Gate 2 line changed in $f"
done
grep -qxF -- "$G2W" "$W" || bad "criterion 4: Gate 2 step changed in $W"

# 5: leak guard passes on the changed files.
"$guard" --skip "private block marker" "$T" "$F" "$W" CHANGELOG.md "$0" > /dev/null 2>&1 || bad "criterion 5: leak guard flags a changed file"

[ "$fail" -eq 0 ] && echo "ok   Gate 1 wording (5 criteria)"
exit "$fail"
