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

proto=scripts/lib/protocol.sh
pf=tests/fixtures/protocol
check "protocol: valid blocks pass" "$proto" "$pf/valid.md"
check "protocol: examples in docs/protocol.md pass" "$proto" docs/protocol.md
check "protocol: unknown kind only warns" "$proto" "$pf/unknown-kind.md"
check "protocol: blocks read from stdin" sh -c "$proto - < $pf/valid.md"
proto_out=$(mktemp)
check "protocol: invalid blocks fail" expect_fail "$proto_out" "$proto" "$pf/invalid.md"
for msg in "question: bad field idea" "bad field round" "array of 1-3 questions" "missing field: default" \
           "question ids must be unique" "answer: bad field v" "unknown command" "must be <owner>/<repo>" \
           "ISO 8601" "bad field outcome" "not valid JSON" \
           "plan: assumptions[0]: bad field confidence" "never a brain path" "bad field tasks" "bad field size" \
           "bad field omitted_private" '"leak-check": "pass"' "decision: bad field gate" "decision: bad field outcome"; do
  check "protocol reports: $msg" grep -qF "$msg" "$proto_out"
done
check "protocol: unclosed block reported" sh -c "$proto $pf/unclosed.md | grep -q 'block not closed'"
check "protocol: each bad idea reported once" sh -c "[ \$(grep -c 'bad field idea' '$proto_out') -eq 1 ]"
check "protocol: four-backtick examples are skipped" sh -c "$proto $pf/valid.md | grep -q '^6 block'"
rm -f "$proto_out"

check "brain template: structure, frontmatter, labels, config" tests/check-brain-template.sh
check "segoy init brain and doctor (offline)" tests/check-init-doctor.sh
check "strip-private and leak-guard (T2.2, T2.4)" tests/check-leak-guard.sh
check "triage comment templates carry valid blocks" sh -c "grep -v '^\`\`\`\`' kit/brain/.claude/skills/segoy-triage/comment.md | $proto - | grep -q '^2 block'"

printf '\n%d passed, %d failed\n' "$passed" "$failed"
[ "$failed" -eq 0 ]
