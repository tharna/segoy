#!/bin/sh
# run.sh — run all Segoy checks. Exit non-zero if any check fails.
set -u
cd "$(dirname "$0")/.." || exit 2

passed=0
failed=0
log=$(mktemp) && bad_out=$(mktemp) || exit 2
trap 'rm -f "$log" "$bad_out"' EXIT

check() {
  desc=$1; shift
  if "$@" > "$log" 2>&1; then
    printf 'pass  %s\n' "$desc"; passed=$((passed + 1))
  else
    printf 'FAIL  %s\n' "$desc"; sed 's/^/      /' "$log"; failed=$((failed + 1))
  fi
}

# expect_fail OUTFILE COMMAND... — succeed if COMMAND fails; keep its output in OUTFILE.
expect_fail() {
  out=$1; shift
  "$@" > "$out" 2>&1 && return 1
  return 0
}

lint=scripts/lib/lint-skills.sh
fx=tests/fixtures/skills

check "linter accepts a well-formed skill" "$lint" "$fx/good"

check "linter rejects a malformed skill" expect_fail "$bad_out" "$lint" "$fx/bad"
for msg in "not kebab-case" "does not match directory" "missing or empty description" \
           'missing section "## Preconditions' 'missing section "## Output contract' \
           'missing section "## Never'; do
  check "linter reports: $msg" grep -qF "$msg" "$bad_out"
done
check "linter does not flag the present Procedure section" sh -c "! grep -qF 'missing section \"## Procedure' '$bad_out'"

check "linter passes on the repo's own skills" "$lint"

printf '\n%d passed, %d failed\n' "$passed" "$failed"
[ "$failed" -eq 0 ]
