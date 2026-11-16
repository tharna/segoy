# Record formats for segoy-weekly-review

Replace `<…>`. Dates are `yyyy-mm-dd` (UTC). Every file has full frontmatter (brain `CLAUDE.md` rule 3) and a `source` link back to where it came from.

## Raw note: `knowledge/raw/<yyyymmdd>-<slug>.md`

`<yyyymmdd>` is the issue's creation date; `<slug>` is kebab-case from the title. The body is the issue title and body exactly as typed. Raw files are immutable once merged.

````markdown
---
id: raw-<yyyymmdd>-<slug>
title: <issue title>
kind: raw
visibility: private
created: <issue created date>
updated: <run date>
source: <issue URL>
links: []
---
<issue title>

<issue body, verbatim>
````

## Decision record: `decisions/D-<yyyymmdd>-<n>.md`

From one `decision` block (protocol §3.7). `<yyyymmdd>` is the date of the comment that carries it.

````markdown
---
id: D-<yyyymmdd>-<n>
title: <idea title>: <outcome> at <gate>
kind: decision
visibility: private
created: <comment date>
updated: <run date>
source: <comment URL>
links: [<idea issue URL>]
gate: <triage|spec|plan|impl|other>
subject: <idea ID>
outcome: <approved|changed|rejected|parked>
---
# <title>

## What was decided
<one or two sentences>

## Reason in the owner's words
> <reason, quoted exactly from the block; "none given" if none>

## Generalisation
<optional: one rule this suggests, ending "(proposed)"; omit the section if none>
````

Index row in `decisions/index.md`: `| [D-<yyyymmdd>-<n>](D-<yyyymmdd>-<n>.md) | <idea ID> <short subject> | <gate> | <outcome> | <date> |`

## Idea stub: `ideas/<id>-<slug>/idea.md`

For a parked or rejected idea that never got an idea folder. Only what the issue says; no inference.

````markdown
---
id: <idea ID>
title: <idea title>
kind: idea
state: <parked|rejected>
visibility: private
created: <issue created date>
updated: <run date>
source: <issue URL>
links: [<decision record path, if any>]
---
# <idea title>

## Captured text (verbatim)
<issue title and body>

## Restatement
<one sentence>

## Why it matters
Stub written by the weekly review; the idea was <parked|rejected> on <date>. See the source issue.
````

Index row in `ideas/index.md`: `| [<id>](<id>-<slug>/idea.md) | <title> | <state> | <target or —> | <run date> |`

## `log.md` line

One line per operation, appended at the end:

```
<run date> · segoy-weekly-review · <file note|record decision|stub idea|fix state|propose way|write digest> · <files>
```

## Ways proposal

A new bullet in the target `ways/` file, next to related rules:

```markdown
- <Imperative, checkable rule.> (proposed; source: <link, D-… or retro path>, <run date>)
```

Replacing an existing rule: keep the old bullet, strike it through, and put the new one right after it, so both are visible in the diff:

```markdown
- ~~<old rule> (source: …)~~ (replaced by the proposal below)
- <new rule> (proposed; source: <evidence>, <run date>)
```
