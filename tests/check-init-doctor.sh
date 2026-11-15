#!/bin/sh
# check-init-doctor.sh — offline tests for `segoy init brain` and `segoy doctor`.
# Run from the repo root. Prints one line per check; exit 1 if any fails.
set -u
S=scripts/segoy
T=$(mktemp -d) || exit 2
trap 'rm -rf "$T"' EXIT
fail=0
ok()  { echo "pass  $1"; }
bad() { echo "FAIL  $1"; fail=1; }
t()   { d=$1; shift; if "$@" >/dev/null 2>&1; then ok "$d"; else bad "$d"; fi; }
tn()  { d=$1; shift; if "$@" >/dev/null 2>&1; then bad "$d"; else ok "$d"; fi; }

git init -q "$T/b"
t  "init brain --no-github succeeds" $S init brain --no-github "$T/b"
t  "config.yml created from template" test -f "$T/b/.segoy/config.yml"
tn "config template itself not copied" test -e "$T/b/.segoy/config.yml.tmpl"
tn "KIT.md files not copied" sh -c "find '$T/b' -name KIT.md | grep -q ."
tn "{{date}} placeholders replaced" grep -rq '{{date}}' "$T/b/self" "$T/b/ways"
t  "dates filled in" grep -q "^created: $(date -u +%Y-%m-%d)$" "$T/b/self/goals.md"
t  "version written" grep -q '^[0-9]' "$T/b/.segoy/version"
t  "manifest lists every copied file" sh -c "[ \$(jq '.files | length' '$T/b/.segoy/manifest.json') -eq \$(cd '$T/b' && find . -type f ! -path './.git/*' ! -name manifest.json ! -name version | wc -l) ]"
t  "manifest hashes match files" sh -c "cd '$T/b' && jq -r '.files | to_entries[] | \"\(.key) \(.value)\"' .segoy/manifest.json | while read -r p h; do [ \"\$(git hash-object --no-filters \"\$p\")\" = \"\$h\" ] || exit 1; done"

echo "my own goals" >> "$T/b/self/goals.md"
out=$($S init brain --no-github "$T/b" 2>&1)
t  "re-init keeps edited files" grep -q "my own goals" "$T/b/self/goals.md"
t  "re-init reports kept files" sh -c "printf '%s' '$out' | grep -q 'skip   self/goals.md'"
t  "re-init adds nothing" sh -c "printf '%s' '$out' | grep -q '^files: 0 added'"

tn "doctor fails while config has placeholders" $S doctor --offline "$T/b"
t  "doctor names the placeholders" sh -c "$S doctor --offline '$T/b' | grep -q 'placeholders: owner brain_repo'"
sed -i -e 's/^owner: .*/owner: example/' -e 's#^brain_repo: .*#brain_repo: example/brain#' \
       -e 's#^tool_repo: .*#tool_repo: example/segoy#' -e 's/^capture_language: .*/capture_language: en/' "$T/b/.segoy/config.yml"
t  "doctor passes offline once config is filled" $S doctor --offline "$T/b"
t  "doctor reports edited kit files as info" sh -c "$S doctor --offline '$T/b' | grep -q '^info .* edited since init'"
rm "$T/b/CLAUDE.md"
tn "doctor fails without CLAUDE.md" $S doctor --offline "$T/b"

git init -q "$T/noorigin"
tn "init without origin and without --repo is refused" $S init brain "$T/noorigin"
t  "init refusal explains --repo" sh -c "$S init brain '$T/noorigin' 2>&1 | grep -q -- '--repo'"
tn "unknown command fails" $S frobnicate
t  "help works" $S --help
t  "doctor --protocol passes valid blocks" $S doctor --protocol tests/fixtures/protocol/valid.md
tn "doctor --protocol fails invalid blocks" $S doctor --protocol tests/fixtures/protocol/invalid.md
t  "doctor --skills lints the repo" $S doctor --skills .

for u in https://github.com/o/r https://github.com/o/r.git git@github.com:o/r.git ssh://git@github.com/o/r; do
  git -C "$T/noorigin" remote remove origin 2>/dev/null
  git -C "$T/noorigin" remote add origin "$u"
  got=$(SEGOY_HOME=. sh -c '. scripts/lib/common.sh; repo_slug "$1"' _ "$T/noorigin")
  if [ "$got" = o/r ]; then ok "repo slug from $u"; else bad "repo slug from $u (got '$got')"; fi
done

exit $fail
