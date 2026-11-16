**Lint 2026-01-10**: 12 findings (1 contradictions, 1 orphan pages, 1 stale pages, 5 frontmatter, 4 index drift, 1 stuck ideas).

Fix PR: #11 fixes 7 frontmatter and index findings.
Nothing in this report was changed except by the fix PR. Contradictions, orphan and stale pages and stuck ideas are for you to decide.

## Contradictions
- `knowledge/wiki/entities/example-tool-x.md:15` says "Example tool X stores data as plain text files."; `knowledge/wiki/topics/example-tool-x-storage.md:15` says "Example tool X stores data in a binary database." Both describe how Example tool X stores data, and the two formats exclude each other.

## Orphan pages
- `knowledge/wiki/topics/example-orphan.md`: no inbound link. (The fix PR lists it in the wiki index under Unfiled; the page itself is unchanged.)

## Stale pages
- `knowledge/wiki/topics/example-stale.md`: updated 2025-09-12, 120 days ago (threshold 90).

## Frontmatter
- `decisions/D-20251205-1.md`: missing `source` (not derivable, please add).
- `ideas/I-20251201-1-example-idea-one/idea.md`: missing `kind` (fixed in #11).
- `ideas/I-20251201-1-example-idea-one/idea.md`: missing `links` (fixed in #11).
- `knowledge/raw/20251201-example-raw-note.md`: no frontmatter (raw file, not fixed; raw files are never edited).
- `self/goals.md`: missing `updated` (fixed in #11).

## Index drift
- `ideas/index.md`: I-20251202-1: no row (fixed in #11).
- `ideas/index.md`: row I-20251130-1: no file (fixed in #11).
- `ideas/index.md`: row I-20251203-1: state "specced" differs from file "planned" (fixed in #11).
- `knowledge/wiki/index.md`: knowledge/wiki/topics/example-orphan.md: no row (fixed in #11).

## Stuck ideas
- I-20251202-1 (#2): `needs-input` for 20 days.

```segoy
{"v": 1, "kind": "run", "skill": "segoy-lint", "repo": "example/brain", "started": "2026-01-10T16:00:05Z", "finished": "2026-01-10T16:06:30Z", "outcome": "ok", "next": "owner: read the report; merge or close the fix PR", "session": "https://claude.ai/code/session_example", "checks": {"leak-check": "pass"}}
```
