#!/bin/sh
# lint-skills.sh — check SKILL.md files against the skill format in CLAUDE.md.
#
# Usage: lint-skills.sh [ROOT...]
#   Finds every SKILL.md under each ROOT (default: kit .claude) and checks:
#   - YAML frontmatter opens on line 1 and closes with ---
#   - `name:` is present, kebab-case, and matches the skill's directory name
#   - `description:` is present and non-empty
#   - the six required `## ` sections are present (a trailing parenthetical,
#     as in "## Preconditions (exit quietly if not met)", is allowed)
#   - the file is at most MAX_LINES lines (warning only)
# Exit status: 0 if all files pass, 1 if any fail, 2 on usage error.

set -u

MAX_LINES=${MAX_LINES:-150}
SECTIONS='Inputs
Preconditions
Procedure
Output contract
Stop conditions and budget
Never'

failures=0
checked=0

fail() {
  printf 'FAIL %s: %s\n' "$1" "$2"
  failures=$((failures + 1))
}

warn() {
  printf 'WARN %s: %s\n' "$1" "$2"
}

# frontmatter FILE — print the frontmatter body (between the first two --- lines).
frontmatter() {
  awk 'NR == 1 { if ($0 != "---") exit; next } $0 == "---" { exit } { print }' "$1"
}

# field FILE KEY — print the value of a top-level frontmatter key.
field() {
  frontmatter "$1" | sed -n "s/^$2:[[:space:]]*//p" | head -n 1
}

lint_file() {
  f=$1
  checked=$((checked + 1))
  before=$failures

  if [ "$(head -n 1 "$f")" != "---" ]; then
    fail "$f" "frontmatter must start on line 1 with ---"
  elif [ "$(awk 'NR > 1 && $0 == "---" { print "y"; exit }' "$f")" != "y" ]; then
    fail "$f" "frontmatter is not closed with ---"
  fi

  name=$(field "$f" name)
  dir=$(basename "$(dirname "$f")")
  if [ -z "$name" ]; then
    fail "$f" "missing name:"
  else
    if ! printf '%s\n' "$name" | grep -Eq '^[a-z0-9]+(-[a-z0-9]+)*$'; then
      fail "$f" "name '$name' is not kebab-case"
    fi
    if [ "$name" != "$dir" ]; then
      fail "$f" "name '$name' does not match directory '$dir'"
    fi
  fi

  if [ -z "$(field "$f" description)" ]; then
    fail "$f" "missing or empty description:"
  fi

  printf '%s\n' "$SECTIONS" | while IFS= read -r s; do
    if ! grep -Eq "^## $s( \(.*\))?[[:space:]]*$" "$f"; then
      printf 'FAIL %s: missing section "## %s"\n' "$f" "$s"
    fi
  done > "$tmp"
  if [ -s "$tmp" ]; then
    cat "$tmp"
    failures=$((failures + $(wc -l < "$tmp")))
  fi

  lines=$(wc -l < "$f")
  if [ "$lines" -gt "$MAX_LINES" ]; then
    warn "$f" "$lines lines (guideline is $MAX_LINES); move templates to sibling files"
  fi

  [ "$failures" -eq "$before" ] && printf 'ok   %s\n' "$f"
}

tmp=$(mktemp) || exit 2
trap 'rm -f "$tmp" "$tmp.list"' EXIT

[ $# -eq 0 ] && set -- kit .claude

for root in "$@"; do
  [ -e "$root" ] || continue
  find "$root" -type f -name SKILL.md
done | sort > "$tmp.list"

while IFS= read -r f; do
  lint_file "$f"
done < "$tmp.list"

printf '%d file(s) checked, %d problem(s)\n' "$checked" "$failures"
[ "$failures" -eq 0 ]
