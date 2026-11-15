---
id: ADR-015
title: Only human actions start tasks
state: accepted
created: 2026-11-15
---
# ADR-015: Only human actions start tasks

## Context
Spike S3 (`spikes-2026-11.md`) found that GitHub events caused through Claude's own GitHub tools (an issue, a label, a comment, a PR) do not start scheduled tasks, even though they appear under the owner's account. Events the owner causes by hand do: issue opened, issue labeled, PR merged. Issue comments start nothing, whoever writes them.

## Decision
- The pipeline is driven only by owner actions: capture (open an issue), answer (label, see ADR-016), approve a spec (merge in the brain), Gate 1 (merge in the project), Gate 2 (merge in the project).
- An agent never relies on its own label, comment or PR to start the next step. A hand-off between agents happens inside one run (for example `plan` then `promote` in `brain-plan-promote`), or waits for the next owner action or a scheduled sweep.
- Skills may still set labels for state and for Otak; they just don't expect a trigger from them.

## Consequences
- No trigger loops are possible from agent activity, so a skill's own comments are safe.
- An idea moves only when the owner acts or a scheduled task runs. That matches the two-gate design, but states that change without an owner action (for example `building` after a Gate 1 merge, seen from the brain) are updated by the next brain run or by the weekly review, not instantly.

## Revisit when
The platform documents or changes this behaviour, or the trigger layer is replaced (ADR-021).
