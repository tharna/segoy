# Gate 1 PR body template

This text goes into the **project** repo and may become public. Nothing personal, no brain paths, no brain name. Replace `<…>`.

````markdown
**Plan: <title>** (<id>)

<what and why in at most five lines, written for someone who has only this repo>

**Tasks**
- [ ] T1 <title>
- [ ] T2 <title>

**Assumptions** (check these first)
- <assumption> (<confidence>)

**Size:** <S|M|L> · **Private items omitted:** <n>

Spec and plan: [`docs/specs/<id>-<slug>/`](docs/specs/<id>-<slug>/)

**Gate 1.** Merge to approve: implementation starts from this plan. To change something, comment and add the label `answered`. Close to reject.

```segoy
{"v": 1, "kind": "plan", "idea": "<id>", "summary": "<one sentence>",
 "assumptions": [{"text": "<…>", "confidence": "<firm|likely|guess>", "source": "<owner-stated|brain|spec|path>"}],
 "tasks": [{"id": "T1", "title": "<…>"}],
 "size": "<S|M|L>", "omitted_private": <n>, "checks": {"leak-check": "pass"}}
```

```segoy
{"v": 1, "kind": "run", "skill": "segoy-promote", "repo": "<owner>/<project>", "idea": "<id>", "started": "<iso>", "finished": "<iso>", "outcome": "ok", "next": "owner: review and merge (Gate 1)", "session": "<url>", "checks": {"leak-check": "pass"}}
```
````
