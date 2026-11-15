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

````markdown
```segoy
{"this": "is a documentation example inside a four-backtick fence and is skipped"}
```
````

```segoy
{"v": 1, "kind": "spec", "idea": "I-20260101-1", "title": "Example idea", "target": "example-repo",
 "criteria": 4, "open_questions": 1, "private_blocks": 2}
```

```segoy
{"v": 1, "kind": "plan", "idea": "I-20260101-1", "summary": "Add an example list with fast entry.",
 "assumptions": [{"text": "Phone first", "confidence": "firm", "source": "owner-stated"},
                 {"text": "Plain markdown storage", "confidence": "likely", "source": "brain"}],
 "tasks": [{"id": "T1", "title": "Data model"}, {"id": "T2", "title": "Entry screen"}],
 "size": "S", "omitted_private": 2, "checks": {"leak-check": "pass"}}
```

```segoy
{"v": 1, "kind": "decision", "idea": "I-20260101-1", "gate": "spec", "outcome": "changed",
 "reason": "\"keep it offline only\""}
```
