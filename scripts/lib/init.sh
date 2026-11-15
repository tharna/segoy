# shellcheck shell=sh
# init.sh — `segoy init brain`. Sourced by scripts/segoy.

# copy_kit KIT DEST — copy kit/KIT into DEST without overwriting.
# Appends copied paths (relative to DEST) to $COPIED_LIST; counts skips in $SKIPPED.
copy_kit() {
  src="$SEGOY_HOME/kit/$1"
  [ -d "$src" ] || return 0
  today=$(date -u +%Y-%m-%d)
  ( cd "$src" && find . -type f ! -name KIT.md | sed 's#^\./##' | sort ) > "$TMPD/files.$1"
  while IFS= read -r rel; do
    case $rel in
      .segoy/config.yml.tmpl) out=.segoy/config.yml ;;
      *) out=$rel ;;
    esac
    if [ -e "$2/$out" ]; then
      say "skip   $out (exists)"
      SKIPPED=$((SKIPPED + 1))
      continue
    fi
    mkdir -p "$2/$(dirname "$out")"
    case $out in
      *.md) sed "s/{{date}}/$today/g" "$src/$rel" > "$2/$out" ;;
      *)    cp "$src/$rel" "$2/$out" ;;
    esac
    [ -x "$src/$rel" ] && chmod +x "$2/$out"
    say "add    $out"
    printf '%s\n' "$out" >> "$COPIED_LIST"
  done < "$TMPD/files.$1"
}

# write_manifest DEST KIND — .segoy/version and .segoy/manifest.json for every file
# Segoy has placed in DEST (previous manifest entries are kept).
write_manifest() {
  dest=$1
  mkdir -p "$dest/.segoy"
  segoy_version > "$dest/.segoy/version"
  old="$dest/.segoy/manifest.json"
  [ -f "$old" ] || printf '{"files":{}}\n' > "$old"
  entries='{}'
  while IFS= read -r p; do
    [ -n "$p" ] || continue
    h=$(file_hash "$dest/$p")
    entries=$(printf '%s' "$entries" | jq --arg p "$p" --arg h "$h" '. + {($p): $h}')
  done < "$COPIED_LIST"
  jq --arg v "$(segoy_version)" --arg k "$2" --argjson new "$entries" \
     '{v: 1, segoy: $v, kit: $k, files: ((.files // {}) + $new)}' "$old" > "$TMPD/manifest" \
     && mv "$TMPD/manifest" "$old"
}

# apply_labels SLUG LABELS_JSON — create or update every label through the REST API.
apply_labels() {
  slug=$1
  n=0 bad=0
  jq -c '.labels[]' "$2" > "$TMPD/labels"
  while IFS= read -r l; do
    name=$(printf '%s' "$l" | jq -r .name)
    color=$(printf '%s' "$l" | jq -r .color)
    desc=$(printf '%s' "$l" | jq -r .description)
    # gh api prints the error body (with "already_exists") on stdout, a summary on stderr.
    if gh api -X POST "repos/$slug/labels" -f name="$name" -f color="$color" -f description="$desc" >"$TMPD/err" 2>&1; then
      n=$((n + 1))
    elif grep -q already_exists "$TMPD/err"; then
      enc=$(printf '%s' "$name" | jq -sRr @uri)
      if gh api -X PATCH "repos/$slug/labels/$enc" -f color="$color" -f description="$desc" >/dev/null 2>&1; then
        n=$((n + 1))
      else
        warn "could not update label $name"; bad=$((bad + 1))
      fi
    else
      warn "could not create label $name: $(tail -n 1 "$TMPD/err")"; bad=$((bad + 1))
    fi
  done < "$TMPD/labels"
  say "labels: $n created or updated, $bad failed"
  [ "$bad" -eq 0 ]
}

cmd_init() {
  [ "${1:-}" = brain ] || die "usage: segoy init brain [--no-github] [--repo <owner>/<repo>] <dir>"
  shift
  github=1 slug='' dir=''
  while [ $# -gt 0 ]; do
    case $1 in
      --no-github) github=0 ;;
      --repo) shift; slug=${1:-} ;;
      -*) die "unknown option $1" ;;
      *) dir=$1 ;;
    esac
    shift
  done
  [ -n "$dir" ] || die "usage: segoy init brain [--no-github] [--repo <owner>/<repo>] <dir>"
  [ -d "$dir" ] || die "$dir is not a directory"
  need jq git
  [ "$github" -eq 0 ] || need gh

  if [ "$github" -eq 1 ] && [ -z "$slug" ]; then
    slug=$(repo_slug "$dir")
    [ -n "$slug" ] || die "cannot tell the GitHub repo from $dir's origin; pass --repo <owner>/<repo> or --no-github"
  fi

  TMPD=$(mktemp -d) || die "mktemp failed"
  trap 'rm -rf "$TMPD"' EXIT
  COPIED_LIST=$TMPD/copied
  : > "$COPIED_LIST"
  SKIPPED=0

  say "segoy $(segoy_version): init brain in $dir"
  copy_kit common "$dir"
  copy_kit brain "$dir"
  write_manifest "$dir" brain
  say "files: $(wc -l < "$COPIED_LIST" | tr -d ' ') added, $SKIPPED kept as they were"

  status=0
  if [ "$github" -eq 1 ]; then
    apply_labels "$slug" "$dir/.segoy/labels.json" || status=1
  else
    say "labels: skipped (--no-github)"
  fi

  say ""
  say "Next:"
  say "  1. Edit $dir/.segoy/config.yml (replace every <...>)."
  say "  2. Commit on a branch and open a PR; merge it yourself."
  say "  3. Run: scripts/segoy doctor $dir"
  return $status
}
