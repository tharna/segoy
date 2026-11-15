```segoy
{"v": 1, "kind": "question", "idea": "I-2026-1", "round": 0,
 "questions": [{"id": "q1", "text": "a"}, {"id": "q1", "text": "b", "default": "x"}, {"id": "q3", "text": "c", "default": "x"}, {"id": "q4", "text": "d", "default": "x"}]}
```

```segoy
{"v": 2, "kind": "answer", "idea": "I-20260101-1", "round": 1, "answers": {"q1": 3}, "command": "merge"}
```

```segoy
{"v": 1, "kind": "run", "skill": "triage", "repo": "brain", "started": "yesterday",
 "finished": "2026-01-01T12:00:00Z", "outcome": "done", "next": ""}
```

```segoy
{"v": 1, "kind": "run", "oops"
```

```segoy
{"v": 1, "kind": "plan", "idea": "I-20260101-1", "summary": "x",
 "assumptions": [{"text": "a", "confidence": "sure", "source": "self/goals.md"}],
 "tasks": [], "size": "XL", "omitted_private": -1, "checks": {"leak-check": "fail"}}
```

```segoy
{"v": 1, "kind": "decision", "idea": "I-20260101-1", "gate": "merge", "outcome": "maybe", "reason": ""}
```

```segoy
{"v": 1, "kind": "impl", "idea": "I-20260101-1",
 "criteria": [{"id": "one", "text": "x", "evidence": "", "result": "maybe"}],
 "deviations": "none", "tests": {"command": "t", "result": "ok"}}
```
