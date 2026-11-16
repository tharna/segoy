#!/bin/sh
# check-sync.sh — offline tests for `segoy sync` (T4.1). Run from the repo root.
# Works on a copy of Segoy so the kit can be changed between syncs.
set -u
T=$(mktemp -d) || exit 2
trap 'rm -rf "$T"' EXIT
fail=0
ok()  { echo "pass  $1"; }
bad() { echo "FAIL  $1"; fail=1; }
t()   { d=$1; shift; if "$@" >/dev/null 2>&1; then ok "$d"; else bad "$d"; fi; }
tn()  { d=$1; shift; if "$@" >/dev/null 2>&1; then bad "$d"; else ok "$d"; fi; }
# shellcheck disable=SC2329  # used through t/tn
has() { grep -qF -- "$2" "$1"; }

mkdir -p "$T/segoy"
cp -R scripts kit VERSION "$T/segoy/"
S=$T/segoy/scripts/segoy
K=$T/segoy/kit
P=$T/p
B=$T/b
git init -q "$P"
git init -q "$B"
"$S" init project --no-github "$P" >/dev/null 2>&1 || bad "init project"
"$S" init brain --no-github "$B" >/dev/null 2>&1 || bad "init brain"

# Fresh repos are up to date.
"$S" sync --no-github "$P" > "$T/out" 2>&1
t  "fresh project: sync succeeds" test $? -eq 0
t  "fresh project: up to date" has "$T/out" "up to date"

# 1. Kit file changed, target untouched -> updated.
printf '\n- extra rule\n' >> "$K/project/.claude/skills/segoy-retro/SKILL.md"
"$S" sync --dry-run --no-github "$P" > "$T/out" 2>&1
t  "dry run reports the update" has "$T/out" "update    .claude/skills/segoy-retro/SKILL.md"
tn "dry run writes nothing" has "$P/.claude/skills/segoy-retro/SKILL.md" "extra rule"
"$S" sync --no-github "$P" > "$T/out" 2>&1
t  "update applied" has "$P/.claude/skills/segoy-retro/SKILL.md" "extra rule"
t  "manifest records the new hash" sh -c "[ \"\$(jq -r '.files[\".claude/skills/segoy-retro/SKILL.md\"]' '$P/.segoy/manifest.json')\" = \"\$(git hash-object '$P/.claude/skills/segoy-retro/SKILL.md')\" ]"
t  "version file written" test -s "$P/.segoy/version"
"$S" sync --no-github "$P" > "$T/out" 2>&1
t  "second run: up to date (idempotent)" has "$T/out" "up to date"

# 1b. Target holds an older committed kit version, manifest hash stale -> update, not conflict.
git -C "$T/segoy" init -q && git -C "$T/segoy" add -A && git -C "$T/segoy" -c user.name=t -c user.email=t@example.invalid commit -qm v1
cp "$K/project/.claude/agents/implementer.md" "$P/.claude/agents/implementer.md"
jq '.files[".claude/agents/implementer.md"] = "0000000000000000000000000000000000000000"' "$P/.segoy/manifest.json" > "$T/m" && cat "$T/m" > "$P/.segoy/manifest.json"
printf '\n- newer kit line\n' >> "$K/project/.claude/agents/implementer.md"
"$S" sync --no-github "$P" > "$T/out" 2>&1
t  "old kit version with stale manifest: updated" has "$T/out" "update    .claude/agents/implementer.md"
t  "old kit version replaced" has "$P/.claude/agents/implementer.md" "newer kit line"

# 2. Target changed a managed file, kit changed it too -> conflict, local kept.
printf '{"local": true}\n' > "$P/.claude/settings.json"
printf '{"kit": 2}\n' > "$K/project/.claude/settings.json"
"$S" sync --no-github "$P" > "$T/out" 2>&1
t  "conflict reported" has "$T/out" "conflict  .claude/settings.json"
t  "local change kept" has "$P/.claude/settings.json" '"local"'
t  "new version written beside it" has "$P/.claude/settings.json.segoy-new" '"kit": 2'
"$S" sync --no-github "$P" > "$T/out" 2>&1
t  "unresolved conflict shown as pending" has "$T/out" "pending   .claude/settings.json"

# 3. New kit file -> added with its mode.
printf '#!/bin/sh\necho hi\n' > "$K/common/.claude/scripts/new-tool.sh"; chmod +x "$K/common/.claude/scripts/new-tool.sh"
"$S" sync --no-github "$P" > "$T/out" 2>&1
t  "new file added" has "$T/out" "add       .claude/scripts/new-tool.sh"
t  "new script executable" test -x "$P/.claude/scripts/new-tool.sh"

# 4. Kit file removed -> orphan reported, never deleted.
rm "$K/common/.claude/scripts/new-tool.sh"
"$S" sync --no-github "$P" > "$T/out" 2>&1
t  "orphan reported" has "$T/out" "orphan    .claude/scripts/new-tool.sh"
t  "orphan kept" test -f "$P/.claude/scripts/new-tool.sh"

# 5. Managed file deleted in the target -> restored.
rm "$P/.claude/agents/verifier.md"
"$S" sync --no-github "$P" > "$T/out" 2>&1
t  "deleted managed file restored" has "$T/out" "restore   .claude/agents/verifier.md"
t  "restored file present" test -f "$P/.claude/agents/verifier.md"

# 6. Repo-owned files are never touched.
cp "$P/CLAUDE.md" "$T/claude.before"; cp "$P/.segoy/config.yml" "$T/config.before"
printf '\nkit change\n' >> "$K/project/CLAUDE.md.tmpl"
printf '\nnew_key: x\n' >> "$K/project/.segoy/config.yml.tmpl"
printf 'kit text\n' > "$K/project/docs/specs/.gitkeep"
"$S" sync --no-github "$P" > "$T/out" 2>&1
t  "project CLAUDE.md untouched" cmp -s "$P/CLAUDE.md" "$T/claude.before"
t  "config untouched" cmp -s "$P/.segoy/config.yml" "$T/config.before"
tn "unmanaged kit file not updated" has "$P/docs/specs/.gitkeep" "kit text"

# 7. Brain: CLAUDE.md is managed there; a skeleton file the owner removed stays removed.
rm "$B/journal/.gitkeep"
printf '\n12. extra rule\n' >> "$K/brain/CLAUDE.md"
"$S" sync --no-github "$B" > "$T/out" 2>&1
t  "brain CLAUDE.md updated" has "$B/CLAUDE.md" "12. extra rule"
tn "removed skeleton file not restored" test -e "$B/journal/.gitkeep"
tn "brain gets no project files" test -e "$B/.claude/skills/segoy-implement/SKILL.md"

# 8. Usage errors.
mkdir "$T/plain"
tn "repo without manifest refused" "$S" sync --no-github "$T/plain"
tn "--pr with --dry-run refused" "$S" sync --pr --dry-run "$P"

exit "$fail"
