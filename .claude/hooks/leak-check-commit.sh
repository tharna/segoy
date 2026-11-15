#!/bin/sh
# leak-check-commit.sh — PreToolUse hook: before a `git commit` in a single-repo
# session, run the project leak check on the staged files. Exit 2 blocks the commit.
input=$(cat)
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // ""' 2>/dev/null)
case $cmd in
  *"git commit"*) ;;
  *) exit 0 ;;
esac
root=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
cd "$root" || exit 0
files=$(git diff --cached --name-only --diff-filter=AM)
[ -n "$files" ] || exit 0
# shellcheck disable=SC2086  # one path per word is intended
if ! out=$(.claude/scripts/project-leak-check.sh $files 2>&1); then
  printf 'Segoy leak check blocked this commit:\n%s\n' "$out" >&2
  exit 2
fi
exit 0
