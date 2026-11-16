# Lint fix PR body template

Title: `Lint fixes <run date>`. Label: `segoy:lint`. Replace `<…>`. One bullet per `fixed` line from `brain-lint.sh --fix`. No protocol block other than the `run` block, and the `run` block is last.

````markdown
**Lint fixes <run date>**: <n> mechanical fixes. The `Lint <run date>` report issue links to this PR.

Only frontmatter blocks (missing derivable fields, `updated` set to <run date>) and index rows change, plus one `log.md` line. No body text, no raw file, no contradiction, orphan or stale page.

## Frontmatter
- `<path>`: added `<field>: <value>`.

## Index rows
- `<index path>`: <what changed>.

Merge to accept. To change something, edit the files in this PR before merging, or close it.

```segoy
{"v": 1, "kind": "run", "skill": "segoy-lint", "repo": "<owner>/<brain>", "started": "<iso>", "finished": "<iso>", "outcome": "ok", "next": "owner: review and merge, or edit and merge", "session": "<url>", "checks": {"leak-check": "pass"}}
```
````

## Filled example (validated by Segoy's tests)

````markdown
**Lint fixes 2026-01-10**: 1 mechanical fix. The `Lint 2026-01-10` report issue links to this PR.

## Frontmatter
- `ideas/I-20251201-1-example-idea/idea.md`: added `links: []`.
````

```segoy
{"v": 1, "kind": "run", "skill": "segoy-lint", "repo": "example/brain", "started": "2026-01-10T16:00:05Z", "finished": "2026-01-10T16:03:10Z", "outcome": "ok", "next": "owner: review and merge, or edit and merge", "session": "https://claude.ai/code/session_example", "checks": {"leak-check": "pass"}}
```
