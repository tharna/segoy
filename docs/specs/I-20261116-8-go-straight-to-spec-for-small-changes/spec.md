---
id: I-20261116-8
title: Go straight to the spec for small, clear changes
kind: idea
state: specced
visibility: shareable
created: 2026-11-16
updated: 2026-11-16
source: promoted
links: []
---
# Spec: Go straight to the spec for small, clear changes

## Problem
After the owner answers a small change's questions, `segoy-respond` sets `state:triaged` and waits for a separate `/spec` comment plus the answer label. That round adds no information for small, clear changes. Also, when a reply contains both answers and `/spec`, the rule "a command wins over answers" makes `/spec` take defaults, so the owner's answers can be dropped.

## Users and context
The brain owner, answering triage questions from a phone.

## Outcomes
- A fully answered small change (`kind:task`) gets its spec PR from one reply.
- Answers given together with `/spec` are applied, not replaced by defaults.

## In scope
- `segoy-respond`: automatic hand-over to `segoy-spec` (create mode) for `kind:task` issues whose questions are all settled by the reply.
- `segoy-respond`: apply answers before running `/spec`; defaults only for questions left unanswered.
- Update the skill text and its output contract accordingly.

## Out of scope
- `kind:idea` issues: they keep requiring `/spec`.
- Changes to `segoy-triage` classification.
- Changes to `segoy-spec` itself.

## Acceptance criteria
1. Given a `kind:task` issue with open questions, when the owner answers every question and `segoy-respond` runs, then it runs `segoy-spec` in create mode in the same run and the issue gets no `state:triaged` wait for `/spec`.
2. Given a `kind:task` issue where the owner answers only some questions, when `segoy-respond` runs, then it behaves as before: unanswered questions take defaults per the existing rule and the state is set per the existing rule, without an automatic spec unless every question is settled.
3. Given a `kind:idea` issue whose questions are all answered, when `segoy-respond` runs, then it sets `state:triaged` and does not start the spec.
4. Given a reply containing answers and `/spec`, when `segoy-respond` runs, then each answered question uses the owner's answer and only unanswered questions take their defaults; the resulting spec's Q&A shows the owner's answers.
5. Given a reply containing `/park` or `/reject` plus answers, when `segoy-respond` runs, then the command still applies as before.
6. Given an open `segoy:paused` issue, when the automatic path would trigger, then nothing happens.
7. Given the automatic path ran, then the issue ends with exactly one `state:*` label, the answer label removed, and one `run` comment, or the PR comment from `segoy-spec` if a PR was opened.
8. The text of `segoy-respond` no longer states that a command wins over answers for `/spec` and `/plan`.

## Constraints
- Never more than three question rounds per idea; the paused check and "claim first" label removal remain unchanged.
- Nothing is committed to `main`.

## Open questions
- Should an issue with all answers but an unclear target still go straight to the spec? (proposed default: yes, `segoy-spec` already handles missing targets)

## Assumptions
- Only `kind:task` qualifies (likely, owner-stated)
- "Answers all its questions" means every question of the latest round is answered or `defaults` is given (guess, spec)
