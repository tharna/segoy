---
id: ADR-018
title: Triage writes no files; the issue is the record until a merged PR
state: accepted
created: 2026-11-15
---
# ADR-018: Triage writes no files; the issue is the record until a merged PR

## Context
Decision 5 allowed triage to commit new idea files and the log directly to the brain's `main`. Spike S11 found that whether a scheduled run pushes to `main` depends on the model: one run did, another refused, citing its instruction to push only to its assigned branch. A pipeline step that works some of the time is worse than one that never needs to.

## Decision
- `triage` writes no files. It sets labels, assigns the idea ID, and posts its comment (with the `question` block when there are questions). The issue is the idea's record.
- The spec PR creates `ideas/<id>-<slug>/idea.md` (from the issue), `spec.md`, and the index entry.
- Notes (`note:`) and ideas that never reach spec are filed by the weekly review PR in one batch: `knowledge/raw/` files, parked or rejected idea stubs, and the `log.md` entries.
- `direct_commit_paths` is removed from the config.

## Consequences
- Nothing in the brain depends on a push to `main`. Every file change is a PR the owner merges.
- Between capture and spec, an idea lives only in its issue, so searching for duplicates must read open issues as well as `ideas/index.md`.
- Supersedes decision 5 in `docs/README.md`.

## Revisit when
Tasks can be configured to push to the default branch reliably, or the trigger layer is replaced (ADR-021).
