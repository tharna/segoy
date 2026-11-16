# Gate 2 PR body template

Project repo; may be public. Nothing personal. Replace `<…>`.

````markdown
**Impl: <title>** (<id>)

<two or three sentences: what changed and why, for someone who has only this repo>

Plan: [`docs/specs/<id>-<slug>/plan.md`](docs/specs/<id>-<slug>/plan.md) · Gate 1: #<n>

**Acceptance criteria**
| # | Criterion | Evidence | Result |
|---|---|---|---|
| 1 | <short> | <test name and result, command output, or path:line> | ✅ pass / ❌ fail / ❔ unclear |

**Deviations from the plan:** <none, or bullets with reasons>

**Try it:** <one to three steps the owner can run or click>

**Follow-ups:** <none, or bullets>

**Gate 2.** Merge to accept. To change something, comment and add the label `answered`. Close to reject.

```segoy
{"v": 1, "kind": "impl", "idea": "<id>",
 "criteria": [{"id": "1", "text": "<short>", "evidence": "<…>", "result": "pass"}],
 "deviations": [], "tests": {"command": "<test command>", "result": "pass"}}
```

```segoy
{"v": 1, "kind": "run", "skill": "segoy-implement", "repo": "<owner>/<repo>", "idea": "<id>", "started": "<iso>", "finished": "<iso>", "outcome": "ok", "next": "owner: review and merge (Gate 2)", "session": "<url>"}
```
````
