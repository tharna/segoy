# Case: answers-plus-spec

Labels before the run: `kind:idea`, `state:needs-input`, `answered`

## Triage comment (agent, 2026-01-01T12:01:00Z)

Questions — reply one line each, or just `defaults`:
1. Phone first or desktop first? (default: phone)
2. Offline support? (default: no)

```segoy
{"v": 1, "kind": "question", "idea": "I-20260101-4", "round": 1,
 "questions": [{"id": "q1", "text": "Phone first or desktop first?", "options": ["phone", "desktop"], "default": "phone"},
               {"id": "q2", "text": "Offline support?", "options": ["yes", "no"], "default": "no"}]}
```

```segoy
{"v": 1, "kind": "run", "skill": "segoy-triage", "repo": "<owner>/<brain>", "idea": "I-20260101-4",
 "started": "2026-01-01T12:00:00Z", "finished": "2026-01-01T12:01:00Z", "outcome": "asked",
 "next": "owner: answer q1 and q2, then add the label answered", "session": "https://claude.ai/code/session_<id>"}
```

## Owner reply (2026-01-02T08:00:00Z)

desktop
/spec

```segoy
{"v": 1, "kind": "answer", "idea": "I-20260101-4", "round": 1, "answers": {"q1": "desktop"}, "command": "spec"}
```

## Expected outcome

- `segoy-spec` runs in create mode in this run: yes (the `/spec` command).
- Q&A in the spec: q1 desktop (your answer, kept), q2 no (default, left unanswered).
- State labels after the run: `state:triaged` only, then as `segoy-spec` sets it.
- `answered` removed first. One comment: the PR comment from `segoy-spec`.
