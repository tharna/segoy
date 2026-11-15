# shellcheck shell=sh
# common.sh — shared helpers for scripts/segoy. Sourced, not executed.
# Requires SEGOY_HOME (the Segoy checkout) to be set by the caller.

say()  { printf '%s\n' "$*"; }
warn() { printf 'WARN %s\n' "$*"; }
die()  { printf 'segoy: %s\n' "$*" >&2; exit 2; }

need() {
  for c in "$@"; do
    command -v "$c" >/dev/null 2>&1 || die "$c is required but not installed"
  done
}

# segoy_version — the version string written into target repos.
segoy_version() {
  v=$(cat "$SEGOY_HOME/VERSION" 2>/dev/null || echo 0.0.0)
  sha=$(git -C "$SEGOY_HOME" rev-parse --short HEAD 2>/dev/null || true)
  if [ -n "$sha" ]; then printf '%s+%s\n' "$v" "$sha"; else printf '%s\n' "$v"; fi
}

# repo_slug DIR — print <owner>/<repo> from DIR's origin remote, or nothing.
# Accepts https://github.com/o/r(.git), git@github.com:o/r(.git), ssh://git@github.com/o/r.
repo_slug() {
  url=$(git -C "$1" remote get-url origin 2>/dev/null) || return 0
  printf '%s\n' "$url" | sed -n \
    -e 's#^https://github\.com/\([^/]*\)/\([^/]*\)$#\1/\2#p' \
    -e 's#^git@github\.com:\([^/]*\)/\([^/]*\)$#\1/\2#p' \
    -e 's#^ssh://git@github\.com/\([^/]*\)/\([^/]*\)$#\1/\2#p' | sed 's#\.git$##'
}

# file_hash FILE — content hash used in manifests (git's blob hash; stable everywhere git is).
file_hash() { git hash-object --no-filters "$1"; }

# config_value DIR KEY — top-level scalar from DIR/.segoy/config.yml (flat `key: value` lines only).
config_value() {
  sed -n "s/^$2:[[:space:]]*\([^#]*\).*/\1/p" "$1/.segoy/config.yml" 2>/dev/null | head -n 1 | sed 's/[[:space:]]*$//'
}
