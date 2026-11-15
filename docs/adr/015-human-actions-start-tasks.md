---
id: ADR-015
title: Only human actions start tasks
state: accepted (amended 2026-11-15 for labels)
created: 2026-11-15
---
# ADR-015: Only human actions start tasks

## Context

> **Amended 2026-11-15 (M1 staging).** Labels added through Claude's GitHub tools **do** start tasks; only issues opened that way do not, and comments never do. See "Amendment" below.

Spike S3 (`spikes-2026-11.md`) found that GitHub events caused through Claude's own GitHub tools (an issue, a label, a comment, a PR) do not start scheduled tasks, even though they appear under the owner's account. Events the owner causes by hand do: issue opened, issue labeled, PR merged. Issue comments start nothing, whoever writes them.

## Decision
- The pipeline is driven only by owner actions: capture (open an issue), answer (label, see ADR-016), approve a spec (merge in the brain), Gate 1 (merge in the project), Gate 2 (merge in the project).
- An agent never relies on its own label, comment or PR to start the next step. A hand-off between agents happens inside one run (for example `plan` then `promote` in `brain-plan-promote`), or waits for the next owner action or a scheduled sweep.
- Skills may still set labels for state and for Otak; they just don't expect a trigger from them.

## Consequences
- No trigger loops are possible from agent activity, so a skill's own comments are safe.
- An idea moves only when the owner acts or a scheduled task runs. That matches the two-gate design, but states that change without an owner action (for example `building` after a Gate 1 merge, seen from the brain) are updated by the next brain run or by the weekly review, not instantly.

## Amendment (2026-11-15, M1 staging)
Observed in the scratch brain:

| Event | Started a task? |
|---|---|
| The `segoy-respond` run added `state:triaged` to an issue | yes: `brain-respond` fired 2 s later |
| A session added a throwaway label to an issue through Claude's token | yes: `brain-respond` fired 3 s later |
| A session opened an issue (spike S3) | no |
| Any comment (spike S3) | no |

So the rule is narrower than first written: **issues opened by agents** and **all comments** start nothing, but **labels added by agents do fire `issues.labeled` triggers**. Consequences:
- Every label a skill sets fires every `issues.labeled` task on that repo. Tasks on `issues.labeled` must **filter on the label they care about** (the trigger form offers a Filter for issue events): `brain-respond` filters on `answered`. Agents never add `answered`, so they cannot start `brain-respond`.
- The skills' preconditions stay the second line of defence: an unfiltered run exits quietly.
- Agent-to-agent hand-off by label is technically possible. Segoy does not use it, to keep "only the owner moves an idea forward" (the decision above stands), and because it risks loops.
- Agent actions are recognisable in an issue's events: they carry `performed_via_github_app: claude`; the owner's own actions do not.

## Revisit when
The platform documents or changes this behaviour, or the trigger layer is replaced (ADR-021).
