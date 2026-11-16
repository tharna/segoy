#!/bin/sh
# shellcheck disable=SC2016  # backticks in patterns are literal Markdown, not shell.
# check-respond.sh — segoy-respond goes straight to the spec for a fully answered
# kind:task issue and keeps answers sent with /spec or /plan (I-20261116-8).
# Run from the repo root.
#   Part 1: each acceptance criterion is stated in the skill.
#   Part 2: the fixture cases in tests/fixtures/respond have valid blocks and
#           a matching entry in the hand-run transcript.
# Prints one line per problem; exit 1 if any.
set -u
S=kit/brain/.claude/skills/segoy-respond/SKILL.md
F=tests/fixtures/respond
proto=kit/common/.claude/scripts/protocol.sh
fail=0
bad() { echo "FAIL $*"; fail=1; }
# has FILE TEXT CRITERION — FILE contains TEXT (fixed string).
has() { grep -qF -- "$2" "$1" || bad "criterion $3: $1 does not say: $2"; }

for f in "$S" "$F/transcript.md"; do
  [ -f "$f" ] || { bad "missing $f"; exit 1; }
done

# --- Part 1: stated in the skill ---------------------------------------------
# 8: no "wins over answers" for any command.
! grep -q 'wins over answers' "$S" || bad "criterion 8: $S still says a command wins over answers"
# 1, 3: the kind:task bullet; kind:idea stops at triaged.
has "$S" '**Small, clear change**: the issue has the `kind:task` label, every question of the latest round is answered in this reply' 1
has "$S" 'do what `/spec` does (step 4) in this run; do not stop at `state:triaged`' 1
has "$S" 'for a `kind:idea` issue or a `kind:task` issue with a partial reply → set `state:triaged`' 3
# 2, 4: answers first, defaults only for the rest.
has "$S" '`/spec` or `/plan` → apply the reply'"'"'s answers to the latest round first (step 5 rules); only questions left unanswered take their defaults' 4
has "$S" 'questions that only fall back to their default do not count' 2
has "$S" 'An omitted question takes its default.' 2
# 5: park and reject still apply alongside answers.
has "$S" '`/park` → set `state:parked`. `/unpark` → `state:triaged`. These apply whatever answers the reply also holds.' 5
has "$S" '`/reject <reason>` → set `state:rejected`; close the issue with reason "not planned"; quote the reason in the comment. This applies whatever answers the reply also holds.' 5
# 6, 7: paused precondition, claim first and label rules unchanged (pinned text).
has "$S" '- No open issue labelled `segoy:paused` in this repo (protocol §5).' 6
has "$S" '**Claim first (event mode):** once the preconditions pass, remove the `answer_label` label from the issue or PR **before any other change**.' 7
has "$S" '10. **Remove any other `state:*` label** so the issue keeps exactly one.' 7
has "$S" 'Post your own comment (step 8) only if `segoy-spec` stopped before opening a PR.' 7
has "$S" '- `/spec`, `/plan`, or a fully answered `kind:task`: whatever `segoy-spec` produces' 7
[ "$(wc -l < "$S")" -le 150 ] || bad "$S is over 150 lines"

# --- Part 2: fixtures and transcript -----------------------------------------
n=0
for c in task-all-answered task-partial idea-all-answered answers-plus-spec park-plus-answers; do
  f=$F/$c.md
  [ -f "$f" ] || { bad "missing fixture $f"; continue; }
  n=$((n + 1))
  "$proto" "$f" > /dev/null 2>&1 || bad "fixture $f fails protocol.sh"
  grep -qF "## Expected outcome" "$f" || bad "fixture $f has no expected outcome"
  grep -qxF "## Case $c" "$F/transcript.md" || bad "transcript has no entry for $c"
  grep -qF "Matches \`$c.md\`" "$F/transcript.md" || bad "transcript does not match $c to its fixture"
done
for f in "$F"/*.md; do
  c=$(basename "$f" .md)
  [ "$c" = transcript ] && continue
  grep -qxF "## Case $c" "$F/transcript.md" || bad "fixture $c has no transcript entry"
done
grep -q '^Paused: stopped at the first precondition. Labels changed: none' "$F/transcript.md" \
  || bad "criterion 6: transcript has no paused run"
# Expected outcomes per criterion.
grep -qF 'Result: spec runs: yes. Matches `task-all-answered.md`' "$F/transcript.md" || bad "criterion 1: task-all-answered does not start the spec"
grep -qF 'Result: spec runs: no. Matches `task-partial.md`' "$F/transcript.md" || bad "criterion 2: task-partial starts the spec"
grep -qF 'Result: spec runs: no. Matches `idea-all-answered.md`' "$F/transcript.md" || bad "criterion 3: idea-all-answered starts the spec"
grep -qF 'Q&A in the spec: q1 desktop (your answer, kept), q2 no (default, left unanswered)' "$F/answers-plus-spec.md" || bad "criterion 4: answers-plus-spec loses the owner's answer"
grep -qF 'State labels after the run: `state:parked` only.' "$F/park-plus-answers.md" || bad "criterion 5: park-plus-answers does not park"

[ "$fail" -eq 0 ] && echo "ok   segoy-respond straight to spec ($n cases)"
exit "$fail"
