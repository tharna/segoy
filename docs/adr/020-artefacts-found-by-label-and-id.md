---
id: ADR-020
title: Artefacts are found by label and idea ID, not by branch name
state: accepted
created: 2026-11-15
---
# ADR-020: Artefacts are found by label and idea ID, not by branch name

## Context
The conventions name branches `claude/<kind>-<id>-<slug>`. Spike S11 found that each cloud run is given a random `claude/<words>` branch per repo and instructed to push only there. A run may decline to create a differently named branch.

## Decision
- Branch names are best effort. Skills ask for the conventional name, and accept the assigned branch if that is what the run can push to.
- Every pipeline PR is identified by its **label** (`segoy:<kind>`) and the **idea ID in its title** (`… (I-20260101-1)`). Skills, Otak, triggers and the weekly review use these, never the branch name.
- PR triggers filter on labels, never on head branch.

## Consequences
- Branch lists in GitHub look less tidy.
- A skill that looks for an existing PR for an idea searches by label and title, which works whatever the branch is called.

## Revisit when
Tasks can be told which branch name to use.
