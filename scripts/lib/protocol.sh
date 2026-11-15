#!/bin/sh
# protocol.sh — validate `segoy` blocks against docs/protocol.md (v1).
#
# Usage: protocol.sh FILE...      (use - for stdin)
#   Extracts every fenced block whose info string is `segoy` (a line that is
#   exactly ```segoy, closed by a line that is exactly ```), skipping anything
#   inside a four-backtick fence (documentation examples of the format), and
#   checks each one with jq.
# Exit status: 0 if every block is valid, 1 if any is not, 2 on usage error.
# A file without blocks is valid.

set -u

if [ $# -eq 0 ]; then
  echo "usage: protocol.sh FILE..." >&2
  exit 2
fi
if ! command -v jq >/dev/null 2>&1; then
  echo "protocol.sh: jq is required" >&2
  exit 2
fi

# jq program: print one error per line for the block on stdin; nothing if valid.
# shellcheck disable=SC2016  # $i and \(...) are jq syntax, not shell.
CHECKS='
def idea_ok: type == "string" and test("^I-[0-9]{8}-[0-9]+$");
def ts_ok: type == "string" and test("^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}(:[0-9]{2})?(\\.[0-9]+)?Z$");
def str_ok: type == "string" and length > 0;
def need(f; ok; msg): if (has(f) | not) then "missing field: \(f)"
                       elif (.[f] | ok) then empty
                       else "bad field \(f): \(msg)" end;
def opt(f; ok; msg): if (has(f) | not) then empty
                      elif (.[f] | ok) then empty
                      else "bad field \(f): \(msg)" end;
if type != "object" then "block is not a JSON object"
else
  need("v"; . == 1; "must be 1"),
  need("kind"; str_ok; "must be a non-empty string"),
  ( if (.kind | IN("question","answer","spec","plan","decision")) then empty
    else opt("idea"; idea_ok; "must look like I-<yyyymmdd>-<n>") end ),
  ( if .kind == "question" then
      need("idea"; idea_ok; "must look like I-<yyyymmdd>-<n>"),
      need("round"; type == "number" and . >= 1 and . == floor; "must be an integer >= 1"),
      need("questions"; type == "array" and length >= 1 and length <= 3; "must be an array of 1-3 questions"),
      ( (.questions // []) | if type == "array" then
          ( to_entries[] | .key as $i | .value |
            if type != "object" then "questions[\($i)] is not an object"
            else
              need("id"; str_ok; "must be a non-empty string"),
              need("text"; str_ok; "must be a non-empty string"),
              need("default"; type == "string"; "must be a string"),
              opt("options"; type == "array" and all(.[]; type == "string"); "must be an array of strings")
              | "questions[\($i)]: " + .
            end ),
          ( [ .[]? | objects | .id ] | if length != (unique | length) then "question ids must be unique" else empty end )
        else empty end )
    elif .kind == "answer" then
      need("idea"; idea_ok; "must look like I-<yyyymmdd>-<n>"),
      need("round"; type == "number" and . >= 1 and . == floor; "must be an integer >= 1"),
      need("answers"; type == "object" and all(.[]; type == "string"); "must be an object of strings"),
      opt("command"; IN("spec","plan","park","unpark","reject","defaults"); "unknown command"),
      opt("reason"; type == "string"; "must be a string")
    elif .kind == "run" then
      need("skill"; str_ok; "must be a non-empty string"),
      need("repo"; type == "string" and test("^[^/ ]+/[^/ ]+$"); "must be <owner>/<repo>"),
      need("started"; ts_ok; "must be an ISO 8601 UTC timestamp"),
      need("finished"; ts_ok; "must be an ISO 8601 UTC timestamp"),
      need("outcome"; IN("ok","asked","skipped","stopped","failed"); "must be ok|asked|skipped|stopped|failed"),
      need("next"; str_ok; "must be a non-empty string"),
      opt("session"; type == "string" and test("^https://"); "must be a URL"),
      opt("checks"; type == "object"; "must be an object")
    elif .kind == "spec" then
      need("idea"; idea_ok; "must look like I-<yyyymmdd>-<n>"),
      need("title"; str_ok; "must be a non-empty string"),
      need("target"; str_ok and (test("/") | not); "must be a repo name without owner, or none"),
      need("criteria"; type == "number" and . >= 1 and . == floor; "must be an integer >= 1"),
      need("open_questions"; type == "number" and . >= 0 and . == floor; "must be an integer >= 0"),
      need("private_blocks"; type == "number" and . >= 0 and . == floor; "must be an integer >= 0")
    elif .kind == "plan" then
      need("idea"; idea_ok; "must look like I-<yyyymmdd>-<n>"),
      need("summary"; str_ok; "must be a non-empty string"),
      need("assumptions"; type == "array"; "must be an array"),
      ( (.assumptions // []) | if type == "array" then
          ( to_entries[] | .key as $i | .value |
            if type != "object" then "assumptions[\($i)] is not an object"
            else
              need("text"; str_ok; "must be a non-empty string"),
              need("confidence"; IN("firm","likely","guess"); "must be firm|likely|guess"),
              need("source"; str_ok and (test("^(self|ways|decisions|ideas|knowledge|journal)/") | not); "must be owner-stated, brain, spec or a project path (never a brain path)")
              | "assumptions[\($i)]: " + .
            end )
        else empty end ),
      need("tasks"; type == "array" and length >= 1 and all(.[]; type == "object" and (.id | type == "string") and (.title | type == "string" and length > 0)); "must be a non-empty array of {id, title}"),
      need("size"; IN("S","M","L"); "must be S|M|L"),
      need("omitted_private"; type == "number" and . >= 0 and . == floor; "must be an integer >= 0"),
      need("checks"; type == "object" and .["leak-check"] == "pass"; "must include \"leak-check\": \"pass\"")
    elif .kind == "decision" then
      need("idea"; idea_ok; "must look like I-<yyyymmdd>-<n>"),
      need("gate"; IN("triage","spec","plan","impl","other"); "must be triage|spec|plan|impl|other"),
      need("outcome"; IN("approved","changed","rejected","parked"); "must be approved|changed|rejected|parked"),
      need("reason"; str_ok; "must be a non-empty string")
    elif (.kind | IN("impl","review")) then empty
    else "warning: unknown kind \(.kind) (ignored by readers)"
    end )
end
'

# extract FILE — print blocks as records: "@@BLOCK <line>" then the block's lines.
extract() {
  awk '
    /^````/ { outer = !outer; next }
    outer { next }
    !inblk && $0 == "```segoy" { inblk = 1; printf "@@BLOCK %d\n", NR; next }
    inblk && $0 == "```" { inblk = 0; print "@@END"; next }
    inblk { print }
    END { if (inblk) print "@@UNCLOSED" }
  ' "$1"
}

status=0
blocks=0
tmp=$(mktemp) || exit 2
trap 'rm -f "$tmp" "$tmp.b"' EXIT

for f in "$@"; do
  if [ "$f" = - ]; then
    cat > "$tmp.in" && f_name=stdin && src="$tmp.in"
  else
    [ -r "$f" ] || { echo "FAIL $f: cannot read"; status=1; continue; }
    f_name=$f && src=$f
  fi
  extract "$src" > "$tmp"
  line=0
  : > "$tmp.b"
  while IFS= read -r l; do
    case $l in
      "@@BLOCK "*) line=${l#@@BLOCK }; : > "$tmp.b" ;;
      "@@UNCLOSED") echo "FAIL $f_name:$line: block not closed"; status=1 ;;
      "@@END")
        blocks=$((blocks + 1))
        if ! jq -e . "$tmp.b" >/dev/null 2>&1; then
          echo "FAIL $f_name:$line: not valid JSON"; status=1; continue
        fi
        kind=$(jq -r '.kind? // "?"' "$tmp.b" 2>/dev/null)
        errs=$(jq -r "$CHECKS" "$tmp.b" 2>&1)
        if [ -z "$errs" ]; then
          echo "ok   $f_name:$line: $kind"
        else
          printf '%s\n' "$errs" | while IFS= read -r e; do
            case $e in
              warning:*) echo "WARN $f_name:$line: ${e#warning: }" ;;
              *) echo "FAIL $f_name:$line: $kind: $e" ;;
            esac
          done
          printf '%s\n' "$errs" | grep -qv '^warning:' && status=1
        fi
        ;;
      *) printf '%s\n' "$l" >> "$tmp.b" ;;
    esac
  done < "$tmp"
done
rm -f "$tmp.in"

echo "$blocks block(s) checked"
exit "$status"
