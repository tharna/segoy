---
id: I-20261116-3
title: Weekly review - no "proposed" marker in ways bullets
kind: task
state: specced
visibility: shareable
created: 2026-11-16
updated: 2026-11-16
source: promoted
links: []
---
# Spec: Weekly review - no "proposed" marker in ways bullets

## Problem
The weekly-review skill marks proposed `ways/` bullets with "proposed" inside the file. After the owner merges the PR the marker stays, although merging is the acceptance, so accepted rules look unaccepted.

## Users and context
The brain owner, who reviews the weekly review PR and accepts proposals by merging it.

## Outcomes
- A `ways/` bullet added by the weekly review reads as a normal final bullet.
- Proposals are identifiable only in the PR body and the journal digest.
- Existing merged bullets lose a leftover "proposed" marker, and the digest says which.

## In scope
- Change the weekly-review skill (and its task/docs where the rule is restated) so new `ways/` bullets carry no "proposed" marker.
- List the proposed bullets in the PR body and the digest, marked as proposals.
- Each run removes the leading "proposed; " marker from `ways/` bullets already on the default branch, and lists each changed bullet in the digest.

## Out of scope
- `proposed` markings in decision-record Generalisation sections.
- Any other skill's behaviour.
- Removing markers from bullets in unmerged PRs.

## Acceptance criteria
1. Given the weekly review proposes a `ways/` change, when it writes the bullet, then the file text contains no "proposed" marker for that bullet.
2. Given a proposed bullet, when the PR is opened, then the PR body and the journal digest each list it and label it a proposal.
3. Given a `ways/` bullet on the default branch containing "proposed; ", when the review runs, then the PR removes that marker and keeps the rest of the bullet, including its source note, unchanged.
4. Given bullets were cleaned under criterion 3, when the digest is written, then it lists each one (file and bullet text).
5. Given a decision record with a `proposed` Generalisation, when the review runs, then that marking is unchanged.
6. Given no merged bullet has a marker, when the review runs, then no cleanup edit or cleanup digest entry is made.
7. Wherever the rule is restated in the kit (skill, task, docs), the wording is the same in each, changed in one commit.

## Constraints
- The change is made in the Segoy kit, not in the brain.
- Cleanup edits go into the weekly review PR; nothing is committed to `main`.
- Stated-over-inferred still holds: only owner-merged content counts as accepted.

## Open questions
- Should the cleanup also match a marker in other forms (for example "(proposed)")? (proposed default: match only the exact "proposed; " prefix inside the source parentheses and the leading "(proposed;" form currently in use)

## Assumptions
- Merging the PR counts as the owner's approval of `ways/` bullets (likely, owner-stated)
- Decision-record Generalisation markings are unaffected (guess, spec)
- Cleanup applies only to bullets already merged (likely, owner-stated)
