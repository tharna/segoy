#!/bin/sh
# shellcheck disable=SC2016  # backticks in patterns are literal Markdown, not shell.
# shellcheck disable=SC2013  # fixture paths have no spaces; loops must not run in a subshell.
# check-lint.sh — checks for the segoy-lint skill and the brain-lint task
# (I-20261116-7), run from the repo root.
#   Part 1: each acceptance criterion is stated where the agent reads it.
#   Part 2: the dry run on tests/fixtures/lint shows the behaviour.
# The helper itself is tested by tests/check-brain-lint-script.sh.
# Prints one line per problem; exit 1 if any.
set -u
S=kit/brain/.claude/skills/segoy-lint
T=tasks/brain-lint.md
F=tests/fixtures/lint
D=$F/dry-run
proto=kit/common/.claude/scripts/protocol.sh
guard=kit/common/.claude/scripts/leak-guard.sh
fail=0
bad() { echo "FAIL $*"; fail=1; }
# has FILE TEXT CRITERION — FILE contains TEXT (fixed string).
has() { grep -qF -- "$2" "$1" || bad "criterion $3: $1 does not say: $2"; }
# last_is_run FILE CRITERION — the last segoy block in FILE is a run block.
last_is_run() {
  out=$("$proto" "$1") || { bad "criterion $2: $1 fails protocol.sh"; return; }
  printf '%s\n' "$out" | grep -v ' block(s) checked' | tail -n 1 | grep -q ': run$' \
    || bad "criterion $2: last block in $1 is not a run block"
}

for f in "$S/SKILL.md" "$S/report.md" "$S/pr-body.md" "$T"; do
  [ -f "$f" ] || { bad "missing $f"; exit 1; }
done

# --- Part 1: stated in the skill and task -----------------------------------
# 1: task names the skill, a weekly schedule and the small model.
has "$T" "segoy-lint" 1
has "$T" "Schedule: weekly, **Saturday 18:00 Europe/Helsinki**" 1
has "$T" "| Model | Haiku" 1
grep -q '^  lint: haiku$' kit/brain/.segoy/config.yml.tmpl || bad "criterion 1: config template has no models.lint haiku"
# 2: pause precondition, nothing posted or changed.
has "$S/SKILL.md" 'No open issue labelled `segoy:paused`' 2
has "$S/SKILL.md" "post nothing, change nothing" 2
has "$S/SKILL.md" "Paused: nothing at all." 2
# 3: no findings, nothing opened.
has "$S/SKILL.md" "**No findings** (steps 2–4 all empty): open no issue and no PR, post no comment" 3
has "$S/SKILL.md" "No findings: no issue, no PR, no comment." 3
# 4: one Lint <date> issue, by category with path, run block last.
has "$S/SKILL.md" 'exactly one issue per run titled `Lint <run date>`' 4
has "$S/SKILL.md" "listing each finding by check category with its file path and ending with a \`run\` block" 4
for sec in Contradictions "Orphan pages" "Stale pages" Frontmatter "Index drift" "Stuck ideas"; do
  has "$S/report.md" "## $sec" 4
done
has "$S/report.md" "the \`run\` block is last" 4
last_is_run "$S/report.md" 4
# 5: contradictions quoted by location, never resolved.
has "$S/SKILL.md" 'record the pair with both statements quoted verbatim by `path:line`' 5
has "$S/SKILL.md" "Never edit either file and never resolve a contradiction" 5
has "$S/SKILL.md" "Never resolve a contradiction" 5
has "$S/report.md" '- `<path>:<line>` says "<statement, quoted verbatim>"; `<path>:<line>` says' 5
# 6, 7: orphan and stale reported, pages untouched.
has "$S/SKILL.md" "No change for contradictions, orphan or stale pages" 6
has "$S/SKILL.md" "never delete, archive, move or rewrite a wiki page" 6
has "$S/report.md" ': no inbound link.' 6
has "$S/report.md" 'days ago (threshold 90)' 7
grep -q 'more than 90 days' kit/common/.claude/scripts/brain-lint.sh || bad "criterion 7: brain-lint.sh does not state the 90-day rule"
# 8, 9: fix PR adds derivable fields, sets updated, corrects index rows.
has "$S/SKILL.md" "adds derivable fields, sets \`updated\`" 8
has "$S/SKILL.md" "The PR changes only frontmatter blocks (missing derivable fields, \`updated\`) and rows of" 9
has "$S/report.md" "not derivable, please add" 8
# 10: stuck ideas, 14 days, with state and age.
has "$S/SKILL.md" "more than **14 days** before run time" 10
has "$S/SKILL.md" "current state and days since the change" 10
has "$S/report.md" '- <idea ID> (#<issue>): `<current state>` for <n> days.' 10
# 11: nothing else in the fix PR.
has "$S/SKILL.md" "No change for contradictions, orphan or stale pages, stuck ideas, or non-derivable fields." 11
has "$S/SKILL.md" "must list only files the \`fixed\` lines name plus \`log.md\`, and nothing under \`knowledge/raw/\`" 11
# 12: one PR, segoy:lint, run block last, no merge/approve/default branch.
has "$S/SKILL.md" 'at most one PR per run titled `Lint fixes <run date>`, labelled `segoy:lint`' 12
has "$S/SKILL.md" "open no second PR" 12
has "$S/SKILL.md" "Never merge, approve or close a PR, never push to the default branch" 12
has "$T" "never to its default" 12
has "$S/pr-body.md" "the \`run\` block is last" 12
last_is_run "$S/pr-body.md" 12
jq -e '[.labels[].name] | index("segoy:lint")' kit/brain/.segoy/labels.json > /dev/null || bad "criterion 12: no segoy:lint label"
grep -q '`lint`' docs/protocol.md || bad "criterion 12: protocol §2 has no lint label"
# 13: self/ paths only, leak check on both bodies.
has "$S/SKILL.md" ".claude/scripts/leak-guard.sh --denylist .segoy/denylist.txt" 13
has "$S/SKILL.md" 'Never read past the frontmatter of a `self/` file' 13
has "$S/SKILL.md" "name only the path and field names in the issue and PR" 13
has "$S/report.md" '`self/` files appear by path and field name only' 13
[ "$(wc -l < "$S/SKILL.md")" -le 150 ] || bad "SKILL.md is over 150 lines"

# --- Part 2: dry run on the fixture brain -------------------------------------
for f in "$D/report.md" "$D/pr-body.md" "$D/fix.diff" "$F/transcript.md" "$F/github/run.json" "$F/github/paused.json"; do
  [ -f "$f" ] || { bad "missing dry-run file $f"; exit 1; }
done
R=$D/report.md
# 4: one issue body, every check category, run block last; paths named.
last_is_run "$R" 4
[ "$("$proto" "$R" | grep -c ': ')" -eq 1 ] || bad "criterion 4: report has more than the run block"
for sec in Contradictions "Orphan pages" "Stale pages" Frontmatter "Index drift" "Stuck ideas"; do
  grep -q "^## $sec$" "$R" || bad "criterion 4: dry-run report lacks $sec"
done
# Every helper finding appears in the report by path.
cut -f2 "$F/dirty/expected-report.txt" | sort -u | while read -r p; do
  grep -qF "\`$p" "$R" || echo "FAIL criterion 4: report does not name $p"
done | grep . && fail=1
# 5: contradiction pair quoted by location, neither page in the diff.
grep -q '^- `knowledge/wiki/[a-z/-]*\.md:[0-9]*` says ".*"; `knowledge/wiki/[a-z/-]*\.md:[0-9]*` says ".*"' "$R" \
  || bad "criterion 5: contradiction not quoted by location"
for p in $(sed -n '/^## Contradictions/,/^## /p' "$R" | grep -o 'knowledge/wiki/[a-z/-]*\.md' | sort -u); do
  qline=$(grep -o "$p:[0-9]*\` says \"[^\"]*\"" "$R" | head -n 1)
  n=$(printf '%s' "$qline" | sed 's/^[^:]*:\([0-9]*\).*/\1/')
  q=$(printf '%s' "$qline" | sed 's/^[^"]*"\(.*\)"$/\1/')
  sed -n "${n}p" "$F/dirty/$p" | grep -qF -- "$q" || bad "criterion 5: quote not at $p:$n"
  grep -q "^diff --git a/$p " "$D/fix.diff" && bad "criterion 5: fix changed $p"
done
# 6, 7: orphan and stale listed, untouched.
grep -q ': no inbound link\.' "$R" || bad "criterion 6: no orphan listed"
grep -q 'days ago (threshold 90)' "$R" || bad "criterion 7: no stale page listed"
for p in $(awk -F'\t' '$1 == "orphan" || $1 == "stale" { print $2 }' "$F/dirty/expected-report.txt"); do
  grep -q "^diff --git a/$p " "$D/fix.diff" && bad "criteria 6, 7, 11: fix changed $p"
done
# 8, 9, 11: diff only frontmatter, index rows, log.md; never raw.
grep '^diff --git' "$D/fix.diff" | sed 's|^diff --git a/\([^ ]*\) .*|\1|' | while read -r p; do
  case $p in
    knowledge/raw/*) echo "FAIL criterion 11: fix changed raw file $p" ;;
    log.md|*index.md) ;;
    *) grep -q "	$p	missing .* (fixable)" "$F/dirty/expected-report.txt" || echo "FAIL criterion 11: $p changed without a fixable finding" ;;
  esac
done | grep . && fail=1
grep -q '^+updated: 2026-01-10$' "$D/fix.diff" || bad "criterion 8: updated not set to the run date"
grep -q '^+links: \[\]$' "$D/fix.diff" || bad "criterion 8: derivable field not added"
grep -q '^diff --git a/ideas/index.md ' "$D/fix.diff" || bad "criterion 9: ideas index not corrected"
grep -q 'missing `source` (not derivable, please add)' "$R" || bad "criterion 8: non-derivable field not reported"
# 10: stuck idea with state and age.
grep -q '^- I-[0-9-]* (#[0-9]*): `[a-z-]*` for [0-9]* days\.$' "$R" || bad "criterion 10: stuck idea not listed with state and age"
# 12: PR body valid, run block last, one PR.
last_is_run "$D/pr-body.md" 12
grep -q 'Lint fixes 2026-01-10' "$D/pr-body.md" || bad "criterion 12: PR title line"
grep -q 'no push, no PR opened, no merge, no approval' "$F/transcript.md" || bad "criterion 12: transcript"
# 13: no self/ body text, leak check clean.
grep -rh 'SELF-BODY-MARKER' "$D" "$F/transcript.md" && bad "criterion 13: self/ body text in the dry run"
"$guard" --denylist kit/brain/.segoy/denylist.txt "$R" "$D/pr-body.md" > /dev/null || bad "criterion 13: leak-guard finds something"
# 2, 3: paused and clean runs open nothing.
jq -e '[.issues[] | select(.state == "open" and (.labels | index("segoy:paused")))] | length == 1' "$F/github/paused.json" > /dev/null \
  || bad "criterion 2: paused fixture has no open segoy:paused issue"
grep -q 'Run B (paused): stopped at the precondition. Files changed: none. Comments posted: none. Issue: none. PR: none.' "$F/transcript.md" || bad "criterion 2: transcript run B"
grep -q 'Run C (clean): brain-lint.sh exit 0, no stuck ideas, no contradictions → no issue, no PR, no comment.' "$F/transcript.md" || bad "criterion 3: transcript run C"

exit "$fail"
