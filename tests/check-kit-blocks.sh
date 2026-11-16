#!/bin/sh
# shellcheck disable=SC2016  # backticks in patterns are literal Markdown, not shell.
# check-kit-blocks.sh — every `segoy` block example in the kit passes protocol.sh,
# every skill that posts blocks carries the same "Check blocks before posting"
# step, protocol.sh refuses the two segoy-spec block mistakes, and a revised
# spec PR body's counts match its spec.md (I-20261116-4).
# Run from the repo root. Prints one line per problem; exit 1 if any.
set -u
proto=kit/common/.claude/scripts/protocol.sh
FX=tests/fixtures/kit-blocks
CANON='**Check blocks before posting.** Write the comment, PR body or file to a scratch file and run `.claude/scripts/protocol.sh <file>`; post or commit it only if the script exits 0. On any other exit (1 = invalid block, 2 = usage error or missing `jq`), fix what it names and run it again, at most twice; if it still fails, post nothing and report a `failed` run in a comment holding only a `run` block.'
SKILLS='brain/segoy-gate-sync brain/segoy-onboard brain/segoy-plan brain/segoy-promote
brain/segoy-respond brain/segoy-spec brain/segoy-triage brain/segoy-weekly-review
common/segoy-sync project/segoy-implement project/segoy-retro'

fail=0
bad() { echo "FAIL $*"; fail=1; }
tmp=$(mktemp -d) || exit 2
trap 'rm -rf "$tmp"' EXIT

# fill FILE — blank the four-backtick fence lines (line numbers stay those of FILE) and fill template placeholders
# with fixed sample values, so the examples become real blocks.
fill() {
  sed \
    -e 's/^````.*$//' \
    -e 's/"<id>"/"I-20260101-1"/g' -e 's/"<idea ID>"/"I-20260101-1"/g' \
    -e 's/: <n>/: 1/g' \
    -e 's/"<iso>"/"2026-01-01T00:00:00Z"/g' \
    -e 's|"<url>"|"https://example.com"|g' \
    -e 's|"<owner>/|"example/|g' \
    -e 's/"<yyyy>-W<ww>"/"2026-W01"/g' \
    -e 's/"<\([a-z-]*\)|[^">]*>"/"\1"/g' \
    -e 's/"<\([A-Z]\)|[^">]*>"/"\1"/g' "$1"
}
# count_open FILE — lines that open a segoy block outside four-backtick fences
# after filling (what protocol.sh must report as checked).
count_open() { grep -c '^```segoy$' "$1"; }

# Part 1 (criterion 6): every kit Markdown file as is, then filled copies.
find kit -name '*.md' | sort > "$tmp/files"
# shellcheck disable=SC2046  # file names in kit/ have no spaces.
"$proto" $(cat "$tmp/files") > "$tmp/asis" 2>&1 || { bad "criterion 6: protocol.sh fails on the kit as is"; cat "$tmp/asis"; }
examples=0
while IFS= read -r f; do
  grep -q '^````' "$f" || continue
  fill "$f" > "$tmp/filled.md"
  want=$(count_open "$tmp/filled.md")
  [ "$want" -gt 0 ] || continue
  if ! "$proto" "$tmp/filled.md" > "$tmp/out" 2>&1; then
    bad "criterion 6: example blocks in $f fail protocol.sh:"; sed "s|$tmp/filled.md|$f (filled)|" "$tmp/out"
  fi
  got=$(sed -n 's/^\([0-9]*\) block(s) checked$/\1/p' "$tmp/out")
  [ "$got" = "$want" ] || bad "criterion 6: $f has $want example block(s), protocol.sh checked ${got:-0}"
  examples=$((examples + got))
done < "$tmp/files"
[ "$examples" -ge 10 ] || bad "criterion 6: only $examples example block(s) found in the kit"

# Part 2 (criteria 4, 5, 7): the canonical step, verbatim, in every skill that posts blocks.
for s in $SKILLS; do
  f=kit/${s%%/*}/.claude/skills/${s#*/}/SKILL.md
  [ "$(grep -cF -- "$CANON" "$f")" -eq 1 ] || bad "criterion 7: $f lacks the check step exactly once"
done
for f in kit/*/.claude/skills/*/SKILL.md; do
  ! grep -qE 'if a check script is available|checking the field tables by hand' "$f" || bad "criterion 4: $f keeps the old check wording"
done

# Part 3 (criteria 1, 2): the validator refuses both mistakes; the skill and templates use the valid forms.
"$proto" "$FX/bad-target.md" > "$tmp/out" 2>&1 && bad "criterion 1: owner-prefixed target passed"
grep -qF 'spec: bad field target' "$tmp/out" || bad "criterion 1: no target error reported"
"$proto" "$FX/bad-decision.md" > "$tmp/out" 2>&1 && bad "criterion 2: decision with subject passed"
grep -qF 'decision: missing field: idea' "$tmp/out" || bad "criterion 2: no missing-idea error reported"
SP=kit/brain/.claude/skills/segoy-spec
fill "$SP/templates.md" > "$tmp/spec-t.md"
"$proto" "$tmp/spec-t.md" > "$tmp/out" 2>&1 || bad "criteria 1, 2: segoy-spec templates fail protocol.sh"
for k in spec decision; do
  grep -q "^ok   .*: $k\$" "$tmp/out" || bad "criteria 1, 2: no valid $k block in segoy-spec templates"
done
grep -qF 'repo name without owner (`<repo>`, never `<owner>/<repo>`), or `none`' "$SP/SKILL.md" || bad "criterion 1: segoy-spec does not say target has no owner"
grep -qF '`decision` block (`idea` = the idea ID' "$SP/SKILL.md" || bad "criterion 2: segoy-spec revise decision block does not name idea"
! grep -q '"subject"' "$SP/SKILL.md" "$SP/templates.md" || bad "criterion 2: segoy-spec still shows a subject field"

# Part 4 (criterion 3): dry-run revise. Recount spec.md and compare with the PR body's spec block.
recount() {
  awk '
    /^## / { sec = $0; next }
    sec == "## Acceptance criteria" && /^[0-9]+\. / { c++ }
    sec == "## Open questions" && /^- / && tolower($0) !~ /^- none/ { q++ }
    $0 == "<!-- private -->" { p++ }
    END { printf "%d %d %d\n", c, q, p }' "$1"
}
block_counts() {
  awk '$0=="```segoy"{b=1;next} b&&$0=="```"{b=0;next} b' "$1" |
    jq -rs 'map(select(.kind=="spec"))[0] | "\(.criteria) \(.open_questions) \(.private_blocks)"'
}
grep -qF 'recount from the pushed `spec.md`' "$SP/SKILL.md" || bad "criterion 3: segoy-spec has no recount step"
want=$(recount "$FX/revise/spec.md")
[ "$want" = "3 1 2" ] || bad "criterion 3: fixture recount is '$want', expected '3 1 2'"
[ "$(block_counts "$FX/revise/pr-body.md")" = "$want" ] || bad "criterion 3: revised PR body counts differ from spec.md"
[ "$(block_counts "$FX/revise/pr-body-stale.md")" != "$want" ] || bad "criterion 3: recount does not catch a stale PR body"
"$proto" "$FX/revise/pr-body.md" > /dev/null 2>&1 || bad "criterion 3: revised PR body fails protocol.sh"
"$proto" "$FX/revise/comment.md" > /dev/null 2>&1 || bad "criterion 2: revise comment fails protocol.sh"
awk '$0=="```segoy"{b=1;next} b&&$0=="```"{b=0;next} b' "$FX/revise/comment.md" |
  jq -es 'map(select(.kind=="decision")) | length == 1 and (.[0] | has("idea") and (has("subject") | not))' > /dev/null ||
  bad "criterion 2: revise comment's decision block lacks idea or has subject"

[ "$fail" -eq 0 ] && echo "ok: kit blocks valid ($examples examples), check step in 11 skills, revise fixture consistent"
exit "$fail"
