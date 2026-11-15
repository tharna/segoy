#!/bin/sh
# project-leak-check.sh — run leak-guard.sh with this repo's configured skips.
# Usage: project-leak-check.sh FILE...   (run from the repo root)
# Reads the "- item" lists under leak_skip_rules and leak_exclude in .segoy/config.yml.
set -u
cfg=.segoy/config.yml
list() {
  [ -f "$cfg" ] || return 0
  awk -v k="$1:" '
    $1 == k { on = 1; next }
    on && /^[[:space:]]*- / { sub(/^[[:space:]]*- /, ""); sub(/[[:space:]]+#.*$/, ""); sub(/[[:space:]]+$/, ""); gsub(/^"|"$/, ""); print; next }
    on && /^[^[:space:]#]/ { on = 0 }' "$cfg"
}
[ $# -gt 0 ] || exit 0
n=$#
# Append the options after the files, then rotate the files to the end,
# because leak-guard.sh reads options before file names.
while IFS= read -r r; do [ -n "$r" ] && set -- "$@" --skip "$r"; done <<EOT
$(list leak_skip_rules)
EOT
while IFS= read -r g; do [ -n "$g" ] && set -- "$@" --exclude "$g"; done <<EOT
$(list leak_exclude)
EOT
i=0
while [ "$i" -lt "$n" ]; do
  x=$1; shift; set -- "$@" "$x"; i=$((i + 1))
done
exec .claude/scripts/leak-guard.sh "$@"
