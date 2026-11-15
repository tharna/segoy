---
id: ADR-019
title: Agent commits keep the Claude identity
state: accepted
created: 2026-11-15
---
# ADR-019: Agent commits keep the Claude identity

## Context
Decision 10 assumed agent commits would appear as the owner. Spike S11 found that in cloud sessions and scheduled tasks the git author and committer are `Claude <noreply@anthropic.com>`, while issues, comments and PRs made through the GitHub tools appear as the owner.

## Decision
Keep the default. Skills do not change `git config user.*`.

## Consequences
- Agent commits are easy to tell apart from the owner's own commits in history and blame.
- PRs, comments and merges are still the owner's, so permissions and notifications behave as for the owner.
- No personal identity needs to be in any config.
- Updates decision 10 in `docs/README.md`.

## Revisit when
The owner wants commits attributed to them (for example for contribution graphs). Then add an optional `commit_identity` to `.segoy/config.yml`.
