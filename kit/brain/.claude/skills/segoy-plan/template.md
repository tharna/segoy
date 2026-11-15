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

Coverage check before handing over: list the spec's criteria numbers and the task groups that cover each. Every number must appear at least once.
