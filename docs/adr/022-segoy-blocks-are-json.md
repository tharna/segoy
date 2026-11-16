---
id: ADR-022
title: segoy blocks contain JSON, not YAML
state: accepted
created: 2026-11-15
---
# ADR-022: `segoy` blocks contain JSON, not YAML

## Context
ADR-012 made the agent–app contract labels plus `segoy` blocks in comments and PR bodies, with YAML content. Writing the protocol (M1, T1.3a) showed a problem: Segoy's scripts are POSIX shell, `git`, `gh` and `jq` only (ADR-003), and none of them can validate YAML. A validator would need Python or `yq`, or a hand-written shell parser that would be fragile.

## Decision
- A `segoy` block is a fenced code block with the info string `segoy` containing exactly one JSON object (`docs/protocol.md` §3).
- `protocol.sh` (in `kit/common/.claude/scripts/` since M4, so every repo has it) validates blocks with `jq`.
- Labels for state, and the rest of ADR-012, are unchanged.

## Consequences
- Strict validation with no new dependency. Models emit JSON reliably, and the app parses it with kotlinx.serialization directly.
- Blocks are slightly less pleasant to read in the GitHub UI. This matters little, because every block repeats prose that sits right above it.
- Amends ADR-012.

## Revisit when
The scripts gain a language with a YAML parser (ADR-003 revisited).
