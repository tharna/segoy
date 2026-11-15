Triage comment with questions.

```segoy
{"v": 1, "kind": "question", "idea": "I-20260101-1", "round": 1,
 "questions": [{"id": "q1", "text": "Which platform?", "options": ["web", "android"], "default": "android"}]}
```

```segoy
{"v": 1, "kind": "answer", "idea": "I-20260101-1", "round": 1, "answers": {"q1": "web"}, "command": "spec"}
```

```segoy
{"v": 1, "kind": "run", "skill": "triage", "repo": "example/brain", "idea": "I-20260101-1",
 "started": "2026-01-01T12:00:00Z", "finished": "2026-01-01T12:01:10Z", "outcome": "asked",
 "next": "owner: answer q1", "session": "https://claude.ai/code/session_example", "checks": {"pause": "pass"}}
```

```segoy
{"v": 1, "kind": "plan", "idea": "I-20260101-1", "summary": "outline kinds only need common fields for now"}
```

````markdown
```segoy
{"this": "is a documentation example inside a four-backtick fence and is skipped"}
```
````
