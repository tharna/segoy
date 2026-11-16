# shellcheck shell=sh
# sync.sh — `segoy sync`. Sourced by scripts/segoy.
#
# Brings a repo set up with `segoy init` up to this Segoy's kit.
# Kit-managed files (see is_managed) are updated when the repo has not changed
# them since the last sync; a locally changed file gets the new version beside
# it as <file>.segoy-new. Every other kit file is copied only when absent.
# Files that left the kit are reported, never deleted.

SYNC_USAGE="usage: segoy sync [--dry-run] [--no-github] [--pr] [--branch NAME] [--pr-footer FILE] <dir>"

# is_managed PATH — kit files that sync keeps up to date. Everything else
# (config, denylist, generated project CLAUDE.md, notes, skeleton) is the repo's.
is_managed() {
  case $1 in
    .claude/*|.github/workflows/segoy-*|.github/ISSUE_TEMPLATE/*|.segoy/labels.json) return 0 ;;
    CLAUDE.md) [ "$SYNC_KIND" = brain ] ;;   # the brain's CLAUDE.md is kit text; a project's is generated
    *) return 1 ;;
  esac
}

# render_kit_file KIT REL OUT — the file as init would write it (dates filled, mode kept).
render_kit_file() {
  src="$SEGOY_HOME/kit/$1/$2"
  case $2 in
    *.md) sed "s/{{date}}/$(date -u +%Y-%m-%d)/g" "$src" > "$3" ;;
    *)    cp "$src" "$3" ;;
  esac
  if [ -x "$src" ]; then chmod +x "$3"; else chmod -x "$3"; fi
}

# kit_had KIT REL HASH — true if HASH is the blob of any committed version of
# kit/KIT/REL in Segoy's history: the repo holds an old kit file, not a local change
# (repos synced by hand before `segoy sync` existed have stale manifest hashes).
kit_had() {
  git -C "$SEGOY_HOME" log --format=%H -- "kit/$1/$2" 2>/dev/null | while IFS= read -r c; do
    [ "$(git -C "$SEGOY_HOME" rev-parse -q --verify "$c:kit/$1/$2" 2>/dev/null)" = "$3" ] && echo yes && break
  done | grep -q yes
}

# sync_note ACTION PATH — record one line of the report.
sync_note() {
  printf '%-9s %s\n' "$1" "$2" >> "$TMPD/report"
  case $1 in add|update|restore) SYNC_CHANGED=$((SYNC_CHANGED + 1)) ;; conflict) SYNC_CONFLICTS=$((SYNC_CONFLICTS + 1)); SYNC_CHANGED=$((SYNC_CHANGED + 1)) ;; esac
}

# sync_put NEW OUT — install NEW at OUT unless this is a dry run.
sync_put() {
  [ "$SYNC_DRY" -eq 1 ] && return 0
  mkdir -p "$(dirname "$2")"
  cp "$1" "$2"
  if [ -x "$1" ]; then chmod +x "$2"; else chmod -x "$2"; fi
}

# sync_kit KIT DEST — compare every file of kit/KIT with DEST and the manifest.
sync_kit() {
  src="$SEGOY_HOME/kit/$1"
  [ -d "$src" ] || return 0
  ( cd "$src" && find . -type f ! -name KIT.md ! -name '*.tmpl' | sed 's#^\./##' | sort ) > "$TMPD/files.$1"
  while IFS= read -r rel; do
    printf '%s\n' "$rel" >> "$TMPD/kitfiles"
    new=$TMPD/new
    render_kit_file "$1" "$rel" "$new"
    nh=$(file_hash "$new")
    out=$2/$rel
    rec=$(jq -r --arg p "$rel" '.files[$p] // ""' "$TMPD/manifest.old")
    if [ ! -e "$out" ]; then
      if [ -n "$rec" ] && ! is_managed "$rel"; then
        continue   # the repo removed a file it owns; leave it removed
      fi
      if [ -n "$rec" ]; then sync_note restore "$rel"; else sync_note add "$rel"; fi
      sync_put "$new" "$out"
      printf '%s\t%s\n' "$rel" "$nh" >> "$TMPD/hashes"
      continue
    fi
    is_managed "$rel" || continue
    ch=$(file_hash "$out")
    if [ "$ch" = "$nh" ]; then
      [ "$rec" = "$nh" ] || printf '%s\t%s\n' "$rel" "$nh" >> "$TMPD/hashes"
    elif { [ -n "$rec" ] && [ "$ch" = "$rec" ]; } || kit_had "$1" "$rel" "$ch"; then
      sync_note update "$rel"
      sync_put "$new" "$out"
      printf '%s\t%s\n' "$rel" "$nh" >> "$TMPD/hashes"
    else
      if [ -f "$out.segoy-new" ] && [ "$(file_hash "$out.segoy-new")" = "$nh" ]; then
        printf '%-9s %s\n' pending "$rel (resolve $rel.segoy-new)" >> "$TMPD/report"
        SYNC_CONFLICTS=$((SYNC_CONFLICTS + 1))
      else
        sync_note conflict "$rel (local changes kept; new version in $rel.segoy-new)"
        sync_put "$new" "$out.segoy-new"
      fi
    fi
  done < "$TMPD/files.$1"
}

# sync_orphans — manifest entries for managed files the kit no longer has.
sync_orphans() {
  jq -r '.files | keys[]' "$TMPD/manifest.old" | while IFS= read -r p; do
    is_managed "$p" || continue
    grep -qxF "$p" "$TMPD/kitfiles" && continue
    [ -e "$1/$p" ] && printf '%-9s %s\n' orphan "$p (no longer in the kit; delete it if unused)" >> "$TMPD/report"
  done
}

# ver_lt A B — true if version A sorts before B (x.y.z; a pre-release such as
# 0.1.0-dev sorts before 0.1.0; build metadata after + is ignored).
ver_lt() {
  awk -v a="${1%%+*}" -v b="${2%%+*}" 'BEGIN {
    na = split(a, x, "-"); nb = split(b, y, "-")
    split(x[1], p, "."); split(y[1], q, ".")
    for (i = 1; i <= 3; i++) { if (p[i] + 0 < q[i] + 0) exit 0; if (p[i] + 0 > q[i] + 0) exit 1 }
    if (na > 1 && nb == 1) exit 0
    if (na > 1 && nb > 1 && x[2] < y[2]) exit 0
    exit 1 }'
}

# sync_migrations HAVE — list migrations/<v>.md with HAVE < v <= this Segoy.
sync_migrations() {
  want=$(cat "$SEGOY_HOME/VERSION" 2>/dev/null || echo 0.0.0)
  for m in "$SEGOY_HOME"/migrations/*.md; do
    [ -f "$m" ] || continue
    v=$(basename "$m" .md)
    case $v in README) continue ;; esac
    if { [ "$1" = none ] || ver_lt "$1" "$v"; } && ! ver_lt "$want" "$v"; then
      printf '%-9s %s\n' migrate "migrations/$v.md (follow it by hand; see the Segoy repo)" >> "$TMPD/report"
    fi
  done
}

# sync_write_manifest DEST — new version and hashes, keeping other entries.
sync_write_manifest() {
  segoy_version > "$1/.segoy/version"
  jq -R -n '[inputs | split("\t") | {(.[0]): .[1]}] | add // {}' "$TMPD/hashes" > "$TMPD/entries"
  jq --arg v "$(segoy_version)" --arg k "$SYNC_KIND" --slurpfile new "$TMPD/entries" \
     '{v: 1, segoy: $v, kit: $k, files: ((.files // {}) + $new[0])}' "$TMPD/manifest.old" > "$1/.segoy/manifest.json"
}

# sync_open_pr DIR SLUG — commit the sync on a branch, push it and open a PR (REST).
sync_open_pr() {
  dir=$1 slug=$2
  base=$(gh api "repos/$slug" --jq .default_branch 2>/dev/null) || base=main
  branch=${SYNC_BRANCH:-claude/chore-sync-$(cat "$SEGOY_HOME/VERSION" 2>/dev/null || echo 0)}
  open=$(gh api "repos/$slug/pulls?state=open&head=${slug%%/*}:$branch" --jq length 2>/dev/null || echo 0)
  if [ "$open" != 0 ]; then
    say "pr: an open PR already uses $branch; not opening another"
    return 1
  fi
  git -C "$dir" checkout -q -B "$branch" || return 1
  git -C "$dir" add -A || return 1
  git -C "$dir" commit -q -m "chore: sync Segoy kit $(segoy_version)" || return 1
  git -C "$dir" push -q -u origin "$branch" || return 1
  # shellcheck disable=SC2016  # backticks are Markdown, not command substitution
  {
    printf 'Syncs the Segoy kit to `%s`.\n\n```\n' "$(segoy_version)"
    cat "$TMPD/report"
    printf '```\n\n'
    if [ "$SYNC_CONFLICTS" -gt 0 ]; then
      printf 'Files marked `conflict` were changed in this repo: the new kit version is in `<file>.segoy-new`. Merge the parts you want into the file and delete the `.segoy-new` file, in this PR or later.\n\n'
    fi
    printf 'Merge to accept. Close to skip this version.\n'
    [ -n "$SYNC_FOOTER" ] && { printf '\n'; cat "$SYNC_FOOTER"; }
  } > "$TMPD/body"
  url=$(gh api -X POST "repos/$slug/pulls" -f title="Sync Segoy kit $(cat "$SEGOY_HOME/VERSION" 2>/dev/null)" \
        -f head="$branch" -f base="$base" -F body=@"$TMPD/body" --jq .html_url) || return 1
  say "pr: $url"
}

cmd_sync() {
  SYNC_DRY=0 github=1 pr=0 dir='' SYNC_BRANCH='' SYNC_FOOTER=''
  while [ $# -gt 0 ]; do
    case $1 in
      --dry-run) SYNC_DRY=1 ;;
      --no-github) github=0 ;;
      --pr) pr=1 ;;
      --branch) shift; SYNC_BRANCH=${1:-} ;;
      --pr-footer) shift; SYNC_FOOTER=${1:-} ;;
      -*) die "unknown option $1" ;;
      *) dir=$1 ;;
    esac
    shift
  done
  [ -n "$dir" ] || die "$SYNC_USAGE"
  [ -d "$dir" ] || die "$dir is not a directory"
  [ -f "$dir/.segoy/manifest.json" ] || die "$dir has no .segoy/manifest.json; set it up with: segoy init brain|project $dir"
  [ -z "$SYNC_FOOTER" ] || [ -r "$SYNC_FOOTER" ] || die "--pr-footer: cannot read $SYNC_FOOTER"
  if [ -n "$SYNC_FOOTER" ] && ! "$SEGOY_HOME/kit/common/.claude/scripts/protocol.sh" "$SYNC_FOOTER" >&2; then
    die "--pr-footer: its segoy blocks are not valid (docs/protocol.md); nothing was changed"
  fi
  need jq git
  if [ "$pr" -eq 1 ]; then
    [ "$SYNC_DRY" -eq 0 ] || die "--pr and --dry-run do not go together"
    [ -z "$(git -C "$dir" status --porcelain 2>/dev/null)" ] || die "$dir has uncommitted changes; --pr needs a clean checkout"
  fi
  slug=''
  if [ "$github" -eq 1 ] || [ "$pr" -eq 1 ]; then
    need gh
    slug=$(repo_slug "$dir")
    [ -n "$slug" ] || die "cannot tell the GitHub repo from $dir's origin; pass --no-github"
  fi

  TMPD=$(mktemp -d) || die "mktemp failed"
  trap 'rm -rf "$TMPD"' EXIT
  : > "$TMPD/report"; : > "$TMPD/hashes"; : > "$TMPD/kitfiles"
  SYNC_CHANGED=0 SYNC_CONFLICTS=0
  jq -e '.files | type == "object"' "$dir/.segoy/manifest.json" >/dev/null 2>&1 || die "$dir/.segoy/manifest.json is not valid"
  cp "$dir/.segoy/manifest.json" "$TMPD/manifest.old"
  SYNC_KIND=$(jq -r '.kit // "brain"' "$TMPD/manifest.old")
  have=$(cat "$dir/.segoy/version" 2>/dev/null || echo none)

  sync_kit common "$dir"
  sync_kit "$SYNC_KIND" "$dir"
  sync_orphans "$dir"
  sync_migrations "$have"
  want_base=$(cat "$SEGOY_HOME/VERSION" 2>/dev/null || echo 0.0.0)
  if [ "${have%%+*}" != "$want_base" ]; then
    printf '%-9s %s\n' version "${have%%+*} -> $want_base" >> "$TMPD/report"
    SYNC_CHANGED=$((SYNC_CHANGED + 1))
  fi

  mode=''; [ "$SYNC_DRY" -eq 1 ] && mode=' (dry run: nothing written)'
  say "segoy sync $SYNC_KIND $dir: $have -> $(segoy_version)$mode"
  if [ -s "$TMPD/report" ]; then cat "$TMPD/report"; fi
  if [ "$SYNC_CHANGED" -eq 0 ]; then
    say "up to date: no kit file changes"
    # Hashes may still need recording (files equal to the kit but missing from the manifest).
    [ "$SYNC_DRY" -eq 0 ] && [ -s "$TMPD/hashes" ] && [ "$pr" -eq 0 ] && sync_write_manifest "$dir"
    return 0
  fi
  say "files: $SYNC_CHANGED changed, $SYNC_CONFLICTS need a manual merge"
  [ "$SYNC_DRY" -eq 1 ] && return 0

  sync_write_manifest "$dir"
  status=0
  if [ "$github" -eq 1 ]; then
    apply_labels "$slug" "$dir/.segoy/labels.json" || status=1
  fi
  if [ "$pr" -eq 1 ]; then
    sync_open_pr "$dir" "$slug" || { warn "could not open the sync PR"; status=1; }
  fi
  return "$status"
}
