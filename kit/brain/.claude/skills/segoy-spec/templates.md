# segoy-spec templates

Replace `<…>`. Dates are `yyyy-mm-dd`. Write in `notes_language`; keep captures verbatim.

## ideas/<id>-<slug>/idea.md

```markdown
---
id: <id>
title: <short English title>
kind: idea
state: specced
visibility: private
created: <issue date>
updated: <today>
source: issue#<n>
links: []
---
# <title>

## Captured text
<the issue title and body, verbatim>

## Restatement
<2–4 sentences>

## Why it matters
<one paragraph; link goals in self/goals.md if any apply>

## Related
- <links or "none">

## Target
<repo name | new project `<name>` | not code>

## Questions and answers
- <date> Q: <question> — A: <answer or "default: …">

## Assumptions
- <text> (<firm|likely|guess>, [source](<path>))
```

## ideas/<id>-<slug>/spec.md

```markdown
---
id: <id>
title: <title>
kind: idea
state: specced
visibility: shareable
created: <today>
updated: <today>
source: issue#<n>
links: []
---
# Spec: <title>

## Problem
<what is wrong or missing today, in plain words>

## Users and context
<who uses it and when; personal details in a private block>

## Outcomes
- <observable result>

## In scope
- …

## Out of scope
- …

## Acceptance criteria
1. <testable statement: given …, when …, then …>

## Constraints
- <technical or budget limits; personal reasons in a private block>

## Open questions
- <question> (proposed default: …)

## Assumptions
- <text> (<confidence>, <owner-stated | brain | spec>)
<!-- private -->
- <assumption whose source or content is personal> ([source](self/…))
<!-- /private -->
```

## ideas/index.md row

```markdown
| [<id>](<id>-<slug>/idea.md) | <title> | specced | <target> | <today> |
```

## PR body

````markdown
<For a new project, this checklist first:>
**Before merging, set up the target repo** (promotion runs on merge):
- [ ] Create `<owner>/<name>` (private unless you decide otherwise) and add it to the Claude GitHub App
- [ ] Add the leak-check CI to it (Segoy `tasks/brain-plan-promote.md`, "Project repo")
- [ ] Create the task `brain-plan-promote-<name>`

**<title>** (<id>)
<two-sentence summary>

- Target: `<repo>`
- Acceptance criteria: <n>
- Assumptions: <n> (<k> marked private, removed on promotion)
- Open questions: <n or "none">

Merge to approve the spec. Merging starts the plan and opens the Gate 1 PR in `<repo>`.
To ask for changes, comment here and add the label `answered`.

```segoy
{"v": 1, "kind": "spec", "idea": "<id>", "title": "<title>", "target": "<repo>", "criteria": <n>, "open_questions": <n>, "private_blocks": <n>}
```

```segoy
{"v": 1, "kind": "run", "skill": "segoy-spec", "repo": "<owner>/<brain>", "idea": "<id>", "started": "<iso>", "finished": "<iso>", "outcome": "ok", "next": "owner: review and merge, or comment and add answered", "session": "<url>"}
```
````

`target` in the `spec` block is the repo name without owner (`<repo>`, never `<owner>/<repo>`), or `none`. After a revision, recount `criteria`, `open_questions` and `private_blocks` from the pushed `spec.md` and update this block and the summary lines.

## Revise comment

At most 5 bullets. Include the `decision` block only if the owner's comment gave a reason; it carries `idea`, never `subject`.

````markdown
Revised the spec:
- <what changed>

```segoy
{"v": 1, "kind": "decision", "idea": "<id>", "gate": "spec", "outcome": "changed", "reason": "<the owner's reason, one line>"}
```

```segoy
{"v": 1, "kind": "run", "skill": "segoy-spec", "repo": "<owner>/<brain>", "idea": "<id>", "started": "<iso>", "finished": "<iso>", "outcome": "ok", "next": "owner: review and merge, or comment and add answered", "session": "<url>"}
```
````
