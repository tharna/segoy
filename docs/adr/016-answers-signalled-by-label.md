---
id: ADR-016
title: Answers are signalled by a label, with an hourly sweep as fallback
state: accepted
created: 2026-11-15
---
# ADR-016: Answers are signalled by a label, with an hourly sweep as fallback

## Context
Agents ask questions on brain issues (state `needs-input`). Spike S3 showed that issue comments do not start tasks, but an owner adding a label does. Otak posts answers as comments with an `answer` block; GitHub mobile users type free text.

## Decision
- An answer is a comment **plus** the label `answered` (name configurable: `answer_label`). Otak adds both in one action.
- `brain-respond` is triggered by `issues.labeled` and runs only when the label is the answer label (the run reads the issue's labels; the trigger context does not say which label was added).
- A scheduled `brain-respond` sweep (hourly; the platform minimum) handles answers that came without the label: open issues in `needs-input` whose latest comment is from the owner and newer than the latest agent comment.
- The skill removes the answer label when it has processed the answer.
- Commands such as `/spec`, `/park` and `/reject` work the same way: comment, then label, or wait for the sweep.

## Consequences
- With Otak, answers take effect within about a minute. From GitHub mobile without the label, within an hour.
- One more label to keep in `labels.yml`, plus one scheduled task.
- Considered: a GitHub Actions workflow on `issue_comment` that calls the task's `/fire` endpoint. Immediate and label-free, but it needs the per-task token stored as a repo secret, and it adds a component to maintain. Kept as an upgrade path (ADR-021).

## Revisit when
Comment events can start tasks, or the friction of the label or the sweep delay is felt in practice.
