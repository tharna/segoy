---
id: ADR-017
title: Promotion's leak check is a skill step plus CI, not a hook
state: accepted
created: 2026-11-15
---
# ADR-017: Promotion's leak check is a skill step plus CI, not a hook

## Context
`brain-plan-promote` mounts the brain and the target project repo. Spike S2/S6 showed that in a session with several repositories, hooks from `.claude/settings.json` do not run, so the `leak-guard.sh` hook cannot protect promotion. Attaching a second repo mid-run (a brain-only task that clones the project itself) was blocked by auto-mode twice in an interactive session, so it is not dependable unattended.

## Decision
- Keep the two-repo task, one per project repo, using a PR trigger on the brain (`pull_request.closed`, Is merged, label `segoy:spec`, label `target:<repo>`).
- Three layers protect the project repo:
  1. **Skill step:** `promote` must run `leak-guard.sh` with the brain's denylist plus the generic patterns over the files it is about to commit, and stop on any hit. The step is listed under Procedure and Output contract, and the run record says it ran.
  2. **CI:** the project repo's `segoy-ci.yml` runs the generic leak check on every PR as a required check. No model involved.
  3. **Gate 1:** the owner reads the promotion PR before merging.
- Hooks stay in place for single-repo runs, where they do work.

## Consequences
- The first layer depends on the model following the skill. The second and third do not.
- The brain-specific denylist is not in CI (it must not be in the project repo). Personal terms that are not generic patterns are caught only by layer 1 and Gate 1. That residual risk is accepted and stated in architecture §5.

## Revisit when
Hooks run in multi-repo sessions, or the trigger layer is replaced (ADR-021).
