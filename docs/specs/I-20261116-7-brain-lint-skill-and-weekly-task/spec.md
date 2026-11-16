---
id: I-20261116-7
title: Brain-lint skill and weekly task
kind: idea
state: specced
visibility: shareable
created: 2026-11-16
updated: 2026-11-16
source: promoted
links: []
---
# Spec: Brain-lint skill and weekly task

## Problem
Nothing checks the brain's health. Wiki pages can contradict each other, become orphaned or stale, files can lack required frontmatter, indexes can drift from the files they list, and ideas can sit in one state indefinitely. These problems are found only by accident.

## Users and context
The brain owner, reading on a phone or desktop. The check runs unattended once a week; the owner reads one report issue and reviews at most one fix PR.

## Outcomes
- Once a week the owner gets one report issue listing every finding, or no issue when the brain is clean.
- Purely mechanical problems arrive as one fix PR; everything else is only reported.
- Contradictions are surfaced for the owner and never resolved by the agent.

## In scope
- A skill `segoy-lint` and a scheduled task `brain-lint` in the Segoy kit, vendored through `segoy sync`.
- Checks:
  1. contradictions between wiki pages (and between wiki and `ways/`/`decisions/`), flagged only;
  2. orphan wiki pages (no inbound link from an index or other page);
  3. stale wiki pages (no `updated` change for more than 90 days);
  4. files missing required frontmatter fields;
  5. index drift (index rows without a file, files without a row, mismatched titles or states);
  6. ideas stuck in a state: open idea, not done/parked/rejected, latest `state:*` label event more than 14 days old.
- One report issue per run titled `Lint <date>`.
- One fix PR per run, limited to adding missing frontmatter fields and correcting index rows.

## Out of scope
- Resolving contradictions, deleting or rewriting wiki pages, archiving stale or orphan pages.
- Changing idea states or labels.
- Writing to any repository other than the brain; merging, approving or pushing to the default branch.

## Acceptance criteria
1. Given the task definition, when inspected, then it names the `segoy-lint` skill, a weekly schedule and the small (lint) model.
2. Given an open issue labelled `segoy:paused`, when the skill runs, then it posts and changes nothing.
3. Given a brain with no findings, when the skill runs, then it opens no issue and no PR.
4. Given any findings, when the skill runs, then it opens exactly one issue titled `Lint <date>` listing each finding by check category with the file path, ending with a `run` block.
5. Given two wiki pages that make conflicting claims, when the skill runs, then the report flags both with the conflicting statements quoted by location, and no file is changed to resolve it.
6. Given a wiki page with no inbound link, when the skill runs, then the report lists it as an orphan and the page is not changed or removed.
7. Given a wiki page whose `updated` date is more than 90 days old, when the skill runs, then the report lists it as stale.
8. Given a file lacking a required frontmatter field, when the skill runs, then the fix PR adds the field with a value derivable from the file (otherwise the report lists it) and sets `updated` to the run date.
9. Given an index row missing, extra or inconsistent with its file, when the skill runs, then the fix PR corrects the row.
10. Given an idea whose latest state change is more than 14 days old and which is not done, parked or rejected, when the skill runs, then the report lists it with its state and age.
11. Given findings that are not frontmatter or index drift, when the skill runs, then the fix PR contains no change for them.
12. Given a run with fixes, when the PR is created, then it is one PR labelled for lint, its body ends with a `run` block, and the agent has not merged, approved or pushed to the default branch.
13. Given any run, when it finishes, then nothing from `self/` appears in the issue or PR beyond file paths, and the shareable parts pass the leak check.
14. Given the implementation, when reviewed, then it is a single PR in the Segoy repo including the skill, the task definition and checks covering criteria 1–13.

## Constraints
- Follows the Segoy protocol (`segoy` blocks, labels carry state, one `state:*` per issue).
- Runs on the lint-class (small) model; checks that need judgement (contradictions) must degrade to "flag with evidence" rather than guess.
- Must fit one implementation PR.

## Open questions
- Which weekday and time should the task run? (proposed default: Saturday 18:00 Europe/Helsinki, so it precedes the Sunday weekly review)
- Should an existing open `Lint` issue be updated instead of opening a new one? (proposed default: open a new issue, close the previous one as completed)

## Assumptions
- Mechanical fixes are limited to missing frontmatter and index drift (firm, owner-stated)
- Wiki page staleness threshold is 90 days (firm, owner-stated)
- "Stuck" follows the weekly review rule, 14 days (likely, spec)
- Report issue is titled `Lint <date>` (likely, spec)
- Lint runs on the small model (firm, brain)
