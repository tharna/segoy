#!/bin/sh
# shellcheck disable=SC2016  # backticks in patterns are literal Markdown, not shell.
# check-weekly-review.sh — checks for the segoy-weekly-review skill and the
# brain-weekly-review task (I-20261116-2), and the ways proposal format
# without a proposed marker plus leftover-marker cleanup (I-20261116-3, "P3"),
# run from the repo root.
#   Part 1: each acceptance criterion is stated where the agent reads it.
#   Part 2: the dry run on tests/fixtures/weekly-review shows the behaviour.
# Prints one line per problem; exit 1 if any.
set -u
S=kit/brain/.claude/skills/segoy-weekly-review
T=tasks/brain-weekly-review.md
F=tests/fixtures/weekly-review
D=$F/dry-run
proto=kit/common/.claude/scripts/protocol.sh
guard=kit/common/.claude/scripts/leak-guard.sh
fail=0
bad() { echo "FAIL $*"; fail=1; }
# has FILE TEXT CRITERION — FILE contains TEXT (fixed string).
has() { grep -qF -- "$2" "$1" || bad "criterion $3: $1 does not say: $2"; }

for f in "$S/SKILL.md" "$S/digest.md" "$S/records.md" "$S/pr-body.md" "$T"; do
  [ -f "$f" ] || { bad "missing $f"; exit 1; }
done

# --- Part 1: stated in the skill and task -----------------------------------
# 1: task names the skill and the schedule.
has "$T" "segoy-weekly-review" 1
has "$T" "Sunday 18:00" 1
has "$T" "Europe/Helsinki" 1
# 2: pause precondition, nothing posted or changed.
has "$S/SKILL.md" 'No open issue labelled `segoy:paused`' 2
has "$S/SKILL.md" "post nothing, change nothing" 2
# 3: one PR labelled segoy:review, run block last, scope listed.
has "$S/SKILL.md" 'labelled `segoy:review`' 3
has "$S/SKILL.md" "The PR changes only:" 3
has "$S/pr-body.md" "the \`run\` block is last" 3
last_kind=$(awk '$0 == "```segoy" { getline; print }' "$S/pr-body.md" | tail -n 1)
case $last_kind in *'"kind": "run"'*) ;; *) bad "criterion 3: last block in pr-body.md is not a run block" ;; esac
# 4: empty week opens nothing.
has "$S/SKILL.md" "**Empty week:**" 4
has "$S/SKILL.md" "open no PR, post no comment, even if ideas are stuck" 4
has "$S/SKILL.md" "and one for the digest" 5
# 5: records with frontmatter and source, and log.md lines.
has "$S/records.md" "source: <comment URL>" 5
has "$S/records.md" "source: <issue URL>" 5
has "$S/records.md" "gate: <triage|spec|plan|impl|other>" 5
has "$S/SKILL.md" 'append one `log.md` line per filed note, decision record, stub' 5
# 6: never knowledge/wiki.
has "$S/SKILL.md" 'never create or change anything under `knowledge/wiki/`' 6
has "$S/SKILL.md" 'Never create or change files under `knowledge/wiki/`' 6
# 7: drift corrected and listed.
has "$S/SKILL.md" "Issue labels are the source of truth" 7
has "$S/digest.md" "## State corrections" 7
# 8: stuck ideas over 14 days with current state.
has "$S/SKILL.md" "more than **14 days**" 8
has "$S/digest.md" '`<current state>` for <n> days' 8
# 9: cited source, no silent rewrite (marker dropped by I-20261116-3).
has "$S/records.md" "- <Imperative, checkable rule.> (source: <link, D-… or retro path>, <run date>)" 9
has "$S/SKILL.md" "never edit or delete a rule silently" 9
has "$S/SKILL.md" "without a visible replacement bullet in the same diff" 9
# P3 1–7: one wording, verbatim, in skill, task and workflows.
W=docs/workflows.md
P3A='Write each proposal as a final `ways/` bullet with its cited source and no `proposed` marker; merging the review PR accepts it. List each one as a proposal in the PR body and the digest.'
P3B='Remove a leftover `(proposed; ` marker from `ways/` bullets already on the default branch, keep the rest of the bullet, and list each one in the digest.'
for f in "$S/SKILL.md" "$T" "$W"; do
  has "$f" "$P3A" "P3 1,2,7"
  has "$f" "$P3B" "P3 3,4,7"
  grep -qF 'marked `proposed`' "$f" && bad "criterion P3 7: $f still says marked \`proposed\`"
done
grep '(proposed; source' "$S/records.md" | grep -qv '^-- <rule> (proposed; source' \
  && bad "criterion P3 1: records.md proposal format still has the marker"
# P3 2, 4: templates label proposals and list cleaned markers.
has "$S/digest.md" "- p1 (proposal) → " "P3 2"
has "$S/pr-body.md" "- p1 (proposal) → " "P3 2"
has "$S/digest.md" "## Markers removed" "P3 4"
has "$S/digest.md" '- `<ways/ file>`: <bullet text after cleanup>' "P3 4"
# P3 3, 5, 6: exact match, read before this run's edits, decisions untouched.
has "$S/SKILL.md" 'match only the exact `(proposed; ` opening and rewrite it to `(`' "P3 3"
has "$S/SKILL.md" "before any edit of this run" "P3 3"
has "$S/SKILL.md" 'Never touch `decisions/`' "P3 5"
has "$S/records.md" '(proposed)"; omit the section if none' "P3 5"
has "$S/SKILL.md" 'no leftover `ways/` marker (step 9 cleanup)' "P3 6"
has "$S/SKILL.md" 'No leftover marker: no cleanup edit, no `clean marker` log line, no "Markers removed" section.' "P3 6"
# 10: leak check on shareable parts, self/ untouched.
has "$S/SKILL.md" ".claude/scripts/leak-guard.sh --denylist .segoy/denylist.txt" 10
has "$S/SKILL.md" 'Never read, quote or write `self/`' 10
# 11: never merge, approve, push to default branch.
has "$S/SKILL.md" "Never merge, approve or close a PR, and never push to the default branch" 11
has "$T" "never to its default branch" 11

# Templates carry valid blocks.
"$proto" "$S/pr-body.md" > /dev/null || bad "criterion 3: pr-body.md example blocks fail protocol.sh"
[ "$(wc -l < "$S/SKILL.md")" -le 150 ] || bad "SKILL.md is over 150 lines"

# --- Part 2: dry run on the fixture brain -------------------------------------
# 3: the PR body validates, has review then run (last), closes the note.
out=$("$proto" "$F/pr-body.md") || bad "criterion 3: dry-run pr-body.md fails protocol.sh"
printf '%s\n' "$out" | grep -q '^2 block' || bad "criterion 3: dry-run pr-body.md should have 2 blocks"
printf '%s\n' "$out" | sed -n 2p | grep -q ': run$' || bad "criterion 3: dry-run run block is not last"
grep -q '^Closes #12$' "$F/pr-body.md" || bad "criterion 3: dry-run body does not close the note"

# 3: every changed file is in scope.
( cd "$D" && find . -type f | sed 's|^\./||' ) | while read -r p; do
  case $p in
    knowledge/raw/*|decisions/D-*.md|decisions/index.md|ideas/*/idea.md|ideas/*/spec.md|ideas/*/plan.md|\
    ideas/index.md|ways/*|log.md|journal/[0-9][0-9][0-9][0-9]-W[0-9][0-9].md) ;;
    *) echo "FAIL criterion 3: out-of-scope file in dry run: $p" ;;
  esac
done | grep . && fail=1
# 6: nothing under knowledge/wiki/, and self/ untouched (10).
[ -e "$D/knowledge/wiki" ] && bad "criterion 6: dry run changed knowledge/wiki/"
[ -e "$D/self" ] && bad "criterion 10: dry run wrote self/"

# 5: new records have full frontmatter with a source link, and log.md lines.
for f in "$D/decisions/D-20251230-1.md" "$D/ideas/I-20251220-1-example-parked-idea/idea.md" \
         "$D/knowledge/raw/20260102-example-article-about-checklists.md"; do
  [ -f "$f" ] || { bad "criterion 5: missing $f"; continue; }
  [ "$(head -n 1 "$f")" = "---" ] || bad "criterion 5: no frontmatter: $f"
  for k in id title kind visibility created updated links; do
    grep -q "^$k: " "$f" || bad "criterion 5: $f lacks $k"
  done
  grep -q '^source: https://' "$f" || bad "criterion 5: $f has no source link"
done
for k in gate subject outcome; do
  grep -q "^$k: " "$D/decisions/D-20251230-1.md" || bad "criterion 5: decision record lacks $k"
done
grep -q '^state: parked$' "$D/ideas/I-20251220-1-example-parked-idea/idea.md" || bad "criterion 5: stub not parked"
base_lines=$(wc -l < "$F/brain/log.md")
head -n "$base_lines" "$D/log.md" | cmp -s - "$F/brain/log.md" || bad "criterion 5: log.md was not appended to"
for op in "file note" "record decision" "stub idea" "fix state" "propose way"; do
  grep -q "· segoy-weekly-review · $op · " "$D/log.md" || bad "criterion 5: no log.md line: $op"
done

# 7: drifted state fixed in file and index, and listed.
grep -q '^state: planned$' "$D/ideas/I-20251201-2-example-drifted-idea/idea.md" || bad "criterion 7: state not fixed"
grep -q '| Example drifted idea | planned |' "$D/ideas/index.md" || bad "criterion 7: index not fixed"
grep -q 'I-20251201-2: file said `specced`, issue label says `planned`' "$D/journal/2026-W01.md" || bad "criterion 7: fix not listed"
# 8: stuck idea listed with its state.
grep -q 'I-20251201-1 .*`needs-input` for 20 days' "$D/journal/2026-W01.md" || bad "criterion 8: stuck idea not listed"
# 9, P3 1: the proposal is a new bullet with a source and no proposed marker.
wr=$(diff "$F/brain/ways/public/principles.md" "$D/ways/public/principles.md" | grep '^[<>]')
p1="- Name the exact test command in every plan's task-group checks. (source: example/project docs/retros/I-20251210-1-example.md, 2026-01-04)"
printf '%s\n' "$wr" | grep -qxF "> $p1" || bad "criterion 9: no proposal bullet with a source in the dry run"
printf '%s\n' "$wr" | grep '^>' | grep -q 'proposed' && bad "criterion P3 1: a new or changed ways bullet says proposed"
# P3 2: the proposal is listed and labelled in PR body and digest.
grep -qF -- "- p1 (proposal) → \`ways/public/principles.md\`: Name the exact test command" "$F/pr-body.md" || bad "criterion P3 2: PR body does not list p1 as a proposal"
grep -qF -- "- p1 (proposal) → \`ways/public/principles.md\`: Name the exact test command" "$D/journal/2026-W01.md" || bad "criterion P3 2: digest does not list p1 as a proposal"
# P3 3: exactly one existing bullet changed, and only by dropping "proposed; ".
old=$(printf '%s\n' "$wr" | sed -n 's/^< //p')
[ "$(printf '%s\n' "$wr" | grep -c '^<')" -eq 1 ] || bad "criterion P3 3: expected exactly one changed existing bullet"
case $old in *'(proposed; '*) ;; *) bad "criterion P3 3: the changed bullet had no (proposed; marker" ;; esac
cleaned=$(printf '%s\n' "$old" | sed 's/(proposed; /(/')
printf '%s\n' "$wr" | grep -qxF "> $cleaned" || bad "criterion P3 3: cleaned bullet differs by more than the marker"
# P3 4: digest lists the cleaned bullet with its file.
grep -qF "## Markers removed" "$D/journal/2026-W01.md" || bad "criterion P3 4: digest has no Markers removed section"
grep -qxF -- "- \`ways/public/principles.md\`: ${cleaned#- }" "$D/journal/2026-W01.md" || bad "criterion P3 4: digest does not list the cleaned bullet"
grep -q '· segoy-weekly-review · clean marker · ways/public/principles.md$' "$D/log.md" || bad "criterion P3 4: no clean marker log line"
# P3 5: the decision record with a (proposed) generalisation is unchanged.
grep -q '(proposed)$' "$F/brain/decisions/D-20251215-1.md" || bad "criterion P3 5: fixture record lacks a (proposed) generalisation"
[ ! -e "$D/decisions/D-20251215-1.md" ] || cmp -s "$F/brain/decisions/D-20251215-1.md" "$D/decisions/D-20251215-1.md" \
  || bad "criterion P3 5: dry run changed the decision record"
# P3 6: without a leftover marker, no cleanup edit and no cleanup digest entry.
N=$F/no-marker
grep -q 'proposed' "$N/brain/ways/public/principles.md" && bad "criterion P3 6: no-marker fixture has a marker"
diff "$N/brain/ways/public/principles.md" "$N/dry-run/ways/public/principles.md" | grep -q '^<' && bad "criterion P3 6: no-marker run changed an existing bullet"
diff "$N/brain/ways/public/principles.md" "$N/dry-run/ways/public/principles.md" | grep -qxF "> $p1" || bad "criterion P3 6: no-marker run lost the proposal"
grep -q 'Markers removed' "$N/dry-run/journal/2026-W01.md" && bad "criterion P3 6: no-marker digest has a Markers removed section"
grep -q 'Run D: ' "$F/transcript.md" || bad "criterion P3 6: transcript has no run D"
# 10: shareable output passes the leak check.
"$guard" --denylist kit/brain/.segoy/denylist.txt "$D/ways/public/principles.md" "$F/pr-body.md" > /dev/null \
  || bad "criterion 10: leak-guard finds something in the dry run"
# 2, 4: paused and empty fixtures exist and say so; transcript records no output.
jq -e '[.issues[] | select(.state == "open" and (.labels | index("segoy:paused")))] | length == 1' "$F/github/paused.json" > /dev/null \
  || bad "criterion 2: paused fixture has no open segoy:paused issue"
jq -e '[.issues[] | select(.labels | index("kind:note"))] | length == 0' "$F/github/empty.json" > /dev/null \
  || bad "criterion 4: empty fixture has a note"
grep -q 'Files changed: none. Comments posted: none. PR: none.' "$F/transcript.md" || bad "criterion 2: transcript run A"
jq -e '[.issues[].label_events[] | select(.created_at >= "2025-12-28T16:00:00Z")] | length == 0' "$F/github/empty.json" > /dev/null \
  || bad "criterion 4: empty fixture has activity in the period"
grep -q 'empty week → no branch, no PR, no comment' "$F/transcript.md" || bad "criterion 4: transcript run B"
# 11: transcript records nothing pushed or merged.
grep -q 'no push, no PR opened, no merge, no approval' "$F/transcript.md" || bad "criterion 11: transcript"

exit "$fail"
