#!/bin/sh
# strip-private.sh — remove private blocks from a Markdown file.
#
# Usage: strip-private.sh FILE   (- for stdin)   → cleaned text on stdout
#
# Removes everything from <!-- private --> to <!-- /private -->, inclusive,  (leak-guard: allow)
# whether on one line or across lines. Prints "removed <n> private block(s)"
# on stderr so the caller can report "N private items omitted".
# Exit status: 0 ok, 1 unbalanced markers (nothing is printed then),
# 2 usage error.

set -u
[ $# -eq 1 ] || { echo "usage: strip-private.sh FILE" >&2; exit 2; }
src=$1
[ "$src" = - ] && src=/dev/stdin
[ "$src" = /dev/stdin ] || [ -r "$src" ] || { echo "strip-private: cannot read $1" >&2; exit 2; }

out=$(mktemp) || exit 2
trap 'rm -f "$out"' EXIT

awk '
  BEGIN { open_re = "<!--[ \t]*private[ \t]*-->"; close_re = "<!--[ \t]*/private[ \t]*-->"; depth = 0; n = 0 }
  {
    line = $0; kept = ""
    while (length(line) > 0) {
      if (depth == 0) {
        if (match(line, open_re)) {
          kept = kept substr(line, 1, RSTART - 1)
          line = substr(line, RSTART + RLENGTH); depth = 1; n++
        } else {
          if (match(line, close_re)) { bad = 1 }
          kept = kept line; line = ""
        }
      } else {
        if (match(line, close_re)) {
          line = substr(line, RSTART + RLENGTH); depth = 0
        } else if (match(line, open_re)) {
          bad = 1; line = ""
        } else { line = "" }
      }
    }
    # Drop lines that only held markers or private text; keep real blank lines.
    if (depth == 1 && kept ~ /^[ \t]*$/) next
    if ($0 ~ open_re || $0 ~ close_re) { if (kept ~ /^[ \t]*$/) next }
    print kept
  }
  END { if (depth != 0) bad = 1; print n > "/dev/stderr"; exit bad ? 1 : 0 }
' "$src" > "$out" 2>"$out.n"
rc=$?
n=$(cat "$out.n" 2>/dev/null || echo 0)
rm -f "$out.n"
if [ "$rc" -ne 0 ]; then
  echo "strip-private: unbalanced private markers in $1; nothing written" >&2
  exit 1
fi
cat "$out"
echo "removed $n private block(s)" >&2
