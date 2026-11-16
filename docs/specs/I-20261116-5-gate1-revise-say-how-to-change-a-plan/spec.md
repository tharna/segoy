---
id: I-20261116-5
title: Gate 1 revise - say how to change a plan
kind: task
state: specced
visibility: shareable
created: 2026-11-16
updated: 2026-11-16
source: promoted
links: []
---
# Spec: Gate 1 revise - say how to change a plan

## Problem
On a `segoy:plan` (Gate 1) PR, commenting and adding the `answered` label starts nothing: `project-implement-pr` exits because the implement skill only revises `segoy:impl` PRs. Yet `docs/workflows.md` says the implement task handles Gate 1 revisions, and the Gate 1 PR text invites the owner to comment. The owner waits for a response that never comes.

## Users and context
The owner reviewing a Gate 1 plan PR in a project repo and wanting changes to the plan.

## Outcomes
- The Gate 1 PR text tells the owner how to change a plan: edit `plan.md` in the PR, or close the PR to replan.
- `docs/workflows.md` describes the same two paths and no longer claims comment plus `answered` revises a plan.

## In scope
- Reword the Gate 1 PR body template in the promote skill.
- Reword the Gate 1 revise description in `docs/workflows.md`.
- Reword any other place in the kit that restates the Gate 1 revise path.

## Out of scope
- A plan-revision mode (the plan skill rewriting `plan.md` from a comment).
- Changing Gate 2 (`segoy:impl`) revise behaviour.
- Changing what closing a Gate 1 PR does.

## Acceptance criteria
1. Given a new Gate 1 PR body generated from the promote template, when read, then it says to edit `plan.md` in the PR or close the PR to replan, and does not tell the owner to comment and add `answered`.
2. Given `docs/workflows.md`, when its Gate 1 section is read, then it describes the same two paths and does not say the implement task revises a `segoy:plan` PR.
3. Given a search of the kit for the old Gate 1 revise wording, when run, then no occurrence remains.
4. Given the Gate 2 revise text, when compared before and after, then it is unchanged.
5. Given the changed files, when the leak check runs, then it passes.

## Constraints
- The change is made in the Segoy kit, not in the brain.
- Wording only; no new modes, labels or tasks.

## Open questions
- none

## Assumptions
- Wording-only option, not plan revision, because it is the smaller change (likely, owner-stated)
- Closing a Gate 1 PR already leads to replan (firm, brain)
