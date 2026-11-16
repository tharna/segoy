#!/bin/sh
# shellcheck disable=SC2016  # backticks in patterns are literal Markdown, not shell.
# check-ingest.sh — checks for the segoy-ingest skill and the brain-ingest task
# (I-20261116-6), run from the repo root.
#   Part 1: each acceptance criterion is stated where the agent reads it.
#   Part 2: the dry run on tests/fixtures/ingest shows the behaviour.
# Prints one line per problem; exit 1 if any.
set -u
S=kit/brain/.claude/skills/segoy-ingest
T=tasks/brain-ingest.md
F=tests/fixtures/ingest
B=$F/brain
D=$F/dry-run
STEM=20260101-example-article-about-checklists
RAW=knowledge/raw/$STEM.md
proto=kit/common/.claude/scripts/protocol.sh
guard=kit/common/.claude/scripts/leak-guard.sh
strip=kit/common/.claude/scripts/strip-private.sh
fail=0
bad() { echo "FAIL $*"; fail=1; }
# has FILE TEXT CRITERION — FILE contains TEXT (fixed string).
has() { grep -qF -- "$2" "$1" || bad "criterion $3: $1 does not say: $2"; }

for f in "$S/SKILL.md" "$S/pages.md" "$S/pr-body.md" "$T"; do
  [ -f "$f" ] || { bad "missing $f"; exit 1; }
done

# --- Part 1: stated in the skill and task -----------------------------------
# 1: task names the skill and the merged-PR trigger; one segoy:knowledge PR per file.
has "$T" "segoy-ingest" 1
has "$T" "Pull request → closed" 1
has "$T" "**Is merged** = true" 1
has "$T" "**no label filter**" 1
has "$S/SKILL.md" 'labelled `segoy:knowledge`' 1
has "$S/SKILL.md" "One PR per raw file" 1
has "$S/SKILL.md" "at most **5 per run**" 1
# 2: raw files are never changed.
has "$S/SKILL.md" 'Never create, edit, move, rename or delete anything under `knowledge/raw/`' 2
has "$S/SKILL.md" 'and nothing under `knowledge/raw/`' 2
# 3: source summary page, Sources citation by path.
has "$S/SKILL.md" 'knowledge/wiki/sources/<stem>.md' 3
has "$S/pages.md" "## Source summary page" 3
has "$S/pages.md" '- [knowledge/raw/<stem>.md](../../raw/<stem>.md)' 3
has "$S/SKILL.md" "cites the raw file by relative link" 3
# 4: update before create, no duplicates.
has "$S/SKILL.md" "**Update before create:**" 4
has "$S/SKILL.md" "Never create a second page on a topic or entity that already has one." 4
# 5: index line and log.md line formats.
has "$S/pages.md" '## Index line: `knowledge/wiki/index.md`' 5
has "$S/pages.md" '<run date> · segoy-ingest · ingest <stem> · <file>, <file>, …' 5
has "$S/SKILL.md" 'append exactly one line to `log.md`' 5
# 6: covered-file precondition.
has "$S/SKILL.md" "A raw file is **covered** when" 6
has "$S/SKILL.md" "Never open a second PR for a covered file." 6
# 7: private parts only inside private blocks.
has "$S/SKILL.md" "every sentence derived from a private part of the source goes inside a private block" 7
has "$S/pages.md" "## Private text" 7
# 8: protocol.sh check, run block last in pr-body.md.
has "$S/SKILL.md" '**Check blocks before posting.**' 8
has "$S/pr-body.md" 'the `run` block is last' 8
last_kind=$(awk '$0 == "```segoy" { getline; print }' "$S/pr-body.md" | tail -n 1)
case $last_kind in *'"kind": "run"'*) ;; *) bad "criterion 8: last block in pr-body.md is not a run block" ;; esac
"$proto" "$S/pr-body.md" > /dev/null || bad "criterion 8: pr-body.md example block fails protocol.sh"
# 9: pause precondition, post nothing.
has "$S/SKILL.md" 'No open issue labelled `segoy:paused`' 9
has "$S/SKILL.md" "stop at once, post nothing, change nothing" 9
# Task: never push to the default branch; note issues do not start ingest.
has "$T" "never to its" 1
has "$S/SKILL.md" "Never start from note issues" 1
[ "$(wc -l < "$S/SKILL.md")" -le 150 ] || bad "SKILL.md is over 150 lines"

# --- Part 2: dry run on the fixture brain -------------------------------------
# 1, 8: the PR body validates, has one block, the run block.
out=$("$proto" "$F/pr-body.md") || bad "criterion 8: dry-run pr-body.md fails protocol.sh"
printf '%s\n' "$out" | grep -q '^1 block' || bad "criterion 8: dry-run pr-body.md should have 1 block"
printf '%s\n' "$out" | sed -n 1p | grep -q ': run$' || bad "criterion 8: dry-run block is not a run block"
grep -qF "open \`Ingest: Example article about checklists ($STEM)\` labelled \`segoy:knowledge\`" "$F/transcript.md" \
  || bad "criterion 1: transcript does not open one segoy:knowledge PR for the file"
jq -e '[.trigger.files[] | select(.status == "added" and (.filename | startswith("knowledge/raw/")))] | length == 1' \
  "$F/github/merged.json" > /dev/null || bad "criterion 1: merged fixture does not add exactly one raw file"

# 2: every changed file is in scope; nothing under knowledge/raw/.
( cd "$D" && find . -type f | sed 's|^\./||' ) | while read -r p; do
  case $p in
    knowledge/raw/*) echo "FAIL criterion 2: dry run changed $p" ;;
    knowledge/wiki/*|log.md) ;;
    *) echo "FAIL criterion 2: out-of-scope file in dry run: $p" ;;
  esac
done | grep . && fail=1

# 3: source page exists; every changed page links the raw path and lists it in links.
[ -f "$D/knowledge/wiki/sources/$STEM.md" ] || bad "criterion 3: no source summary page"
for f in $(cd "$D" && find knowledge/wiki -name '*.md' ! -name index.md); do
  [ "$(head -n 1 "$D/$f")" = "---" ] || bad "criterion 3: no frontmatter: $f"
  for k in id title kind visibility created updated source links; do
    grep -q "^$k: " "$D/$f" || bad "criterion 3: $f lacks $k"
  done
  grep -qF "](../../raw/$STEM.md)" "$D/$f" || bad "criterion 3: $f does not cite the raw file by relative link"
  grep -q "^links: .*$RAW" "$D/$f" || bad "criterion 3: $f does not list the raw path in links"
done

# 4: the existing topic page is updated in place; no second page with its title.
T0=knowledge/wiki/topics/checklists.md
[ -f "$D/$T0" ] || bad "criterion 4: existing topic page not updated"
cmp -s "$B/$T0" "$D/$T0" && bad "criterion 4: existing topic page unchanged"
grep -q '^id: topic-checklists$' "$D/$T0" || bad "criterion 4: topic page lost its id"
grep -q '^created: 2025-12-01$' "$D/$T0" || bad "criterion 4: topic page lost its created date"
[ "$(grep -rlx 'title: Checklists' "$D/knowledge/wiki" | wc -l)" -eq 1 ] || bad "criterion 4: a second page titled Checklists"

# 5: every new page is in index.md; log.md gained exactly one line in the right form.
for f in $(cd "$D/knowledge/wiki" && find . -name '*.md' ! -name index.md | sed 's|^\./||'); do
  [ -f "$B/knowledge/wiki/$f" ] && continue
  grep -qF "]($f) (" "$D/knowledge/wiki/index.md" || bad "criterion 5: new page $f not in index.md"
done
base_lines=$(wc -l < "$B/log.md")
head -n "$base_lines" "$D/log.md" | cmp -s - "$B/log.md" || bad "criterion 5: log.md was not appended to"
[ "$(wc -l < "$D/log.md")" -eq $((base_lines + 1)) ] || bad "criterion 5: log.md did not gain exactly one line"
tail -n 1 "$D/log.md" | grep -qE "^[0-9]{4}-[0-9]{2}-[0-9]{2} · segoy-ingest · ingest $STEM · knowledge/wiki/" \
  || bad "criterion 5: log.md line not in the date · actor · operation · files form"

# 6: the covered file got no output; the open PR covers it.
jq -e '[.pulls[] | select(.state == "open" and (.labels | index("segoy:knowledge")) and (.title | endswith("(20251220-example-covered-note)")))] | length == 1' \
  "$F/github/run-now.json" > /dev/null || bad "criterion 6: run-now fixture lacks the covering PR"
grep -rq '20251220-example-covered-note' "$D" "$F/pr-body.md" && bad "criterion 6: dry run touched the covered file"
grep -q 'Run D: ' "$F/transcript.md" || bad "criterion 6: transcript has no Run now run"

# 7: the private marker phrase survives only inside private blocks.
grep -q 'household budget' "$B/$RAW" || bad "criterion 7: fixture raw file lacks the marker phrase"
for f in $(cd "$D" && find knowledge/wiki -name '*.md'); do
  "$strip" "$D/$f" 2>/dev/null | grep -q 'household budget' && bad "criterion 7: private text outside a private block in $f"
done
grep -rq 'household budget' "$D/knowledge/wiki" || bad "criterion 7: dry run lost the private part instead of keeping it in a block"
grep -q 'household budget' "$F/pr-body.md" && bad "criterion 7: PR body quotes private text"
"$strip" "$D/$T0" 2>/dev/null | "$guard" --denylist kit/brain/.segoy/denylist.txt - > /dev/null \
  || bad "criterion 7: leak-guard finds something in the shareable page after stripping"

# 9: paused fixture stops at once; transcript records no output.
jq -e '[.issues[] | select(.state == "open" and (.labels | index("segoy:paused")))] | length == 1' "$F/github/paused.json" > /dev/null \
  || bad "criterion 9: paused fixture has no open segoy:paused issue"
grep -q 'Files changed: none. Comments posted: none. PR: none.' "$F/transcript.md" || bad "criterion 9: transcript run A"
# Quiet exit when the merged PR added no raw file.
jq -e '[.trigger.files[] | select(.filename | startswith("knowledge/raw/"))] | length == 0' "$F/github/no-raw.json" > /dev/null \
  || bad "no-raw fixture adds a raw file"
grep -q 'added no file under `knowledge/raw/` → exit quietly' "$F/transcript.md" || bad "transcript run B"
grep -q 'no push, no PR opened, no merge, no approval' "$F/transcript.md" || bad "transcript: run C pushed or merged"

exit "$fail"
