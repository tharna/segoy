---
id: I-20261116-4
title: Kit skills keep their protocol blocks valid
kind: idea
state: specced
visibility: shareable
created: 2026-11-16
updated: 2026-11-16
source: promoted
links: []
---
# Spec: Kit skills keep their protocol blocks valid

## Problem
`segoy-spec` has posted `segoy` blocks that fail protocol validation: the `spec` block `target` carried an owner prefix, the revise-mode `decision` block used `subject` instead of `idea`, and after a revision the PR body's `spec` block still showed the old counts. Other skills that post blocks have no step that catches the same class of mistake before posting.

## Users and context
The brain owner and the apps that read `segoy` blocks from comments and PR bodies.

## Outcomes
- Every block a kit skill posts passes the protocol validator.
- A revised spec PR shows current counts in its `spec` block.

## In scope
- `segoy-spec` writes `spec` block `target` as the repo name without owner (or `none`).
- `segoy-spec` revise mode writes its `decision` block with `idea`, not `subject`.
- After a revision, `segoy-spec` refreshes the PR body's `spec` block (`criteria`, `open_questions`, `private_blocks`) to match the pushed files.
- Every kit skill that posts `segoy` blocks validates them with `.claude/scripts/protocol.sh` before posting, fixes failures and re-checks.
- The templates and examples in the skills use the valid forms.

## Out of scope
- Changing the protocol itself or `protocol.sh` rules.
- Skills that never post blocks.
- Re-validating blocks already posted.

## Acceptance criteria
1. Given `segoy-spec` opens a spec PR for a target repo, when the PR body is written, then the `spec` block `target` has no `/` and `protocol.sh` accepts it.
2. Given `segoy-spec` revises a spec and the owner gave a reason, when it comments, then the `decision` block has an `idea` field, no `subject` field, and passes `protocol.sh`.
3. Given a revision changes the number of acceptance criteria, open questions or private blocks, when the revision is pushed, then the PR body's `spec` block counts equal the counts in the pushed `spec.md`.
4. Given any kit skill is about to post a comment or PR body containing `segoy` blocks, when it prepares the text, then it runs `protocol.sh` on that text first and posts only if the exit status is 0.
5. Given `protocol.sh` reports an error, when the skill handles it, then the skill corrects the block and re-runs the check, and if it still fails after two attempts it posts nothing and reports a `failed` run.
6. Every skill file and template in the kit that shows a `spec`, `decision` or other block example passes `protocol.sh`, checked in one run over the kit.
7. The same validation wording appears in each skill that posts blocks, changed in one commit.

## Constraints
- The change is made in the Segoy kit, not in the brain.
- `protocol.sh` and `jq` must be available where the skill runs; if `protocol.sh` exits 2 (usage error or missing `jq`), the skill treats that as a failed check.

## Open questions
- Should the check also cover blocks written to files (for example journal digests)? (proposed default: yes, any block the skill writes or posts)

## Assumptions
- Target is the Segoy kit (likely, brain)
- Validation failures block posting rather than warn (likely, owner-stated)
- `protocol.sh` already enforces the three named rules (firm, spec)
