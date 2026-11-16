#!/bin/sh
# check-brain-lint-script.sh — fixture tests for kit/common/.claude/scripts/brain-lint.sh
# (I-20261116-7, task group T1), run from the repo root.
#   Each fixture brain in tests/fixtures/lint/ is copied to a temporary git repo
#   with one commit dated 2025-12-01, then linted with --today 2026-01-10.
# Prints one line per problem; exit 1 if any.
set -u
L=kit/common/.claude/scripts/brain-lint.sh
F=tests/fixtures/lint
TODAY=2026-01-10
fail=0
bad() { echo "FAIL $*"; fail=1; }

for f in "$L" "$F/clean/index.md" "$F/dirty/index.md" "$F/dirty/expected-report.txt"; do
  [ -e "$f" ] || { bad "missing $f"; exit 1; }
done
lint=$(pwd)/$L

tmp=$(mktemp -d) || exit 1
trap 'rm -rf "$tmp"' EXIT

# copy NAME — fixture brain as a git repo with a fixed commit date.
copy() {
  mkdir -p "$tmp/$1"
  cp -R "$F/$1/." "$tmp/$1/"
  rm -f "$tmp/$1/expected-report.txt"
  (
    cd "$tmp/$1" || exit 1
    git init -q
    git add -A
    GIT_AUTHOR_DATE=2025-12-01T12:00:00Z GIT_COMMITTER_DATE=2025-12-01T12:00:00Z \
      git -c user.name=test -c user.email=test@example.com -c commit.gpgsign=false commit -qm fixture
  ) || bad "cannot create git copy of $1"
}
# has FILE LINE WHAT — FILE contains the exact line LINE.
has() { grep -qxF -- "$2" "$1" || bad "$3: missing line: $2"; }
T=$(printf '\t')

# --- Usage errors -------------------------------------------------------------
sh "$lint" > /dev/null 2>&1; [ $? -eq 2 ] || bad "usage: no args should exit 2"
sh "$lint" --today "$TODAY" "$tmp/nonexistent" > /dev/null 2>&1; [ $? -eq 2 ] || bad "usage: missing dir should exit 2"
sh "$lint" --today 2026-1-1 "$F/clean" > /dev/null 2>&1; [ $? -eq 2 ] || bad "usage: bad --today should exit 2"
sh "$lint" --bogus "$F/clean" > /dev/null 2>&1; [ $? -eq 2 ] || bad "usage: unknown option should exit 2"

# --- Clean brain: no output, exit 0 -------------------------------------------
copy clean
sh "$lint" --today "$TODAY" "$tmp/clean" > "$tmp/clean.out" 2>&1; rc=$?
[ $rc -eq 0 ] || bad "clean: report exit $rc, want 0"
[ -s "$tmp/clean.out" ] && bad "clean: unexpected output: $(head -n 3 "$tmp/clean.out")"
sh "$lint" --today "$TODAY" --fix "$tmp/clean" > "$tmp/clean-fix.out" 2>&1; rc=$?
[ $rc -eq 0 ] || bad "clean: fix exit $rc, want 0"
[ -s "$tmp/clean-fix.out" ] && bad "clean: unexpected fix output"
[ -z "$(git -C "$tmp/clean" status --porcelain)" ] || bad "clean: --fix changed files"

# --- Dirty brain: report ------------------------------------------------------
copy dirty
D=$tmp/dirty
sh "$lint" --today "$TODAY" "$D" > "$tmp/report" 2> "$tmp/report.err"; rc=$?
[ $rc -eq 1 ] || bad "dirty: report exit $rc, want 1"
[ -s "$tmp/report.err" ] && bad "dirty: stderr: $(head -n 3 "$tmp/report.err")"
cmp -s "$tmp/report" "$F/dirty/expected-report.txt" || {
  bad "dirty: report differs from expected-report.txt"
  diff "$F/dirty/expected-report.txt" "$tmp/report" | sed 's/^/  /'
}
[ -z "$(git -C "$D" status --porcelain)" ] || bad "dirty: report mode changed files"
# Each planted problem with the right check.
I1=ideas/I-20251201-1-example-idea-one/idea.md
has "$tmp/report" "orphan${T}knowledge/wiki/topics/example-orphan.md${T}no inbound link" "orphan"
has "$tmp/report" "stale${T}knowledge/wiki/topics/example-stale.md${T}updated 2025-09-12, 120 days ago" "stale"
has "$tmp/report" "frontmatter${T}$I1${T}missing kind (fixable)" "idea missing kind"
has "$tmp/report" "frontmatter${T}$I1${T}missing links (fixable)" "idea missing links"
has "$tmp/report" "frontmatter${T}decisions/D-20251205-1.md${T}missing source" "decision missing source"
has "$tmp/report" "index${T}ideas/index.md${T}row I-20251130-1: no file (fixable)" "row without folder"
has "$tmp/report" "index${T}ideas/index.md${T}I-20251202-1: no row (fixable)" "folder without row"
has "$tmp/report" "index${T}ideas/index.md${T}row I-20251203-1: state \"specced\" differs from file \"planned\" (fixable)" "wrong state"
has "$tmp/report" "frontmatter${T}knowledge/raw/20251201-example-raw-note.md${T}no frontmatter (raw file, not fixed)" "raw file"
has "$tmp/report" "frontmatter${T}self/goals.md${T}missing updated (fixable)" "self missing updated"
grep -q 'example-tool-x' "$tmp/report" && bad "contradiction pages should give no script finding"
grep -q 'SELF-BODY-MARKER' "$tmp/report" && bad "self/ body text in report output"
# Sorted by check, then path.
LC_ALL=C sort -c -t "$T" -k1,1 -k2,2 "$tmp/report" 2> /dev/null || bad "report not sorted by check, then path"

# --- Dirty brain: fix ---------------------------------------------------------
sh "$lint" --today "$TODAY" --fix "$D" > "$tmp/fix" 2> "$tmp/fix.err"; rc=$?
[ $rc -eq 1 ] || bad "dirty: fix exit $rc, want 1 (orphan, stale remain)"
[ -s "$tmp/fix.err" ] && bad "dirty: fix stderr: $(head -n 3 "$tmp/fix.err")"
grep -q 'SELF-BODY-MARKER' "$tmp/fix" && bad "self/ body text in fix output"
grep -q '(fixable)' "$tmp/fix" && bad "fix output still lists a fixable finding"
# Unfixable findings are still printed.
has "$tmp/fix" "orphan${T}knowledge/wiki/topics/example-orphan.md${T}no inbound link" "fix: orphan"
has "$tmp/fix" "stale${T}knowledge/wiki/topics/example-stale.md${T}updated 2025-09-12, 120 days ago" "fix: stale"
has "$tmp/fix" "frontmatter${T}decisions/D-20251205-1.md${T}missing source" "fix: decision missing source"
has "$tmp/fix" "frontmatter${T}knowledge/raw/20251201-example-raw-note.md${T}no frontmatter (raw file, not fixed)" "fix: raw file"
# Applied fixes are printed.
has "$tmp/fix" "fixed${T}$I1${T}added kind: idea" "fix: kind"
has "$tmp/fix" "fixed${T}$I1${T}added links: []" "fix: links"
has "$tmp/fix" "fixed${T}self/goals.md${T}added updated: $TODAY" "fix: self updated"

# Only frontmatter-fixed files and index files changed; nothing under raw/.
git -C "$D" diff --name-only | LC_ALL=C sort > "$tmp/changed"
printf '%s\n' "$I1" ideas/index.md knowledge/wiki/index.md self/goals.md | LC_ALL=C sort > "$tmp/want"
cmp -s "$tmp/changed" "$tmp/want" || bad "fix changed: $(tr '\n' ' ' < "$tmp/changed"), want: $(tr '\n' ' ' < "$tmp/want")"
grep -q '^knowledge/raw/' "$tmp/changed" && bad "fix changed a file under knowledge/raw/"
git -C "$D" status --porcelain --untracked-files=all | grep -qv '^ M ' && bad "fix added or removed files"

# No body line changed: text after the first frontmatter block is identical.
body() { awk 'NR == 1 && $0 == "---" { fm = 1; next } fm && $0 == "---" { fm = 0; next } !fm' ; }
grep -v 'index\.md$' "$tmp/changed" > "$tmp/fm-changed"
while IFS= read -r f; do
  git -C "$D" show "HEAD:$f" | body > "$tmp/before"
  body < "$D/$f" > "$tmp/after"
  cmp -s "$tmp/before" "$tmp/after" || bad "fix changed a body line in $f"
  grep -qx "updated: $TODAY" "$D/$f" || bad "fixed file $f lacks updated: $TODAY"
done < "$tmp/fm-changed"
grep -qx 'kind: idea' "$D/$I1" || bad "idea file did not get kind: idea"
grep -qx 'links: \[\]' "$D/$I1" || bad "idea file did not get links: []"
# Existing frontmatter lines are kept in order (only additions and updated).
git -C "$D" diff -U0 -- "$I1" self/goals.md | grep '^-[^-]' | grep -v '^-updated: ' > "$tmp/removed"
[ -s "$tmp/removed" ] && bad "fix removed frontmatter lines: $(tr '\n' ' ' < "$tmp/removed")"

# Index rows corrected.
grep -q 'I-20251130-1' "$D/ideas/index.md" && bad "row without folder not removed"
has "$D/ideas/index.md" "| [I-20251202-1](I-20251202-1-example-unlisted-idea/idea.md) | Example unlisted idea | needs-input |  | 2025-12-06 |" "new row"
has "$D/ideas/index.md" "| [I-20251203-1](I-20251203-1-example-wrong-state/idea.md) | Example wrong-state idea | planned | example-project | 2025-12-08 |" "wrong state fixed"
has "$D/ideas/index.md" "| [I-20251201-1](I-20251201-1-example-idea-one/idea.md) | Example idea one | triaged | example-project | 2025-12-05 |" "unchanged row kept"
has "$D/knowledge/wiki/index.md" "- [Example orphan](topics/example-orphan.md) (topic)" "wiki index row"
has "$D/knowledge/wiki/index.md" "## Unfiled" "wiki Unfiled heading"
# Orphan and stale pages themselves are untouched.
for f in knowledge/wiki/topics/example-orphan.md knowledge/wiki/topics/example-stale.md \
  knowledge/wiki/entities/example-tool-x.md knowledge/wiki/topics/example-tool-x-storage.md; do
  git -C "$D" diff --quiet -- "$f" || bad "fix changed $f"
done

# --- Second report after fix: only non-fixable findings remain ----------------
sh "$lint" --today "$TODAY" "$D" > "$tmp/after-fix"; rc=$?
[ $rc -eq 1 ] || bad "after fix: report exit $rc, want 1"
grep -q '(fixable)' "$tmp/after-fix" && bad "after fix: fixable findings remain: $(grep '(fixable)' "$tmp/after-fix" | head -n 3)"
awk -F "$T" '$1 == "frontmatter" || $1 == "index"' "$tmp/after-fix" > "$tmp/after-fi"
printf '%s\n' "frontmatter${T}decisions/D-20251205-1.md${T}missing source" \
  "frontmatter${T}knowledge/raw/20251201-example-raw-note.md${T}no frontmatter (raw file, not fixed)" > "$tmp/want-fi"
cmp -s "$tmp/after-fi" "$tmp/want-fi" || bad "after fix: frontmatter/index findings: $(tr '\t\n' '  ' < "$tmp/after-fi")"
has "$tmp/after-fix" "stale${T}knowledge/wiki/topics/example-stale.md${T}updated 2025-09-12, 120 days ago" "after fix: stale"

# --- Lint ---------------------------------------------------------------------
if command -v shellcheck > /dev/null 2>&1; then
  shellcheck -x "$L" tests/check-brain-lint-script.sh || bad "shellcheck"
else
  echo "SKIP shellcheck not installed"
fi

exit "$fail"
