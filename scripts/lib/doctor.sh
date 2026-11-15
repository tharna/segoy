# shellcheck shell=sh
# doctor.sh — `segoy doctor`. Sourced by scripts/segoy.

D_FAIL=0
d_ok()   { say "ok   $*"; }
d_warn() { say "WARN $*"; }
d_fail() { say "FAIL $*"; D_FAIL=1; }

doctor_offline() {
  dir=$1
  cfg=$dir/.segoy/config.yml
  if [ ! -f "$cfg" ]; then
    d_fail "no .segoy/config.yml (run: segoy init brain $dir)"
    return
  fi
  d_ok "config present"
  if grep -nE '^[a-z_]+:[[:space:]]*<[^>]*>' "$cfg" >/dev/null; then
    d_fail "config still has placeholders: $(grep -oE '^[a-z_]+:[[:space:]]*<[^>]*>' "$cfg" | cut -d: -f1 | tr '\n' ' ')"
  else
    d_ok "config has no placeholders"
  fi
  kind=$(jq -r '.kit // "brain"' "$dir/.segoy/manifest.json" 2>/dev/null || echo brain)
  case $kind in
    project) keys="owner project_repo answer_label" ;;
    *) keys="owner brain_repo notes_language answer_label" ;;
  esac
  for k in $keys; do
    [ -n "$(config_value "$dir" "$k")" ] || d_fail "config lacks $k"
  done
  if [ -f "$dir/CLAUDE.md" ]; then d_ok "CLAUDE.md present"; else d_fail "CLAUDE.md missing"; fi

  if [ -f "$dir/.segoy/labels.json" ] && jq -e '.labels | length > 0' "$dir/.segoy/labels.json" >/dev/null 2>&1; then
    d_ok "labels.json valid"
  else
    d_fail "labels.json missing or invalid"
  fi

  if [ -f "$dir/.segoy/version" ]; then
    have=$(cat "$dir/.segoy/version")
    want=$(segoy_version)
    if [ "${have%%+*}" = "${want%%+*}" ]; then d_ok "kit version $have"; else d_warn "kit version $have, this Segoy is $want (sync arrives in M4)"; fi
  else
    d_fail "no .segoy/version"
  fi

  m=$dir/.segoy/manifest.json
  if ! jq -e '.files | type == "object"' "$m" >/dev/null 2>&1; then
    d_fail "manifest missing or invalid"
    return
  fi
  missing=0 changed=0
  jq -r '.files | to_entries[] | "\(.key)\t\(.value)"' "$m" > "$m.check.$$"
  while IFS="$(printf '\t')" read -r p h; do
    if [ ! -f "$dir/$p" ]; then
      missing=$((missing + 1))
    elif [ "$(file_hash "$dir/$p")" != "$h" ]; then
      changed=$((changed + 1))
    fi
  done < "$m.check.$$"
  rm -f "$m.check.$$"
  if [ "$missing" -eq 0 ]; then d_ok "all kit files present"; else d_warn "$missing kit file(s) missing"; fi
  if [ "$changed" -eq 0 ]; then d_ok "no kit files changed"; else say "info $changed kit file(s) edited since init (expected for config, indexes and stubs)"; fi
}

doctor_online() {
  dir=$1
  if ! command -v gh >/dev/null 2>&1; then
    d_fail "gh not installed"
    return
  fi
  if user=$(gh api user --jq .login 2>/dev/null) && [ -n "$user" ]; then
    d_ok "GitHub REST API reachable (as $user)"
  else
    d_fail "GitHub REST API not reachable with gh (GraphQL is not needed)"
    return
  fi
  slug=$(config_value "$dir" brain_repo)
  [ -n "$slug" ] || slug=$(config_value "$dir" project_repo)
  case $slug in */*) ;; *) slug=$(repo_slug "$dir") ;; esac
  if [ -z "$slug" ]; then
    d_fail "cannot tell the repo: set brain_repo in config"
    return
  fi
  if have=$(gh api "repos/$slug/labels?per_page=100" --jq '.[].name' 2>/dev/null); then
    miss=$(jq -r '.labels[].name' "$dir/.segoy/labels.json" | while IFS= read -r n; do
      printf '%s\n' "$have" | grep -qxF "$n" || printf '%s ' "$n"
    done)
    if [ -z "$miss" ]; then d_ok "all labels present in $slug"; else d_fail "labels missing in $slug: $miss(run: segoy init brain $dir)"; fi
  else
    d_fail "cannot read labels of $slug"
  fi
  branch=$(gh api "repos/$slug" --jq .default_branch 2>/dev/null || echo main)
  if rules=$(gh api "repos/$slug/rules/branches/$branch" 2>"$dir/.segoy/.err.$$"); then
    if [ "$(printf '%s' "$rules" | jq 'length')" -gt 0 ]; then
      d_ok "branch rules active on $branch"
    else
      d_warn "no branch rules on $branch (planned for T4.3: require PR, block force-push)"
    fi
  elif grep -q "Upgrade to GitHub Pro" "$dir/.segoy/.err.$$"; then
    d_warn "branch rules for a private repo need GitHub Pro; skipped (see T4.3)"
  else
    d_warn "cannot read branch rules: $(tail -n 1 "$dir/.segoy/.err.$$")"
  fi
  rm -f "$dir/.segoy/.err.$$"
  say "info the Claude GitHub App cannot be detected from here; check github.com/settings/installations"
}

cmd_doctor() {
  dir=. offline=0 mode=repo files=''
  while [ $# -gt 0 ]; do
    case $1 in
      --offline) offline=1 ;;
      --skills) mode=skills ;;
      --protocol) mode=protocol; shift; files="$*"; break ;;
      -*) die "unknown option $1" ;;
      *) dir=$1 ;;
    esac
    shift
  done
  need jq git
  case $mode in
    skills)
      if [ -d "$dir/.claude" ] || [ -d "$dir/kit" ]; then
        (cd "$dir" && "$SEGOY_HOME/scripts/lib/lint-skills.sh")
      else
        die "no .claude/ or kit/ in $dir"
      fi
      return ;;
    protocol)
      [ -n "$files" ] || die "usage: segoy doctor --protocol FILE..."
      # shellcheck disable=SC2086  # word splitting of the file list is intended
      "$SEGOY_HOME/scripts/lib/protocol.sh" $files
      return ;;
  esac
  [ -d "$dir" ] || die "$dir is not a directory"
  say "segoy doctor: $dir"
  doctor_offline "$dir"
  if [ "$offline" -eq 0 ]; then doctor_online "$dir"; else say "info online checks skipped (--offline)"; fi
  return $D_FAIL
}
