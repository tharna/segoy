**Plan: Example idea** (I-20260101-1)

Adds an example feature to the example project so the fixture shows a full Gate 1 PR body.

**Tasks**
- [ ] T1 Build the example
- [ ] T2 Test the example

**Assumptions** (check these first)
- The example needs no new dependency (likely)

**Size:** S · **Private items omitted:** 0

Spec and plan: [`docs/specs/I-20260101-1-example-idea/`](docs/specs/I-20260101-1-example-idea/)

**Gate 1.** Merge to approve: implementation starts from this plan. To change the plan, edit `plan.md` in this PR (commit to its branch), or close the PR to replan. A comment alone starts nothing.

```segoy
{"v": 1, "kind": "plan", "idea": "I-20260101-1", "summary": "Add an example feature.",
 "assumptions": [{"text": "The example needs no new dependency", "confidence": "likely", "source": "spec"}],
 "tasks": [{"id": "T1", "title": "Build the example"}, {"id": "T2", "title": "Test the example"}],
 "size": "S", "omitted_private": 0, "checks": {"leak-check": "pass"}}
```

```segoy
{"v": 1, "kind": "run", "skill": "segoy-promote", "repo": "example-owner/example-project", "idea": "I-20260101-1", "started": "2026-01-01T10:00:00Z", "finished": "2026-01-01T10:05:00Z", "outcome": "ok", "next": "owner: review and merge (Gate 1)", "session": "https://claude.ai/code/session_example", "checks": {"leak-check": "pass"}}
```
