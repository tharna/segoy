---
id: I-20261115-5
title: PoC first for project-sized ideas
kind: idea
state: specced
visibility: shareable
created: 2026-11-15
updated: 2026-11-15
source: promoted
links: []
---
# Spec: PoC first for project-sized ideas

## Problem
Ideas that become their own project go straight from spec to a full plan. Risky assumptions are then found late, after much work.

## Users and context
The owner and the agents that write specs and plans. It applies whenever an idea's target is a new repository.

## Outcomes
- Plans for new-project ideas start with a minimal proof of concept.
- The rule is written down once, where agents read it.

## In scope
- One rule in the public ways of working: plans for ideas targeting a new repo make a simple PoC their first milestone.
- A short definition of the PoC: minimal, aimed at the riskiest assumption.

## Out of scope
- Changing Segoy's flow or skills.
- Applying the rule to ideas that target an existing repo.
- Building any PoC.

## Acceptance criteria
1. Given the public ways folder, when it is read, then one bullet states that plans for new-repo ideas have a PoC as first milestone, with a source and date.
2. Given a spec whose target is a new repo, when its plan is drafted, then the first milestone is titled as a PoC and names the assumption it tests.
3. Given a spec whose target is an existing repo or `none`, when its plan is drafted, then no PoC milestone is required.
4. Given the PoC milestone, when reviewed, then its scope fits a single short task with no feature beyond the tested assumption.

## Constraints
- Follows DRY, YAGNI and KISS.
- No change to Segoy.

## Open questions
- Should the PoC be skippable when the owner says so? (proposed default: yes, by a comment on the spec PR)

## Assumptions
- The rule lives in the public ways of working (firm, owner-stated)
- "Worth its own project" means the target is a new repo (likely, spec)
- The PoC is the first plan milestone, not a step before the spec (likely, spec)
