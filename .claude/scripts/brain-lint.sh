#!/bin/sh
# brain-lint.sh — mechanical health checks for a brain repo (used by segoy-lint).
#
# Usage: brain-lint.sh [--today YYYY-MM-DD] [--fix] <brain-dir>
#
# Scans every *.md file under <brain-dir>, skipping .git/ .claude/ .segoy/
# .github/ and inbox/, and prints one finding per line, sorted by check, then path:
#   <check><TAB><path><TAB><detail>
# <check> is one of:
#   frontmatter  a required field is missing (or there is no frontmatter block);
#   index        ideas/, decisions/, knowledge/wiki/, projects/ or ways/ index
#                drifted from the files it lists (path is the index file);
#   orphan       a knowledge/wiki/ page no other brain file links to;
#   stale        a knowledge/wiki/ page whose `updated` is more than 90 days
#                before --today (default: today, UTC).
# <path> is relative to the brain root. A finding that --fix can fix ends with
# " (fixable)".
#
# --fix scans first, then applies only the fixable findings: it adds missing
# derivable frontmatter fields (and sets `updated` to --today on each such file)
# and corrects index rows. It prints each applied fix as
#   fixed<TAB><path><TAB><what was done>
# and every other finding of the scan unchanged. It never changes a body line,
# never writes under knowledge/raw/, and never removes or reorders an existing
# frontmatter line.
#
# Privacy: for files under self/ only the frontmatter block is read; parsing
# stops at its closing "---". The body is never parsed or printed (a fix copies
# it unchanged with tail). Output names paths and field names only.
#
# No network. POSIX sh, awk, sed, git (git only for `created` dates).
# Exit status: 0 no findings (with --fix: none left unfixed), 1 findings remain,
# 2 usage error.

set -u

usage() { echo "usage: brain-lint.sh [--today YYYY-MM-DD] [--fix] <brain-dir>" >&2; exit 2; }

today='' fix=0 dir=''
while [ $# -gt 0 ]; do
  case $1 in
    --today) [ $# -ge 2 ] || usage; shift; today=$1 ;;
    --fix) fix=1 ;;
    --) shift; break ;;
    -?*) echo "brain-lint: unknown option $1" >&2; usage ;;
    *) [ -z "$dir" ] || usage; dir=$1 ;;
  esac
  shift
done
if [ $# -gt 0 ]; then
  [ -z "$dir" ] && [ $# -eq 1 ] || usage
  dir=$1
fi
[ -n "$dir" ] || usage
[ -d "$dir" ] || { echo "brain-lint: no such directory: $dir" >&2; exit 2; }
[ -n "$today" ] || today=$(date -u +%F)
case $today in
  [0-9][0-9][0-9][0-9]-[01][0-9]-[0-3][0-9]) ;;
  *) echo "brain-lint: --today must be YYYY-MM-DD" >&2; exit 2 ;;
esac

cd "$dir" || exit 2
tmp=$(mktemp -d) || exit 2
trap 'rm -rf "$tmp"' EXIT
trap 'exit 2' INT TERM
TAB=$(printf '\t')

# --- Collect ------------------------------------------------------------------
# All paths (for link targets), and the scanned Markdown files.
find . -name .git -prune -o -print | sed 's|^\./||' | grep -v '^\.$' > "$tmp/exists"
find . \( -path ./.git -o -path ./.claude -o -path ./.segoy -o -path ./.github -o -path ./inbox \) -prune \
  -o -type f -name '*.md' -print | sed 's|^\./||' | LC_ALL=C sort > "$tmp/files"

# Scanner. Emits records (TAB-separated):
#   F path none|open   first line is / is not "---"
#   E path n           closing "---" of the frontmatter is line n
#   K path key value   top-level frontmatter field
#   H path text        first "# " heading of the body
#   L path target      Markdown link target in the body
#   X path n line      every line of an index file that is checked for drift
# With self=1 it stops at the closing "---" (or line 200) and emits only F/E/K.
# shellcheck disable=SC2016  # awk program, not shell.
SCAN='
function trim(s) { sub(/^[ \t]+/, "", s); sub(/[ \t]+$/, "", s); return s }
FNR == 1 {
  p = FILENAME; sub(/^\.\//, "", p)
  isx = (p == "ideas/index.md" || p == "decisions/index.md" || p == "knowledge/wiki/index.md" ||
         p == "projects/index.md" || p == "ways/index.md" || p == "ways/private/index.md")
  head = 0
  if ($0 == "---") { infm = 1; print "F\t" p "\topen" }
  else { infm = 0; print "F\t" p "\tnone"; if (self) exit }
}
isx { l = $0; gsub(/\t/, " ", l); print "X\t" p "\t" FNR "\t" l }
FNR == 1 && infm { next }
infm {
  if ($0 == "---") { infm = 0; print "E\t" p "\t" FNR; if (self) exit; next }
  if (self && FNR > 200) exit
  if (match($0, /^[A-Za-z_][A-Za-z0-9_-]*:/)) {
    k = substr($0, 1, RLENGTH - 1); v = trim(substr($0, RLENGTH + 1)); gsub(/\t/, " ", v)
    if (v ~ /^".*"$/ || v ~ /^\047.*\047$/) v = substr(v, 2, length(v) - 2)
    print "K\t" p "\t" k "\t" v
  }
  next
}
!head && /^# / { h = trim(substr($0, 3)); sub(/[ \t]+#+$/, "", h); gsub(/\t/, " ", h); print "H\t" p "\t" h; head = 1 }
{
  s = $0
  while (match(s, /\]\([^)]*\)/)) {
    t = substr(s, RSTART + 2, RLENGTH - 3); gsub(/\t/, " ", t)
    print "L\t" p "\t" t
    s = substr(s, RSTART + RLENGTH)
  }
}'

: > "$tmp/recs"
grep -v '^self/' "$tmp/files" > "$tmp/other"
grep '^self/' "$tmp/files" > "$tmp/self"
if [ -s "$tmp/other" ]; then
  # Batch through find so names need no quoting; self/ is pruned here.
  find . \( -path ./.git -o -path ./.claude -o -path ./.segoy -o -path ./.github -o -path ./inbox -o -path ./self \) -prune \
    -o -type f -name '*.md' -exec awk -v self=0 "$SCAN" {} + >> "$tmp/recs"
fi
while IFS= read -r f; do
  awk -v self=1 "$SCAN" "./$f" >> "$tmp/recs"
done < "$tmp/self"

# `created` from git for files with frontmatter but no created field.
if git rev-parse --git-dir > /dev/null 2>&1; then
  awk -F '\t' '$1 == "F" && $3 == "open" { o[$2] = 1 } $1 == "K" && $3 == "created" { c[$2] = 1 }
    END { for (p in o) if (!(p in c)) print p }' "$tmp/recs" | while IFS= read -r f; do
    d=$(git log --diff-filter=A --format=%as -- "$f" 2> /dev/null | tail -n 1)
    [ -n "$d" ] && printf 'G\t%s\t%s\n' "$f" "$d"
  done > "$tmp/created"
  cat "$tmp/created" >> "$tmp/recs"
fi

# --- Analyse ------------------------------------------------------------------
# Emits:
#   R check path detail fixed-detail   finding (fixed-detail empty = not fixable)
#   M path "key: value"                frontmatter line to add (canonical order)
#   S path                             file whose existing `updated` is reset
#   O path op n text                   index edit: D delete line n, R replace
#                                      line n, A append after line n, Z append at end
# shellcheck disable=SC2016  # awk program, not shell.
ANALYSE='
function trim(s) { sub(/^[ \t]+/, "", s); sub(/[ \t]+$/, "", s); return s }
function rest(n,   s, i) { s = $0; for (i = 1; i <= n; i++) sub(/^[^\t]*\t/, "", s); return s }
function base(p) { sub(/^.*\//, "", p); return p }
function dirof(p) { if (p !~ /\//) return ""; sub(/\/[^\/]*$/, "", p); return p }
function isdate(s) { return s ~ /^[0-9][0-9][0-9][0-9]-[01][0-9]-[0-3][0-9]$/ }
function daynum(s,   y, m, d, era, yoe, doy) {
  y = substr(s, 1, 4) + 0; m = substr(s, 6, 2) + 0; d = substr(s, 9, 2) + 0
  if (m <= 2) y--
  era = int(y / 400); yoe = y - era * 400
  doy = int((153 * (m > 2 ? m - 3 : m + 9) + 2) / 5) + d - 1
  return era * 146097 + yoe * 365 + int(yoe / 4) - int(yoe / 100) + doy - 719468
}
function norm(p,   n, a, i, o, k, r) {
  n = split(p, a, "/"); k = 0
  for (i = 1; i <= n; i++) {
    if (a[i] == "" || a[i] == ".") continue
    if (a[i] == "..") { if (k == 0) return ""; k--; continue }
    o[++k] = a[i]
  }
  r = ""; for (i = 1; i <= k; i++) r = r (i > 1 ? "/" : "") o[i]
  return r
}
# Resolve a link target found in file `from` to a brain path; "" = not a relative link.
function resolve(from, t,   d) {
  t = trim(t)
  if (t ~ /^</) { sub(/^</, "", t); sub(/>.*$/, "", t) } else sub(/[ \t].*$/, "", t)
  if (t == "" || t ~ /^#/ || t ~ /^\// || t ~ /^[A-Za-z][A-Za-z0-9+.-]*:/) return ""
  sub(/#.*$/, "", t); sub(/\?.*$/, "", t)
  if (t == "") return ""
  d = dirof(from)
  return norm((d == "" ? "" : d "/") t)
}
function out(c, p, d, fx) { gsub(/\t/, " ", d); gsub(/\t/, " ", fx); print "R\t" c "\t" p "\t" d "\t" fx }
function op(p, o, n, t) { print "O\t" p "\t" o "\t" n "\t" t }
function fmst(p) { return st[p] == "open" ? ((p in endl) ? "fm" : "unclosed") : "none" }
function val(p, k) { return ((p SUBSEP k) in has) ? kv[p, k] : "" }
function dkind(p) {
  if (p ~ /^ideas\/[^\/]+\/plan\.md$/) return "plan"
  if (p ~ /^ideas\//) return "idea"
  if (p ~ /^decisions\//) return "decision"
  if (p ~ /^ways\//) return "way"
  if (p ~ /^self\//) return "self"
  if (p ~ /^projects\//) return "project"
  if (p ~ /^journal\//) return "journal"
  if (p ~ /^knowledge\/wiki\/sources\//) return "source"
  if (p ~ /^knowledge\/wiki\/topics\//) return "topic"
  if (p ~ /^knowledge\/wiki\/entities\//) return "entity"
  if (p ~ /^knowledge\/wiki\/syntheses\//) return "synthesis"
  if (p ~ /^knowledge\/wiki\//) return "wiki"
  return ""
}
function derive(p, f,   s) {
  if (f == "id") {
    if (p ~ /^ideas\/I-[0-9]+-[0-9]+(-[^\/]*)?\//) { s = substr(p, 7); match(s, /^I-[0-9]+-[0-9]+/); return substr(s, 1, RLENGTH) }
    if (p ~ /^decisions\/D-[0-9]+-[0-9]+\.md$/) { s = base(p); sub(/\.md$/, "", s); return s }
    return ""
  }
  if (f == "title") return (p ~ /^self\// || !(p in head)) ? "" : head[p]
  if (f == "kind") return dkind(p)
  if (f == "visibility") return "private"
  if (f == "created") return (p in gc) ? gc[p] : ""
  if (f == "updated") return today
  if (f == "links") return "[]"
  return ""
}
# Value after this run: frontmatter value, else the derivable one.
function eff(p, f) { return ((p SUBSEP f) in has) ? kv[p, f] : ((p in isfile) && fmst(p) == "fm" && p !~ /^knowledge\/raw\// ? derive(p, f) : "") }
function cells(line, c, pad,   s, n, i) {
  s = trim(line); sub(/^\|/, "", s); sub(/\|$/, "", s)
  n = split(s, c, "|")
  for (i = 1; i <= n; i++) c[i] = trim(c[i])
  for (i = n + 1; i <= pad; i++) c[i] = ""
  return n < pad ? pad : n
}
function row(c, n,   s, i) { s = "|"; for (i = 1; i <= n; i++) s = s " " c[i] " |"; return s }
function nlinks(line,   n) { n = 0; while (match(line, /\]\(/)) { n++; line = substr(line, RSTART + 2) } return n }
function single(line) { return (line ~ /^[ \t]*\|/ || line ~ /^[ \t]*[-*+][ \t]/) && nlinks(line) == 1 }
function stagefile(d,   b) {
  b = "ideas/" d "/"
  if ((b "plan.md") in isfile) return b "plan.md"
  if ((b "spec.md") in isfile) return b "spec.md"
  if ((b "idea.md") in isfile) return b "idea.md"
  return ""
}
# Links in index lines: report missing targets (fixable when the line has one link).
function deadlinks(ix,   n, line, s, t, res, fx) {
  for (n = 1; n <= xn[ix]; n++) {
    line = xl[ix, n]; s = line
    while (match(s, /\]\([^)]*\)/)) {
      t = substr(s, RSTART + 2, RLENGTH - 3); s = substr(s, RSTART + RLENGTH)
      res = resolve(ix, t)
      if (res == "" || (res in exists)) continue
      if (single(line)) { out("index", ix, "line \"" t "\": no file (fixable)", "line \"" t "\": removed (no file)"); op(ix, "D", n, "") }
      else out("index", ix, "line \"" t "\": no file", "")
    }
  }
}
BEGIN {
  FS = "\t"; td = daynum(today)
  split("id title state kind visibility created updated source links", CANON, " ")
}
FILENAME == ARGV[1] { exists[$0] = 1; next }
FILENAME == ARGV[2] { nf++; file[nf] = $0; isfile[$0] = 1; next }
$1 == "F" { st[$2] = $3; next }
$1 == "E" { endl[$2] = $3; next }
$1 == "K" { if (!(($2 SUBSEP $3) in has)) { has[$2, $3] = 1; kv[$2, $3] = rest(3) } next }
$1 == "H" { head[$2] = rest(2); next }
$1 == "L" { r = resolve($2, rest(2)); if (r != "") { lk[$2, r] = 1; if (r != $2) inbound[r] = 1 } next }
$1 == "X" { xl[$2, $3] = rest(3); if ($3 + 0 > xn[$2]) xn[$2] = $3 + 0; next }
$1 == "G" { gc[$2] = $3; next }
END {
  for (i = 1; i <= nf; i++) {
    p = file[i]; b = base(p)
    if (p ~ /^knowledge\/wiki\// && b != "index.md") { nw++; wiki[nw] = p; iswiki[p] = 1 }
    if (b == "log.md" || b == "index.md" || b == "README.md" || b == "CLAUDE.md") continue
    s = fmst(p)
    # --- frontmatter
    if (p ~ /^knowledge\/raw\//) {
      if (s != "fm") { out("frontmatter", p, "no frontmatter (raw file, not fixed)", ""); continue }
      if (!((p SUBSEP "title") in has)) out("frontmatter", p, "missing title", "")
      if (!((p SUBSEP "source") in has) && !((p SUBSEP "url") in has)) out("frontmatter", p, "missing source (or url)", "")
      continue
    }
    if (s == "none") { out("frontmatter", p, "no frontmatter", ""); continue }
    if (s == "unclosed") { out("frontmatter", p, "frontmatter not closed", ""); continue }
    req = " title kind visibility created updated source links "
    if (p ~ /^(ideas|decisions)\//) req = req "id "
    if (p ~ /^ideas\//) req = req "state "
    nadd = 0
    for (j = 1; j <= 9; j++) {
      f = CANON[j]
      if (index(req, " " f " ") == 0 || ((p SUBSEP f) in has)) continue
      v = derive(p, f)
      if (v == "") { out("frontmatter", p, "missing " f, ""); continue }
      out("frontmatter", p, "missing " f " (fixable)", "added " f ": " v)
      print "M\t" p "\t" f ": " v; nadd++
    }
    if (nadd && ((p SUBSEP "updated") in has)) print "S\t" p
  }
  # --- stale and orphan
  for (i = 1; i <= nw; i++) {
    p = wiki[i]; u = val(p, "updated")
    if (isdate(u) && td - daynum(u) > 90) out("stale", p, "updated " u ", " (td - daynum(u)) " days ago", "")
    if (!(p in inbound)) out("orphan", p, "no inbound link", "")
  }
  # --- ideas/index.md
  ix = "ideas/index.md"
  if (ix in isfile) {
    for (i = 1; i <= nf; i++) {
      p = file[i]
      if (p !~ /^ideas\/I-[0-9]+-[0-9]+(-[^\/]*)?\//) continue
      d = substr(p, 7); sub(/\/.*$/, "", d)
      if (d in seenf) continue
      seenf[d] = 1; match(d, /^I-[0-9]+-[0-9]+/); id = substr(d, 1, RLENGTH)
      nfo++; fid[nfo] = id; folder[id] = d
    }
    last = 0
    for (n = 1; n <= xn[ix]; n++) {
      line = xl[ix, n]
      if (line !~ /^[ \t]*\|/) continue
      last = n
      if (line ~ /^[ \t|:-]*$/) continue
      nc = cells(line, c, 5)
      if (!match(c[1], /I-[0-9]+-[0-9]+/)) continue
      id = substr(c[1], RSTART, RLENGTH); rowseen[id] = 1
      if (!(id in folder)) { out("index", ix, "row " id ": no file (fixable)", "row " id ": removed (no file)"); op(ix, "D", n, ""); continue }
      d = folder[id]; ch = 0
      t = eff("ideas/" d "/idea.md", "title")
      if (t != "" && c[2] != t) { out("index", ix, "row " id ": title \"" c[2] "\" differs from file \"" t "\" (fixable)", "row " id ": title set to \"" t "\""); c[2] = t; ch = 1 }
      sf = stagefile(d); v = (sf == "") ? "" : val(sf, "state")
      if (v != "" && c[3] != v) { out("index", ix, "row " id ": state \"" c[3] "\" differs from file \"" v "\" (fixable)", "row " id ": state set to \"" v "\""); c[3] = v; ch = 1 }
      if (ch) op(ix, "R", n, row(c, nc))
    }
    for (k = 1; k <= nfo; k++) {
      id = fid[k]
      if (id in rowseen) continue
      d = folder[id]; t = eff("ideas/" d "/idea.md", "title")
      sf = stagefile(d); v = (sf == "") ? "" : val(sf, "state")
      if (t == "" || v == "") { out("index", ix, id ": no row", ""); continue }
      u = val("ideas/" d "/idea.md", "updated"); if (!isdate(u)) u = today
      out("index", ix, id ": no row (fixable)", id ": row added")
      r = "| [" id "](" d "/idea.md) | " t " | " v " |  | " u " |"
      if (last) op(ix, "A", last, r)
      else {
        if (!hdr[ix]) { op(ix, "Z", 0, "| ID | Title | State | Target | Updated |"); op(ix, "Z", 0, "|---|---|---|---|---|"); hdr[ix] = 1 }
        op(ix, "Z", 0, r)
      }
    }
  }
  # --- decisions/index.md
  ix = "decisions/index.md"
  if (ix in isfile) {
    last = 0
    for (n = 1; n <= xn[ix]; n++) {
      line = xl[ix, n]
      if (line !~ /^[ \t]*\|/) continue
      last = n
      if (line ~ /^[ \t|:-]*$/) continue
      nc = cells(line, c, 5)
      if (!match(c[1], /D-[0-9]+-[0-9]+/)) continue
      id = substr(c[1], RSTART, RLENGTH); drow[id] = 1; f = "decisions/" id ".md"
      if (!(f in isfile)) { out("index", ix, "row " id ": no file (fixable)", "row " id ": removed (no file)"); op(ix, "D", n, ""); continue }
      ch = 0
      v = val(f, "subject")
      if (v != "" && c[2] != v && index(c[2], v " ") != 1) { out("index", ix, "row " id ": subject \"" c[2] "\" differs from file \"" v "\" (fixable)", "row " id ": subject set to \"" v "\""); c[2] = v; ch = 1 }
      v = val(f, "gate")
      if (v != "" && c[3] != v) { out("index", ix, "row " id ": gate \"" c[3] "\" differs from file \"" v "\" (fixable)", "row " id ": gate set to \"" v "\""); c[3] = v; ch = 1 }
      v = val(f, "outcome")
      if (v != "" && c[4] != v) { out("index", ix, "row " id ": outcome \"" c[4] "\" differs from file \"" v "\" (fixable)", "row " id ": outcome set to \"" v "\""); c[4] = v; ch = 1 }
      if (ch) op(ix, "R", n, row(c, nc))
    }
    for (i = 1; i <= nf; i++) {
      p = file[i]
      if (p !~ /^decisions\/D-[0-9]+-[0-9]+\.md$/) continue
      id = base(p); sub(/\.md$/, "", id)
      if (id in drow) continue
      sj = val(p, "subject"); g = val(p, "gate"); o = val(p, "outcome"); cr = eff(p, "created")
      if (sj == "" || g == "" || o == "" || cr == "") { out("index", ix, id ": no row", ""); continue }
      out("index", ix, id ": no row (fixable)", id ": row added")
      r = "| [" id "](" id ".md) | " sj " | " g " | " o " | " cr " |"
      if (last) op(ix, "A", last, r)
      else {
        if (!hdr[ix]) { op(ix, "Z", 0, "| ID | Subject | Gate | Outcome | Date |"); op(ix, "Z", 0, "|---|---|---|---|---|"); hdr[ix] = 1 }
        op(ix, "Z", 0, r)
      }
    }
  }
  # --- knowledge/wiki/index.md
  ix = "knowledge/wiki/index.md"
  if (ix in isfile) {
    unf = 0; lastnb = 0
    for (n = 1; n <= xn[ix]; n++) {
      line = xl[ix, n]
      if (line ~ /[^ \t]/) lastnb = n
      if (line ~ /^## Unfiled[ \t]*$/) unf = n
      if (line !~ /^[ \t]*[-*+][ \t]/ || !match(line, /\[[^\]]*\]\([^)]*\)/)) continue
      ls = RSTART; m = substr(line, RSTART, RLENGTH)
      txt = m; sub(/\]\(.*$/, "", txt); txt = substr(txt, 2)
      t = m; sub(/^\[[^\]]*\]\(/, "", t); t = substr(t, 1, length(t) - 1)
      res = resolve(ix, t)
      if (res == "") continue
      if (!(res in exists)) {
        if (single(line)) { out("index", ix, "line \"" t "\": no file (fixable)", "line \"" t "\": removed (no file)"); op(ix, "D", n, "") }
        else out("index", ix, "line \"" t "\": no file", "")
        continue
      }
      if (!(res in iswiki)) continue
      tt = eff(res, "title")
      if (tt != "" && txt != tt) {
        out("index", ix, "line \"" t "\": text \"" txt "\" differs from title \"" tt "\" (fixable)", "line \"" t "\": text set to \"" tt "\"")
        op(ix, "R", n, substr(line, 1, ls) tt substr(line, ls + 1 + length(txt)))
      }
    }
    pos = 0
    if (unf) { pos = unf; for (n = unf + 1; n <= xn[ix]; n++) { if (xl[ix, n] ~ /^#/) break; if (xl[ix, n] ~ /[^ \t]/) pos = n } }
    started = 0
    for (i = 1; i <= nw; i++) {
      p = wiki[i]
      if ((ix SUBSEP p) in lk) continue
      tt = eff(p, "title"); kd = eff(p, "kind")
      if (tt == "" || kd == "") { out("index", ix, p ": no row", ""); continue }
      out("index", ix, p ": no row (fixable)", p ": row added under Unfiled")
      r = "- [" tt "](" substr(p, 16) ") (" kd ")"
      if (pos) op(ix, "A", pos, r)
      else {
        if (!started) { if (lastnb == xn[ix] && xn[ix] > 0) op(ix, "Z", 0, ""); op(ix, "Z", 0, "## Unfiled"); op(ix, "Z", 0, ""); started = 1 }
        op(ix, "Z", 0, r)
      }
    }
  }
  # --- projects/ and ways/ indexes: dead links; pages with no row (report only)
  if ("projects/index.md" in isfile) deadlinks("projects/index.md")
  if ("ways/index.md" in isfile) deadlinks("ways/index.md")
  if ("ways/private/index.md" in isfile) deadlinks("ways/private/index.md")
  for (i = 1; i <= nf; i++) {
    p = file[i]
    if (base(p) == "index.md") continue
    if (p ~ /^projects\//) ix = "projects/index.md"
    else if (p ~ /^ways\/public\//) ix = "ways/index.md"
    else if (p ~ /^ways\/private\//) ix = "ways/private/index.md"
    else continue
    if ((ix in isfile) && !((ix SUBSEP p) in lk)) out("index", ix, p ": no row", "")
  }
}'

awk -v today="$today" "$ANALYSE" "$tmp/exists" "$tmp/files" "$tmp/recs" > "$tmp/an"

emit() { LC_ALL=C sort -t "$TAB" -k1,1 -k2,2; }

if [ "$fix" = 0 ]; then
  awk -F '\t' '$1 == "R" { print $2 "\t" $3 "\t" $4 }' "$tmp/an" | emit
  if grep -q '^R' "$tmp/an"; then exit 1; fi
  exit 0
fi

# --- Fix ----------------------------------------------------------------------
# Frontmatter: add fields just before the closing "---", reset `updated`. The
# frontmatter is rewritten by awk (which stops at the closing line); the body
# is copied unchanged with tail and never parsed.
awk -F '\t' '$1 == "M" || $1 == "S" { print $2 }' "$tmp/an" | LC_ALL=C sort -u > "$tmp/fmfix"
while IFS= read -r f; do
  case $f in knowledge/raw/*) continue ;; esac
  end=$(awk 'NR == 1 && $0 != "---" { exit } NR > 1 && $0 == "---" { print NR; exit } NR > 200 { exit }' "$f")
  [ -n "$end" ] || continue
  P=$f awk -F '\t' '$1 == "M" && $2 == ENVIRON["P"] { s = $0; sub(/^[^\t]*\t[^\t]*\t/, "", s); print s }' "$tmp/an" > "$tmp/adds"
  ADDS=$tmp/adds TODAY=$today awk -v end="$end" '
    NR < end { if ($0 ~ /^updated:/) $0 = "updated: " ENVIRON["TODAY"]; print; next }
    { while ((getline a < ENVIRON["ADDS"]) > 0) print a; print; exit }' "$f" > "$tmp/new"
  tail -n +"$((end + 1))" "$f" >> "$tmp/new"
  cat "$tmp/new" > "$f"
done < "$tmp/fmfix"

# Index files: apply the line operations in one pass per file.
awk -F '\t' '$1 == "O" { print $2 }' "$tmp/an" | LC_ALL=C sort -u > "$tmp/ixfix"
while IFS= read -r f; do
  P=$f awk -F '\t' '$1 == "O" && $2 == ENVIRON["P"] { s = $0; sub(/^[^\t]*\t[^\t]*\t/, "", s); print s }' "$tmp/an" > "$tmp/ops"
  awk -F '\t' '
    FILENAME == ARGV[1] {
      t = $0; sub(/^[^\t]*\t[^\t]*\t/, "", t)
      if ($1 == "D") del[$2] = 1
      else if ($1 == "R") rep[$2] = t
      else if ($1 == "A") app[$2] = app[$2] t "\n"
      else if ($1 == "Z") z = z t "\n"
      next
    }
    { if (FNR in rep) print rep[FNR]; else if (!(FNR in del)) print; if (FNR in app) printf "%s", app[FNR] }
    END { printf "%s", z }' "$tmp/ops" "$f" > "$tmp/new"
  cat "$tmp/new" > "$f"
done < "$tmp/ixfix"

awk -F '\t' -v today="$today" '
  $1 == "R" && $5 != "" { print "fixed\t" $3 "\t" $5 }
  $1 == "R" && $5 == "" { print $2 "\t" $3 "\t" $4 }
  $1 == "S" { print "fixed\t" $2 "\tset updated: " today }' "$tmp/an" | emit
if awk -F '\t' '$1 == "R" && $5 == "" { found = 1 } END { exit !found }' "$tmp/an"; then exit 1; fi
exit 0
