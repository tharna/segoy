# Weekly review PR body template

Goes into the brain (private). Replace `<…>`. The `review` block (protocol §3.9) comes before the `run` block, and the `run` block is last.

````markdown
**Weekly review <yyyy>-W<ww>** (<from date> to <to date>)

- Filed: <n> notes, <n> decision records, <n> idea stubs; <n> state corrections.
- Stuck: <n> ideas. Needs you: <n> items. Proposed ways changes: <n>.
- Digest: [`journal/<yyyy>-W<ww>.md`](journal/<yyyy>-W<ww>.md)

Merge to accept everything. To change a proposal or record, edit the files in this PR before merging, or close it to reject the whole review. Merging closes the filed notes:

Closes #<n>

```segoy
{"v": 1, "kind": "review", "week": "<yyyy>-W<ww>",
 "period": {"from": "<iso>", "to": "<iso>"},
 "proposals": [{"id": "p1", "text": "<rule>", "target": "ways/<file>", "source": "<link or D-…>"}],
 "filed": {"notes": <n>, "decisions": <n>, "stubs": <n>, "state_fixes": <n>},
 "stuck": ["<idea ID>"], "stats": {"runs": <n>, "questions": <n>, "assumptions": <n>}}
```

```segoy
{"v": 1, "kind": "run", "skill": "segoy-weekly-review", "repo": "<owner>/<brain>", "started": "<iso>", "finished": "<iso>", "outcome": "ok", "next": "owner: review and merge, or edit and merge", "session": "<url>", "checks": {"leak-check": "pass"}}
```
````

## Filled example (validated by Segoy's tests)

````markdown
**Weekly review 2026-W01** (2025-12-28 to 2026-01-04)

Closes #12
````

```segoy
{"v": 1, "kind": "review", "week": "2026-W01",
 "period": {"from": "2025-12-28T16:00:00Z", "to": "2026-01-04T16:00:00Z"},
 "proposals": [{"id": "p1", "text": "Ask platform questions before scope questions.", "target": "ways/public/principles.md", "source": "D-20260102-1"}],
 "filed": {"notes": 1, "decisions": 1, "stubs": 1, "state_fixes": 1},
 "stuck": ["I-20251201-1"], "stats": {"runs": 12, "questions": 3, "assumptions": 9}}
```

```segoy
{"v": 1, "kind": "run", "skill": "segoy-weekly-review", "repo": "example/brain", "started": "2026-01-04T16:00:05Z", "finished": "2026-01-04T16:09:40Z", "outcome": "ok", "next": "owner: review and merge, or edit and merge", "session": "https://claude.ai/code/session_example", "checks": {"leak-check": "pass"}}
```
