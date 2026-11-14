---
name: example-good
description: Use when testing the skill linter; this file must pass.
---
## Inputs
- An example issue number.

## Preconditions (exit quietly if not met)
- The repo has no open `segoy:paused` issue.

## Procedure (numbered, imperative, each step checkable)
1. Read the example issue.
2. Post one comment.

## Output contract
- One comment on the issue.

## Stop conditions and budget
- Stop after one comment.

## Never
- Never push to `main`.
