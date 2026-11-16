---
id: I-20261116-1
title: segoy-plan states that an init-only repo counts as new (PoC needed)
kind: idea
state: specced
visibility: shareable
created: 2026-11-16
updated: 2026-11-16
source: promoted
links: []
---
# Spec: segoy-plan states that an init-only repo counts as new (PoC needed)

## Problem
The PoC-first rule applies to ideas that target a new repository. `segoy-plan` step 4 does not say whether a repo that holds only the init scaffold, with no commits of its own, counts as new. The behaviour is correct today (it counts as new) but implicit.

## Users and context
Agents running `segoy-plan`, and the owner reading its plans.

## Outcomes
- `segoy-plan` step 4 says explicitly that a repo that is missing, or has only the init scaffold and no commits of its own, counts as a new project and so needs a PoC as first milestone.

## In scope
- One wording change in `segoy-plan` step 4 in the Segoy repo.

## Out of scope
- Any change in planning behaviour.
- Changes to other skills or to the brain.

## Acceptance criteria
1. Given `segoy-plan` step 4, when it is read, then it states that an init-only repo with no commits of its own counts as a new project and requires a PoC first milestone.
2. Given a target repo with only the init scaffold, when a plan is drafted, then its first milestone is a PoC (unchanged behaviour).
3. Given a target repo with commits of its own, when a plan is drafted, then no PoC milestone is required (unchanged behaviour).
4. Given the change, when the diff is reviewed, then only wording in `segoy-plan` changes.

## Constraints
- Follows DRY, YAGNI and KISS.
- Skills change in Segoy and reach the brain through `segoy sync`.

## Open questions
- none

## Assumptions
- The PoC rule applies only to ideas targeting a new repo (firm, owner-stated)
- "New" means repo missing or init-only (firm, owner-stated)
- This is a wording clarification, not a behaviour change (firm, owner-stated)
