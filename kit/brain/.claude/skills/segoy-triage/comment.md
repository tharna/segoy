# Triage comment templates

Write in `notes_language`. Keep each comment short enough to read on a phone without scrolling much. Replace `<…>`. End with the `segoy` blocks (protocol §3): `question` first when asking, `run` always last.

## Idea or task

```markdown
**<ID> — <short English title>**
<2–3 sentences restating the idea in your own words.>
<If capture_language differs from notes_language and keep_original is true: "Original: <first line of the capture, verbatim>">

Related: <links to related issues or idea files, or "none">
Suggested target: <existing repo `name` | new project `name` | not code><, small change — for a task>
Assumed from your notes:
- <assumption> (<confidence>, [source](<path>))
<or "Assumed from your notes: nothing">

Questions — reply one line each, or just `defaults`:
1. <question> (default: <default>)

Next: reply, then add the label `answered`. Or comment `/spec` and add `answered` to go ahead with the defaults.
```

Without questions, replace the Questions and Next lines with:

```markdown
Next: ready for a spec. Comment `/spec` and add `answered` when you want it, or `/park` to keep it for later.
```

Blocks (example; IDs, times and text are placeholders):

````markdown
```segoy
{"v": 1, "kind": "question", "idea": "I-20260101-1", "round": 1,
 "questions": [{"id": "q1", "text": "Phone first or desktop first?", "options": ["phone", "desktop"], "default": "phone"}]}
```

```segoy
{"v": 1, "kind": "run", "skill": "segoy-triage", "repo": "<owner>/<brain>", "idea": "I-20260101-1",
 "started": "2026-01-01T12:00:00Z", "finished": "2026-01-01T12:01:00Z", "outcome": "asked",
 "next": "owner: answer q1, then add the label answered", "session": "https://claude.ai/code/session_<id>"}
```
````

## Duplicate

```markdown
**Duplicate of <ID or #issue> — <title>**
This looks like the same idea as <link>: <one sentence why>. <"Closing this one; reopen it if it is different." or "Leaving it open for you to decide.">
```
Then the `run` block with `outcome` `ok` and `next` `none`.

## Note

```markdown
**Note saved**
<One sentence on what it is.> The weekly review will file it into `knowledge/raw/` and link it to related pages, then close this issue.
```
Then the `run` block with `outcome` `ok` and `next` `none (weekly review files it)`.

## Self

```markdown
**About you — please confirm**
I would add to `self/<file>.md`: "<the statement, restated in notes_language>" (source: this issue, <date>).
Reply `yes` (or correct it), then add the label `answered`. Nothing changes until you confirm.
```
Then the `run` block with `outcome` `asked` and `next` `owner: confirm, then add the label answered`.
