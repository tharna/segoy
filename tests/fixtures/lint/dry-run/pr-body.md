**Lint fixes 2026-01-10**: 8 mechanical fixes. The `Lint 2026-01-10` report issue links to this PR.

Only frontmatter blocks (missing derivable fields, `updated` set to 2026-01-10) and index rows change, plus one `log.md` line. No body text, no raw file, no contradiction, orphan or stale page.

## Frontmatter
- `ideas/I-20251201-1-example-idea-one/idea.md`: added `kind: idea`.
- `ideas/I-20251201-1-example-idea-one/idea.md`: added `links: []`.
- `ideas/I-20251201-1-example-idea-one/idea.md`: set `updated: 2026-01-10`.
- `self/goals.md`: added `updated: 2026-01-10`.

## Index rows
- `ideas/index.md`: I-20251202-1: row added.
- `ideas/index.md`: row I-20251130-1: removed (no file).
- `ideas/index.md`: row I-20251203-1: state set to "planned".
- `knowledge/wiki/index.md`: knowledge/wiki/topics/example-orphan.md: row added under Unfiled.

Merge to accept. To change something, edit the files in this PR before merging, or close it.

```segoy
{"v": 1, "kind": "run", "skill": "segoy-lint", "repo": "example/brain", "started": "2026-01-10T16:00:05Z", "finished": "2026-01-10T16:05:10Z", "outcome": "ok", "next": "owner: review and merge, or edit and merge", "session": "https://claude.ai/code/session_example", "checks": {"leak-check": "pass"}}
```
