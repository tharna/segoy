#!/bin/sh
# leak-guard.sh — find content that must not leave a private brain.
#
# Usage: leak-guard.sh [--denylist FILE] [--exclude GLOB]... [--skip RULE]... FILE...   (- for stdin)
#
# Fails on:
#   - private block markers (<!-- private --> / <!-- /private -->) still present;
#   - generic secrets and personal data: e-mail addresses, access tokens and
#     API keys, private-key blocks, phone numbers in international form,
#     Finnish personal identity codes, IBANs;
#   - any term in the denylist (one extended regex per line, case-insensitive,
#     lines starting with # ignored).
# A line containing "leak-guard: allow" is skipped (for docs that must show a
# pattern). Allowed e-mail forms: example.com/org/net, noreply addresses, git@github.com.
# --skip RULE turns one rule off by name (for example "private block marker" in
# a repo that documents the marker format).
#
# Output: one line per hit, "LEAK <file>:<line>: <rule>". The matching text is
# never printed, and denylist hits name the denylist line number, not the term.
# Exit status: 0 clean, 1 leaks found, 2 usage error.

set -u

denylist='' excludes='' skips=''
while [ $# -gt 0 ]; do
  case $1 in
    --denylist) shift; denylist=${1:-} ;;
    --exclude) shift; excludes="$excludes
${1:-}" ;;
    --skip) shift; skips="$skips
${1:-}" ;;
    --) shift; break ;;
    -?*) echo "leak-guard: unknown option $1" >&2; exit 2 ;;
    *) break ;;
  esac
  shift
done
[ $# -gt 0 ] || { echo "usage: leak-guard.sh [--denylist FILE] [--exclude GLOB]... [--skip RULE]... FILE..." >&2; exit 2; }
if [ -n "$denylist" ] && [ ! -r "$denylist" ]; then
  echo "leak-guard: cannot read denylist $denylist" >&2; exit 2
fi

# name<TAB>extended regex (case-sensitive; denylist terms are matched case-insensitively).
RULES='private block marker	<!--[[:space:]]*/?private[[:space:]]*-->
e-mail address	[A-Za-z0-9._%+-]+@[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)*\.[A-Za-z]{2,}
GitHub token	(gh[pousr]_[A-Za-z0-9]{30,}|github_pat_[A-Za-z0-9_]{20,})
Anthropic API key	sk-ant-[A-Za-z0-9_-]{20,}
API secret key	sk-[A-Za-z0-9]{32,}
AWS access key	AKIA[0-9A-Z]{16}
Google API key	AIza[0-9A-Za-z_-]{35}
Slack token	xox[abprs]-[A-Za-z0-9-]{10,}
private key block	-----BEGIN [A-Z ]*PRIVATE KEY-----
phone number	\+[0-9]{1,3}[ -]?\(?[0-9]{1,4}\)?([ -]?[0-9]{2,4}){2,4}
Finnish personal identity code	(^|[^0-9])[0-3][0-9][01][0-9][0-9]{2}[-+A-FU-Y][0-9]{3}[0-9A-Y]([^0-9A-Za-z]|$)
IBAN	(^|[^A-Z0-9])[A-Z]{2}[0-9]{2} ?[0-9]{4} ?[0-9]{4} ?[0-9]{4}( ?[0-9A-Z]{1,4}){0,4}([^A-Za-z0-9]|$)'

# Lines that may legitimately match the e-mail rule.
EMAIL_OK='(noreply@|no-reply@|@users\.noreply\.github\.com|@example\.(com|org|net)|^git@github\.com)'

excluded() {
  printf '%s\n' "$excludes" | while IFS= read -r g; do
    [ -n "$g" ] || continue
    # shellcheck disable=SC2254  # the glob is the pattern
    case $1 in $g) echo yes; break ;; esac
  done
}

hits=0
scan() {
  label=$1 src=$2
  printf '%s\n' "$RULES" | while IFS="$(printf '\t')" read -r name re; do
    if printf '%s\n' "$skips" | grep -qxF "$name"; then continue; fi
    grep -nE -- "$re" "$src" 2>/dev/null | grep -v 'leak-guard: allow' | while IFS=: read -r ln rest; do
      if [ "$name" = "e-mail address" ]; then
        # Report only if some address on the line is not an allowed one.
        printf '%s\n' "$rest" | grep -oE '[A-Za-z0-9._%+-]+@[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)*\.[A-Za-z]{2,}' \
          | grep -qvE "$EMAIL_OK" || continue
      fi
      echo "LEAK $label:$ln: $name"
    done
  done
  if [ -n "$denylist" ]; then
    n=0
    while IFS= read -r term || [ -n "$term" ]; do
      n=$((n + 1))
      case $term in ''|'#'*) continue ;; esac
      grep -niE -- "$term" "$src" 2>/dev/null | grep -v 'leak-guard: allow' | cut -d: -f1 | while IFS= read -r ln; do
        echo "LEAK $label:$ln: denylist line $n"
      done
    done < "$denylist"
  fi
}

tmp=$(mktemp) || exit 2
trap 'rm -f "$tmp" "$tmp.in"' EXIT
for f in "$@"; do
  if [ "$f" = - ]; then
    cat > "$tmp.in"; scan stdin "$tmp.in"
  elif [ -n "$(excluded "$f")" ]; then
    continue
  elif [ -f "$f" ]; then
    scan "$f" "$f"
  else
    echo "leak-guard: cannot read $f" >&2; exit 2
  fi
done > "$tmp"

hits=$(grep -c '^LEAK ' "$tmp")
cat "$tmp"
if [ "$hits" -gt 0 ]; then
  echo "leak-guard: $hits finding(s)" >&2
  exit 1
fi
exit 0
