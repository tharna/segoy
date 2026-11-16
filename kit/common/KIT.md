# kit/common

Vendored into every repo (brain and projects):

- `.claude/scripts/strip-private.sh`: removes `<!-- private -->` blocks; used by `segoy-promote`.
- `.claude/scripts/leak-guard.sh`: generic secret and personal-data patterns plus an optional denylist; used by `segoy-promote` (with the brain's denylist) and by project CI (generic only).
- `.claude/scripts/protocol.sh`: validates `segoy` blocks against `docs/protocol.md`; every skill that posts or writes `segoy` blocks runs it on the text first and posts only if it exits 0 ("Check blocks before posting").
- `.claude/skills/segoy-sync/`: the kit-sync task's skill; it runs `scripts/segoy sync --pr` from a Segoy checkout (M4).

There is deliberately **no hook** here. A brain legitimately holds personal data, so a commit hook would block normal brain work. Project repos get the hook wiring from `kit/project` (M3). See ADR-017 and architecture §5.
