#!/bin/sh
# check-leak-guard.sh — tests for strip-private.sh and leak-guard.sh (T2.2, T2.4).
set -u
LG=kit/common/.claude/scripts/leak-guard.sh
SP=kit/common/.claude/scripts/strip-private.sh
F=tests/fixtures/promote
T=$(mktemp -d) || exit 2
trap 'rm -rf "$T"' EXIT
fail=0
ok()  { echo "pass  $1"; }
bad() { echo "FAIL  $1"; fail=1; }
t()   { d=$1; shift; if "$@" >/dev/null 2>&1; then ok "$d"; else bad "$d"; fi; }
tn()  { d=$1; shift; if "$@" >/dev/null 2>&1; then bad "$d"; else ok "$d"; fi; }

# --- strip-private
$SP "$F/brain-spec.md" > "$T/clean.md" 2> "$T/strip.err"
t  "strip: succeeds" test -s "$T/clean.md"
t  "strip: reports 3 removed blocks" grep -q "removed 3 private block" "$T/strip.err"
tn "strip: no markers left" grep -q "private -->" "$T/clean.md"
tn "strip: no private text left" grep -qiE "Zyxwvut|Kuusikatu|nightjar|budget|someone@" "$T/clean.md"
t  "strip: public text kept" grep -q "Adding an item takes under ten seconds." "$T/clean.md"
t  "strip: inline block removed, rest of line kept" grep -qx -- "- Adding an item takes under ten seconds. " "$T/clean.md"
t  "strip: frontmatter kept" grep -q "^id: I-20260101-1$" "$T/clean.md"
printf 'a\n<!-- private -->\nsecret\n' > "$T/unclosed.md"
tn "strip: unclosed block refused" $SP "$T/unclosed.md"
t  "strip: refusal prints nothing" sh -c "! $SP '$T/unclosed.md' 2>/dev/null | grep -q ."
printf 'a\n<!-- /private -->\n' > "$T/stray.md"
tn "strip: stray closing marker refused" $SP "$T/stray.md"

# --- leak-guard on the T2.4 fixture
tn "guard: raw brain spec fails" $LG --denylist "$F/denylist.txt" "$F/brain-spec.md"
t  "guard: stripped spec passes (generic + denylist)" $LG --denylist "$F/denylist.txt" "$T/clean.md"
$LG --denylist "$F/denylist.txt" "$F/brain-spec.md" > "$T/raw.out" 2>&1
t  "guard: reports private markers" grep -q "private block marker" "$T/raw.out"
t  "guard: reports denylist by line number" grep -q "denylist line 2" "$T/raw.out"
t  "guard: reports e-mail" grep -q "e-mail address" "$T/raw.out"
tn "guard: never prints the secret" grep -qiE "Zyxwvut|Kuusikatu|someone@" "$T/raw.out"

# A denylisted term outside any private block survives stripping and must be caught.
printf -- '- Built for Zyxwvut.\n' >> "$T/clean.md"
tn "guard: denylist term outside private block caught" $LG --denylist "$F/denylist.txt" "$T/clean.md"

# --- generic rules (secrets assembled here, never stored in the repo)
gh="gh""p_"$(printf 'a%.0s' $(seq 1 36))
ant="sk-""ant-"$(printf 'b%.0s' $(seq 1 30))
aws="AK""IA"$(printf 'C%.0s' $(seq 1 16))
mail="owner""@""realmail"".fi"
phone="+3""58 40 123"" 4567"
hetu="1310""52-308""T"
iban="FI2""1 1234 5600"" 0007 85"
for case in "e-mail address|mail me at $mail" "GitHub token|token $gh" "Anthropic API key|key $ant" \
            "AWS access key|$aws" "private key block|-----BEGIN RSA PRIVATE"" KEY-----" \
            "phone number|call $phone" "Finnish personal identity code|hetu $hetu" \
            "IBAN|$iban"; do
  rule=${case%%|*} text=${case#*|}
  printf '%s\n' "$text" > "$T/g.md"
  if $LG "$T/g.md" 2>/dev/null | grep -q "$rule"; then ok "guard rule: $rule"; else bad "guard rule: $rule"; fi
done
for text in "noreply@anthropic.com" "123+456@users.noreply.github.com" "user@example.com" "ADR-015 and ADR-022" \
            "version 1.2.3 build 20260101" "I-20260101-1" "phone: <your number>" "see leak-guard: allow $mail"; do
  printf '%s\n' "$text" > "$T/ok.md"
  if $LG "$T/ok.md" >/dev/null 2>&1; then ok "guard allows: $text"; else bad "guard allows: $text"; fi
done
t  "guard allows: git@github.com URL" sh -c "echo 'git@github.com:o/r.git' | $LG -"
t  "guard: --skip turns a rule off" $LG --skip "private block marker" --skip "e-mail address" --denylist /dev/null "$F/brain-spec.md"
t  "guard: whole Segoy repo is clean (docs may show markers)" sh -c "git ls-files | grep -v '^tests/fixtures/promote/' | xargs $LG --skip 'private block marker'"
t  "guard: stdin works" sh -c "echo clean text | $LG -"
t  "guard: --exclude skips a file" $LG --exclude "*/raw.out" --exclude "$F/*" "$F/brain-spec.md"
tn "guard: unknown option is a usage error" $LG --nope x

exit $fail
