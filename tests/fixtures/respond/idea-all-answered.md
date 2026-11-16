# Case: idea-all-answered

Labels before the run: `kind:idea`, `state:needs-input`, `answered`

## Triage comment (agent, 2026-01-01T12:01:00Z)

Questions — reply one line each, or just `defaults`:
1. Phone first or desktop first? (default: phone)
2. Offline support? (default: no)

```segoy
{"v": 1, "kind": "question", "idea": "I-20260101-3", "round": 1,
 "questions": [{"id": "q1", "text": "Phone first or desktop first?", "options": ["phone", "desktop"], "default": "phone"},
               {"id": "q2", "text": "Offline support?", "options": ["yes", "no"], "default": "no"}]}
```

```segoy
{"v": 1, "kind": "run", "skill": "segoy-triage", "repo": "<owner>/<brain>", "idea": "I-20260101-3",
 "started": "2026-01-01T12:00:00Z", "finished": "2026-01-01T12:01:00Z", "outcome": "asked",
 "next": "owner: answer q1 and q2, then add the label answered", "session": "https://claude.ai/code/session_<id>"}
```

## Owner reply (2026-01-02T08:00:00Z)

desktop
yes

```segoy
{"v": 1, "kind": "answer", "idea": "I-20260101-3", "round": 1, "answers": {"q1": "desktop", "q2": "yes"}}
```

## Expected outcome

- `segoy-spec` runs: no (`kind:idea` keeps requiring `/spec`).
- Values: q1 desktop, q2 yes (your answers).
- State labels after the run: `state:triaged` only; the comment says `/spec` (plus the label) starts the spec.
- `answered` removed. One `segoy-respond` comment ending with a `run` block (`outcome` `ok`).
