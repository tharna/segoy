#!/bin/sh
# check-brain-template.sh — structural checks on kit/brain (run from repo root).
# Prints one line per problem; exit 1 if any.
set -u
B=kit/brain
fail=0
bad() { echo "FAIL $*"; fail=1; }

for f in CLAUDE.md README.md index.md log.md .segoy/config.yml.tmpl .segoy/denylist.txt \
         .segoy/labels.json .github/ISSUE_TEMPLATE/capture.md ideas/index.md projects/index.md \
         ways/index.md ways/private/index.md decisions/index.md knowledge/wiki/index.md \
         ways/public/principles.md ways/public/stack.md ways/public/conventions.md ways/public/review.md \
         self/profile.md self/goals.md self/values.md self/preferences.md self/constraints.md; do
  [ -f "$B/$f" ] || bad "missing $B/$f"
done
for d in inbox knowledge/raw knowledge/wiki/topics knowledge/wiki/entities knowledge/wiki/syntheses journal; do
  [ -d "$B/$d" ] || bad "missing directory $B/$d"
done

# Frontmatter on every Markdown file except log.md, CLAUDE.md, README.md and issue templates' own format.
find "$B" -name '*.md' ! -name log.md ! -name CLAUDE.md ! -name README.md ! -path '*/ISSUE_TEMPLATE/*' ! -path '*/.claude/*' | while read -r f; do
  [ "$(head -n 1 "$f")" = "---" ] || echo "FAIL no frontmatter: $f"
  grep -q '^visibility: ' "$f" || echo "FAIL no visibility: $f"
done | grep . && fail=1

# self/ is always private.
grep -L '^visibility: private$' "$B"/self/*.md | sed 's/^/FAIL self file not private: /' | grep . && fail=1

# Labels: valid JSON, unique names, colours taken from the design system.
L=$B/.segoy/labels.json
if ! jq -e '.v == 1 and (.labels | length > 0)' "$L" >/dev/null 2>&1; then
  bad "labels.json is not valid"
else
  dup=$(jq -r '[.labels[].name] | group_by(.) | map(select(length > 1) | .[0]) | .[]' "$L")
  [ -z "$dup" ] || bad "duplicate labels: $dup"
  palette=$(jq -r '.color.tokens[].value | if type == "object" then .phosphor else . end | strings | ascii_downcase | ltrimstr("#")' design-system/project/tokens.json)
  for c in $(jq -r '(.labels[], .dynamic[]) | .color' "$L"); do
    printf '%s\n' "$palette" | grep -qx "$c" || bad "label colour $c is not a design-system token"
  done
  for n in answered segoy:paused state:needs-input kind:idea kind:note segoy:spec; do
    jq -e --arg n "$n" 'any(.labels[]; .name == $n)' "$L" >/dev/null || bad "label $n missing"
  done
fi

# Config template has the keys skills read.
for k in owner brain_repo capture_language notes_language keep_original answer_label sweep_interval \
         question_limit_per_round duplicate_action; do
  grep -q "^$k:" "$B/.segoy/config.yml.tmpl" || bad "config template lacks $k"
done

# The template is generic: placeholders only.
if grep -rnE '[A-Za-z0-9._%+-]+@[A-Za-z0-9-]+\.[A-Za-z]{2,}' "$B" | grep -v 'noreply@anthropic.com'; then
  bad "e-mail address in template"
fi

exit $fail
