# Lint report issue template

Title: `Lint <run date>`. Label: `segoy:lint` (no `state:*` label). Written in `notes_language`. Replace `<…>`. Leave out a section that has no findings, but keep the order. Every finding names its file path; `self/` files appear by path and field name only, never their content. No protocol block other than the `run` block, and the `run` block is last.

````markdown
**Lint <run date>**: <n> findings (<n> contradictions, <n> orphan pages, <n> stale pages, <n> frontmatter, <n> index drift, <n> stuck ideas).

Fix PR: #<n> fixes <n> frontmatter and index findings. <or: No fix PR: nothing here is mechanical. / Fixes wait for open lint PR #<n>.>
Nothing in this report was changed except by the fix PR. Contradictions, orphan and stale pages and stuck ideas are for you to decide.

## Contradictions
- `<path>:<line>` says "<statement, quoted verbatim>"; `<path>:<line>` says "<statement, quoted verbatim>". <one line: why they cannot both be true>

## Orphan pages
- `<path>`: no inbound link.

## Stale pages
- `<path>`: updated <date>, <n> days ago (threshold 90).

## Frontmatter
- `<path>`: missing `<field>` (fixed in #<n> | not derivable, please add).

## Index drift
- `<index path>`: <detail from brain-lint.sh> (fixed in #<n> | needs you).

## Stuck ideas
- <idea ID> (#<issue>): `<current state>` for <n> days.

```segoy
{"v": 1, "kind": "run", "skill": "segoy-lint", "repo": "<owner>/<brain>", "started": "<iso>", "finished": "<iso>", "outcome": "ok", "next": "owner: read the report; merge or close the fix PR", "session": "<url>", "checks": {"leak-check": "pass"}}
```
````

## Filled example (validated by Segoy's tests)

````markdown
**Lint 2026-01-10**: 2 findings (1 orphan pages, 1 stuck ideas).

## Orphan pages
- `knowledge/wiki/topics/example-orphan.md`: no inbound link.

## Stuck ideas
- I-20251201-1 (#5): `needs-input` for 20 days.
````

```segoy
{"v": 1, "kind": "run", "skill": "segoy-lint", "repo": "example/brain", "started": "2026-01-10T16:00:05Z", "finished": "2026-01-10T16:03:40Z", "outcome": "ok", "next": "owner: read the report", "session": "https://claude.ai/code/session_example", "checks": {"leak-check": "pass"}}
```
