#!/bin/sh
# check-init-project.sh — offline tests for `segoy init project`, the project
# leak-check wrapper and the commit hook. Run from the repo root.
set -u
S=scripts/segoy
T=$(mktemp -d) || exit 2
trap 'rm -rf "$T"' EXIT
fail=0
ok()  { echo "pass  $1"; }
bad() { echo "FAIL  $1"; fail=1; }
t()   { d=$1; shift; if "$@" >/dev/null 2>&1; then ok "$d"; else bad "$d"; fi; }
tn()  { d=$1; shift; if "$@" >/dev/null 2>&1; then bad "$d"; else ok "$d"; fi; }

# Public ways as a brain would hold them (frontmatter + rules).
mkdir -p "$T/ways"
printf -- '---\ntitle: Principles\nvisibility: shareable\n---\n# Principles\n\n- Keep PRs small. (source: owner-stated, 2026-01-01)\n' > "$T/ways/principles.md"
printf -- '---\ntitle: Stack\nvisibility: shareable\n---\n# Stack\n\n- Prefer POSIX shell. (source: owner-stated, 2026-01-01)\n' > "$T/ways/stack.md"

git init -q "$T/p"
t  "init project --no-github succeeds" $S init project --no-github --ways "$T/ways" "$T/p"
t  "CLAUDE.md generated" test -f "$T/p/CLAUDE.md"
tn "CLAUDE.md template not copied" test -e "$T/p/CLAUDE.md.tmpl"
t  "ways rules included" grep -q "Keep PRs small" "$T/p/CLAUDE.md"
t  "second ways file included" grep -q "Prefer POSIX shell" "$T/p/CLAUDE.md"
tn "ways frontmatter stripped" grep -q "^visibility: shareable" "$T/p/CLAUDE.md"
tn "no placeholders left in CLAUDE.md" grep -qE "\{\{(ways|repo|date)\}\}" "$T/p/CLAUDE.md"
t  "repo name filled" grep -q "^# p$" "$T/p/CLAUDE.md"
t  "project labels copied" jq -e 'any(.labels[]; .name == "segoy:impl")' "$T/p/.segoy/labels.json"
tn "brain files not copied" test -e "$T/p/self/goals.md"
t  "hook installed and executable" test -x "$T/p/.claude/hooks/leak-check-commit.sh"
t  "kit/common scripts installed" test -x "$T/p/.claude/scripts/leak-guard.sh"
t  "leak-check workflow installed" test -f "$T/p/.github/workflows/segoy-leak-check.yml"
t  "docs/specs and docs/retros exist" test -d "$T/p/docs/specs" -a -d "$T/p/docs/retros"
t  "manifest says kit project" sh -c "jq -e '.kit == \"project\"' '$T/p/.segoy/manifest.json'"

tn "doctor fails while project config has placeholders" $S doctor --offline "$T/p"
sed -e 's/^owner: .*/owner: example/' -e 's#^project_repo: .*#project_repo: example/p#' "$T/p/.segoy/config.yml" > "$T/c" && cat "$T/c" > "$T/p/.segoy/config.yml"
t  "doctor passes a filled project config offline" $S doctor --offline "$T/p"

# Existing CLAUDE.md is kept.
git init -q "$T/q"; printf '# my own\n' > "$T/q/CLAUDE.md"
out=$($S init project --no-github --ways "$T/ways" "$T/q" 2>&1)
t  "existing CLAUDE.md kept" grep -qx "# my own" "$T/q/CLAUDE.md"
t  "init says how to add the Segoy sections" sh -c "printf '%s' '$out' | grep -q 'CLAUDE.md exists and was kept'"

# Ways that leak are refused.
mkdir -p "$T/badways"; mail="owner""@""realmail"".fi"
printf -- '# Review\n\n- Ask %s before merging.\n' "$mail" > "$T/badways/review.md"
git init -q "$T/r"
tn "init fails when ways leak" $S init project --no-github --ways "$T/badways" "$T/r"
tn "leaking CLAUDE.md not written" test -e "$T/r/CLAUDE.md"
printf 'Zyxwvut\n' > "$T/deny.txt"; printf -- '- Built for Zyxwvut.\n' > "$T/ways/extra.md"
git init -q "$T/s"
tn "init fails when ways hit the brain denylist" $S init project --no-github --ways "$T/ways" --denylist "$T/deny.txt" "$T/s"
rm "$T/ways/extra.md"

# Commit hook: blocks a leaking staged file, allows a clean one.
cd "$T/p" || exit 2
git config user.email noreply@example.com; git config user.name test
hook='{"tool_input":{"command":"git commit -m x"}}'
printf 'clean text\n' > ok.md; git add ok.md
if printf '%s' "$hook" | .claude/hooks/leak-check-commit.sh >/dev/null 2>&1; then ok "hook allows a clean commit"; else bad "hook allows a clean commit"; fi
printf 'reach me at %s\n' "$mail" > leak.md; git add leak.md
printf '%s' "$hook" | .claude/hooks/leak-check-commit.sh >/dev/null 2>&1; rc=$?
if [ "$rc" -eq 2 ]; then ok "hook blocks a leaking commit (exit 2)"; else bad "hook blocks a leaking commit (got $rc)"; fi
if printf '{"tool_input":{"command":"ls"}}' | .claude/hooks/leak-check-commit.sh >/dev/null 2>&1; then ok "hook ignores other commands"; else bad "hook ignores other commands"; fi
printf 'leak_exclude:\n  - "leak.md"   # a trailing comment must not break the entry\n' >> .segoy/config.yml
if printf '%s' "$hook" | .claude/hooks/leak-check-commit.sh >/dev/null 2>&1; then ok "hook honours leak_exclude from config"; else bad "hook honours leak_exclude from config"; fi
exit $fail
