#!/bin/sh
# check-history.sh — `segoy doctor --history` (T4.3). Run from the repo root.
set -u
S=$(pwd)/scripts/segoy
T=$(mktemp -d) || exit 2
trap 'rm -rf "$T"' EXIT
fail=0
ok()  { echo "pass  $1"; }
bad() { echo "FAIL  $1"; fail=1; }

# Sample values are assembled at run time so this file itself stays clean.
at=@
mail="someone${at}mailbox.test"
term="Zorblax"
git init -q "$T/r"
g() { git -C "$T/r" -c user.name=t -c user.email=t.invalid "$@"; }
printf 'contact: %s\n' "$mail" > "$T/r/notes.md"
g add notes.md && g commit -qm "first"
printf 'clean\n' > "$T/r/notes.md"
g commit -qam "second: met $term"
printf '%s\n' "$term" > "$T/deny.txt"

"$S" doctor --history "$T/r" > "$T/out" 2>&1
st=$?
if [ "$st" -eq 1 ]; then ok "history finding fails the check"; else bad "history finding fails the check (exit $st)"; fi
if grep -q '^LEAK notes.md@[0-9a-f]\{7\}:1: e-mail address' "$T/out"; then ok "old file version found, path and blob named"; else bad "old file version found"; fi
if grep -qF "$mail" "$T/out"; then bad "matched text never printed"; else ok "matched text never printed"; fi

(cd "$T" && "$S" doctor --history --denylist deny.txt r) > "$T/out2" 2>&1
if grep -q '^LEAK commit-messages:[0-9]*: denylist line 1' "$T/out2"; then ok "commit message checked with a relative denylist"; else bad "commit message checked with a relative denylist"; fi
if grep -qF "$term" "$T/out2"; then bad "denylist term never printed"; else ok "denylist term never printed"; fi

printf 'clean\n' > "$T/c.md"; git init -q "$T/clean"; git -C "$T/clean" -c user.name=t -c user.email=t.invalid commit -q --allow-empty -m "empty"
if "$S" doctor --history "$T/clean" > /dev/null 2>&1; then ok "clean history passes"; else bad "clean history passes"; fi
exit "$fail"
