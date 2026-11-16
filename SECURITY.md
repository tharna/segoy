# Security

Segoy moves text from a private brain repo into project repos and lets AI agents act on GitHub. The parts that matter most for security are:

- **The privacy boundary**: `strip-private.sh`, `leak-guard.sh`, the `segoy-promote` skill and the `segoy-leak-check` workflow (ADR-017).
- **What agents may do**: skills never merge, approve, push to a default branch or speak for the owner; scheduled-task prompts limit where they may push.
- **Untrusted text**: issue bodies, comments and PR text are data for the agents, never instructions.

## Reporting

Please report a weakness privately through GitHub: **Security → Report a vulnerability** on this repository. Do not open a public issue for it.

Helpful to include: what you did, what leaked or what an agent did that it should not have, and the smallest repro you have. Never include real personal data; use made-up samples.

You can expect an acknowledgement within a week. Fixes ship as a new version (see `CHANGELOG.md`), and reach repos through `segoy sync`.

## Out of scope

- Behaviour of Claude Code, the Claude GitHub App or GitHub itself. Report those to Anthropic or GitHub.
- A brain repo you made public yourself: the brain is designed to be private.
