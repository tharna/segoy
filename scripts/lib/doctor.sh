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
    if [ "${have%%+*}" = "${want%%+*}" ]; then d_ok "kit version $have"; else d_warn "kit version $have, this Segoy is $want (run: segoy sync $dir)"; fi
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

# doctor_history DIR [leak-guard options] — leak-check every file version and every
# commit message in DIR's history. Prints "<path>@<blob>:<line>: <rule>", never the text.
doctor_history() {
  hdir=$1; shift
  git -C "$hdir" rev-parse --git-dir >/dev/null 2>&1 || die "$hdir is not a git repository"
  H=$(mktemp -d) || die "mktemp failed"
  git -C "$hdir" rev-list --all --objects > "$H/objects"
  cut -d' ' -f1 "$H/objects" | git -C "$hdir" cat-file --batch-check='%(objecttype) %(objectname)' \
    | awk '$1 == "blob" { print $2 }' | sort -u > "$H/blobs"
  n=0
  while IFS=' ' read -r sha path; do
    [ -n "$path" ] || continue
    grep -qx "$sha" "$H/blobs" || continue
    [ -e "$H/b/$sha" ] && continue      # one copy per blob is enough
    mkdir -p "$H/b/$sha/$(dirname "$path")"
    git -C "$hdir" cat-file blob "$sha" > "$H/b/$sha/$path"
    n=$((n + 1))
  done < "$H/objects"
  git -C "$hdir" log --all --format='%H%n%B%n' > "$H/commit-messages"
  say "segoy doctor --history: $n file versions and $(git -C "$hdir" rev-list --all | wc -l | tr -d ' ') commit messages"
  status=0
  ( cd "$H/b" 2>/dev/null && find . -type f | sed 's#^\./##' ) > "$H/list"
  if [ -s "$H/list" ]; then
    (cd "$H/b" && tr '\n' '\0' < "$H/list" | xargs -0 "$SEGOY_HOME/kit/common/.claude/scripts/leak-guard.sh" "$@") > "$H/raw" || status=1
    sed 's#^LEAK \([0-9a-f]\{40\}\)/\([^:]*\):#LEAK \2@\1:#; s#@\([0-9a-f]\{7\}\)[0-9a-f]*:#@\1:#' "$H/raw" > "$H/out"
  fi
  (cd "$H" && "$SEGOY_HOME/kit/common/.claude/scripts/leak-guard.sh" "$@" commit-messages) >> "$H/out" || status=1
  grep '^LEAK' "$H/out"
  say "findings: $(grep -c '^LEAK' "$H/out")"
  rm -rf "$H"
  return "$status"
}

cmd_doctor() {
  dir=. offline=0 mode=repo files='' hopts=''
  while [ $# -gt 0 ]; do
    case $1 in
      --offline) offline=1 ;;
      --skills) mode=skills ;;
      --protocol) mode=protocol; shift; files="$*"; break ;;
      --history) mode=history ;;
      --denylist|--skip|--exclude)
        v=${2:-}
        [ "$1" = --denylist ] && case $v in /*) ;; *) v=$(pwd)/$v ;; esac
        hopts="$hopts$1
$v
"; shift ;;
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
      "$SEGOY_HOME/kit/common/.claude/scripts/protocol.sh" $files
      return ;;
  esac
  [ -d "$dir" ] || die "$dir is not a directory"
  if [ "$mode" = history ]; then
    # Options are newline-separated so values with spaces ("private block marker") survive.
    old_ifs=$IFS; IFS='
'
    # shellcheck disable=SC2086  # split on newlines only
    set -- $hopts
    IFS=$old_ifs
    doctor_history "$dir" "$@"
    return
  fi
  say "segoy doctor: $dir"
  doctor_offline "$dir"
  if [ "$offline" -eq 0 ]; then doctor_online "$dir"; else say "info online checks skipped (--offline)"; fi
  return $D_FAIL
}
