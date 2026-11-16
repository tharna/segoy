# Case: park-plus-answers

Labels before the run: `kind:task`, `state:needs-input`, `target:<repo>`, `answered`

## Triage comment (agent, 2026-01-01T12:01:00Z)

Questions — reply one line each, or just `defaults`:
1. Phone first or desktop first? (default: phone)
2. Offline support? (default: no)

```segoy
{"v": 1, "kind": "question", "idea": "I-20260101-5", "round": 1,
 "questions": [{"id": "q1", "text": "Phone first or desktop first?", "options": ["phone", "desktop"], "default": "phone"},
               {"id": "q2", "text": "Offline support?", "options": ["yes", "no"], "default": "no"}]}
```

```segoy
{"v": 1, "kind": "run", "skill": "segoy-triage", "repo": "<owner>/<brain>", "idea": "I-20260101-5",
 "started": "2026-01-01T12:00:00Z", "finished": "2026-01-01T12:01:00Z", "outcome": "asked",
 "next": "owner: answer q1 and q2, then add the label answered", "session": "https://claude.ai/code/session_<id>"}
```

## Owner reply (2026-01-02T08:00:00Z)

desktop
yes
/park

```segoy
{"v": 1, "kind": "answer", "idea": "I-20260101-5", "round": 1, "answers": {"q1": "desktop", "q2": "yes"}, "command": "park"}
```

## Expected outcome

- `/park` applies although every question is answered: `segoy-spec` runs: no.
- State labels after the run: `state:parked` only.
- `answered` removed. One `segoy-respond` comment with a `decision` block (`gate` `triage`, `outcome` `parked`, `reason` `none given`) and a `run` block last.
