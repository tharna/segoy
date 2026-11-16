# Ingest PR body template

Goes into the brain (private). Replace `<…>`. No protocol block other than the `run` block, and the `run` block is last.

````markdown
**Ingest: <source title>** (`knowledge/raw/<stem>.md`)

<One or two sentences: what the source is.>

- Source summary: [`knowledge/wiki/sources/<stem>.md`](knowledge/wiki/sources/<stem>.md)
- Updated: <n> pages: `<path>`, …
- Created: <n> pages: `<path>`, …
- Private parts: <n> passages kept inside private blocks.
- Raw file unchanged.

Merge to accept. To change something, edit the files in this PR before merging, or close it to reject this source (it will not be ingested again unless you name it in a Run now prompt).

```segoy
{"v": 1, "kind": "run", "skill": "segoy-ingest", "repo": "<owner>/<brain>", "started": "<iso>", "finished": "<iso>", "outcome": "ok", "next": "owner: review and merge, or edit and merge", "session": "<url>", "checks": {"leak-check": "pass"}}
```
````

## Filled example (validated by Segoy's tests)

````markdown
**Ingest: Example article about checklists** (`knowledge/raw/20260101-example-article.md`)
````

```segoy
{"v": 1, "kind": "run", "skill": "segoy-ingest", "repo": "example/brain", "started": "2026-01-02T10:00:05Z", "finished": "2026-01-02T10:04:40Z", "outcome": "ok", "next": "owner: review and merge, or edit and merge", "session": "https://claude.ai/code/session_example", "checks": {"leak-check": "pass"}}
```
