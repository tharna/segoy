# Plan template

```markdown
---
id: <id>
title: <title>
kind: plan
state: planned
visibility: shareable
created: <today>
updated: <today>
source: spec
links: [spec.md]
---
# Plan: <title>

## Assumptions
- PoC: <not needed (existing repo | owner skipped) | see T1>
- <assumption> (<firm|likely|guess>, <owner-stated | brain | spec | path in this repo>)
<!-- private -->
- <assumption resting on personal context> ([source](<brain path>))
<!-- /private -->

## Approach
<one or two paragraphs: the shape of the solution and why>

## Components touched
- `<path>`: <what changes>

## Task groups
### T1 <title>
- Files: `<path>`, …
- Steps: <numbered or bulleted, each small>
- Check: `<command>` → <expected result>
- Covers criteria: <1, 2>

### T2 <title>
…

## Test plan
<what is tested how; which criteria each test proves>

## Risks
- <risk> → <mitigation>

## Rollout
<how it reaches use; anything the owner must do by hand>

## Size
<S | M | L> <and "multi-pr: one PR per task group" when L>
```

When the PoC check (skill step 4) says a PoC is needed, `T1` is `PoC: <riskiest assumption>`: one short task, a `- Judged:` line saying how the result is judged, no feature beyond that assumption.

Coverage check before handing over: list the spec's criteria numbers and the task groups that cover each. Every number must appear at least once. Confirm the `PoC:` line is present, and when it says `see T1`, that `T1` is the PoC task group.
