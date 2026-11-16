---
id: protocol
title: Segoy agent–app protocol
state: v1
created: 2026-11-15
updated: 2026-11-15
---
# Segoy agent–app protocol (v1)

This is the contract between Segoy skills and anything that reads their output without parsing prose: the Otak app, `segoy doctor`, and other skills. GitHub carries all of it. There is no server.

- **State** lives in labels (§2).
- **Content** lives in `segoy` blocks: JSON objects in fenced code blocks, appended to the comments and PR bodies that skills already write (§3).
- **Owner actions** that start work are listed in §4.

Any change to what a skill posts must keep this document valid. Validate with `.claude/scripts/protocol.sh <file>` (in any repo with the kit; in Segoy, `kit/common/.claude/scripts/protocol.sh`); from M1 also `scripts/segoy doctor --protocol <file>`.

## 1. Principles

1. **Additive.** Humans read the prose; the block repeats the same content in machine form. A reader that ignores blocks loses nothing.
2. **Tolerant reader.** Readers ignore unknown fields and unknown kinds. Writers never remove or rename a field within a version.
3. **Versioned.** Every block has `"v": 1`. A breaking change means `"v": 2`, described here, with readers accepting both for at least one release.
4. **Small.** A block carries what an app needs to render and act, not the whole artefact. Long content stays in files and is linked.
5. **No personal data beyond what the surrounding comment already shows.** Blocks in project repos are public in public repos.
6. **Checked before posting.** Every kit skill that posts or writes `segoy` blocks runs `.claude/scripts/protocol.sh` on the text first and posts only on exit 0; after two failed fixes it posts nothing but a checked `failed` `run` block. `tests/check-kit-blocks.sh` checks every example in the kit.

## 2. Labels (state)

| Label | Where | Meaning |
|---|---|---|
| `state:<state>` | Brain issues | Lifecycle state, exactly one. States: `inbox`, `triaged`, `needs-input`, `specced`, `planned`, `promoted`, `building`, `in-review`, `done`, `parked`, `rejected` (workflows §1) |
| `kind:<kind>` | Brain issues | `idea`, `note`, `task`, `self` |
| `target:<repo>` | Brain issues and spec PRs | Intended project repo (name only, no owner) |
| `segoy:<kind>` | PRs | `spec`, `plan`, `impl`, `retro`, `review`, `knowledge`, `lint` (`segoy:lint` is also on the weekly `Lint <date>` report issue in the brain, which has no `state:*` label) |
| `answered` | Issues and PRs | The owner has answered or given a command; start the next step (ADR-016). Name configurable as `answer_label` |
| `segoy:paused` | One open issue per repo | Automation in this repo is paused (§5) |

Skills set and remove labels with the GitHub tools. Labels set by agents start no task (ADR-015). They exist for state and for Otak.

## 3. Blocks (content)

### 3.1 Format

A block is a fenced code block with the info string `segoy`, containing exactly one JSON object:

````markdown
Human-readable text first.

```segoy
{"v": 1, "kind": "run", "skill": "triage", "outcome": "ok", "...": "..."}
```
````

Rules:
- At most one block per kind in one comment or PR body, placed at the end.
- The JSON must be valid. Pretty-printing is allowed.
- Common fields in every block: `v` (integer, `1`) and `kind` (string). Most blocks also carry `idea` (`I-<yyyymmdd>-<n>`) when they concern an idea.
- Timestamps are ISO 8601 UTC strings (`2026-01-01T12:00:00Z`).
- JSON rather than YAML (ADR-022): validated with `jq`, parsed directly by the app, written reliably by models.

### 3.2 `question`

Posted by `triage`, `spec` or `plan` when the owner must answer. Pairs with the comment's numbered questions.

| Field | Type | Required | Notes |
|---|---|---|---|
| `idea` | string | yes | Idea ID |
| `round` | integer ≥ 1 | yes | Increments with each round of questions on the same idea |
| `questions` | array, 1–3 items | yes | At most three per round (brain design §5) |
| `questions[].id` | string | yes | `q1`, `q2`, … unique within the round |
| `questions[].text` | string | yes | Answerable in one line from a phone |
| `questions[].options` | array of strings | no | Offered as one-tap choices |
| `questions[].default` | string | yes | Used when the owner says "defaults" |

```segoy
{"v": 1, "kind": "question", "idea": "I-20260101-1", "round": 1,
 "questions": [
   {"id": "q1", "text": "Which platform first?", "options": ["web", "android"], "default": "android"},
   {"id": "q2", "text": "Is offline use needed?", "options": ["yes", "no"], "default": "no"}
 ]}
```

### 3.3 `answer`

Posted by the app, together with the `answered` label (ADR-016). A plain-text reply from GitHub mobile is equally valid; skills must handle both.

| Field | Type | Required | Notes |
|---|---|---|---|
| `idea` | string | yes | |
| `round` | integer | yes | The round being answered |
| `answers` | object | yes | Question id → answer text. An omitted id means "use the default" |
| `command` | string | no | `spec`, `plan`, `park`, `unpark`, `reject`, `defaults` |
| `reason` | string | no | With `reject` |

```segoy
{"v": 1, "kind": "answer", "idea": "I-20260101-1", "round": 1, "answers": {"q1": "web"}}
```

### 3.4 `run`

Every skill run ends by posting one `run` comment: on the brain issue for brain flows, on the PR for project flows. This is the app's activity feed and failure inbox.

| Field | Type | Required | Notes |
|---|---|---|---|
| `skill` | string | yes | Skill name |
| `repo` | string | yes | `<owner>/<repo>` the run worked in |
| `idea` | string | no | When the run concerns an idea |
| `started` | string | yes | ISO 8601 |
| `finished` | string | yes | ISO 8601 |
| `outcome` | string | yes | `ok`, `asked` (posted questions), `skipped` (preconditions not met), `stopped` (hit a stop condition), `failed` |
| `next` | string | yes | The single next action, and whose it is ("owner: answer q1–q2", "none") |
| `session` | string | no | Session URL (`https://claude.ai/code/session_<id>`, spike S9) |
| `checks` | object | no | Named checks and their result, for example `{"leak-check": "pass"}` (ADR-017) |

```segoy
{"v": 1, "kind": "run", "skill": "triage", "repo": "<owner>/<brain>", "idea": "I-20260101-1",
 "started": "2026-01-01T12:00:00Z", "finished": "2026-01-01T12:01:10Z",
 "outcome": "asked", "next": "owner: answer q1–q2, then add the label answered",
 "session": "https://claude.ai/code/session_<id>"}
```

A skill that exits quietly in its preconditions (already handled, paused, not its event) posts **no** run block, to keep timelines clean.

**Every comment an agent posts carries a `run` block** (often in the same comment as a `question` block), and owner comments never do. Comments made through the session's GitHub tools appear under the owner's account (spike S11), so this is how skills and the app tell agent comments from the owner's: an owner reply is any comment without a `run` block that is newer than the newest comment with one. An `answer` block from the app does not make a comment an agent comment. A second signal, for labels and other issue events: actions made through Claude's GitHub tools appear in the issue's event list with `performed_via_github_app.slug` = `claude`; the owner's own actions have no app.

### 3.5 `spec` (M2)

At the end of a spec PR body in the brain (`segoy:spec`).

| Field | Type | Required | Notes |
|---|---|---|---|
| `idea` | string | yes | |
| `title` | string | yes | Short English title |
| `target` | string | yes | Target repo name (no owner), or `none` for "not code" |
| `criteria` | integer ≥ 1 | yes | Number of acceptance criteria |
| `open_questions` | integer ≥ 0 | yes | Questions the spec leaves open |
| `private_blocks` | integer ≥ 0 | yes | `<!-- private -->` blocks in the spec, which promotion will drop |

### 3.6 `plan` (M2)

At the end of a Gate 1 PR body in the project repo (`segoy:plan`). **This block is in the project repo, which may be public:** it carries nothing private, and assumption sources that point into the brain read `brain` rather than a path.

| Field | Type | Required | Notes |
|---|---|---|---|
| `idea` | string | yes | |
| `summary` | string | yes | One or two sentences |
| `assumptions` | array | yes | May be empty |
| `assumptions[].text` | string | yes | |
| `assumptions[].confidence` | string | yes | `firm`, `likely` or `guess` |
| `assumptions[].source` | string | yes | `owner-stated`, `brain`, `spec` or a path in this project repo |
| `tasks` | array, ≥ 1 | yes | Task groups |
| `tasks[].id` | string | yes | `T1`, `T2`, … |
| `tasks[].title` | string | yes | |
| `size` | string | yes | `S` (under a day of agent work), `M` (a few days), `L` (more; consider splitting) |
| `omitted_private` | integer ≥ 0 | yes | Private items left out by promotion |
| `checks` | object | yes | Must include `"leak-check": "pass"` (ADR-017) |

### 3.7 `decision` (M2)

A short note on the brain issue when the owner approves with changes, rejects, parks or explains a choice at a gate (M2-D2). The weekly review (M5) files these into `decisions/`. It usually rides in the same comment as a `run` block.

| Field | Type | Required | Notes |
|---|---|---|---|
| `idea` | string | yes | |
| `gate` | string | yes | `triage`, `spec`, `plan`, `impl`, `other` |
| `outcome` | string | yes | `approved`, `changed`, `rejected`, `parked` |
| `reason` | string | yes | In the owner's words, quoted; `none given` if there was none |

### 3.8 `impl` (M3)

At the end of a Gate 2 PR body in the project repo (`segoy:impl`). Like `plan`, it is in the project repo: nothing private.

| Field | Type | Required | Notes |
|---|---|---|---|
| `idea` | string | yes | |
| `criteria` | array, ≥ 1 | yes | One entry per acceptance criterion in the spec |
| `criteria[].id` | string | yes | The criterion's number in the spec, as a string (`"1"`) |
| `criteria[].text` | string | yes | Short form of the criterion |
| `criteria[].evidence` | string | yes | Test name and result, command output, or `path:line` |
| `criteria[].result` | string | yes | `pass`, `fail` or `unclear` (verifier's verdict) |
| `deviations` | array of strings | yes | Differences from the plan; empty when none |
| `tests` | object | no | `{"command": "…", "result": "pass"/"fail"}` for the repo's test command |

### 3.9 `review` (M5)

At the end of a weekly review PR body in the brain (`segoy:review`), followed by the `run` block. Written by `segoy-weekly-review`.

| Field | Type | Required | Notes |
|---|---|---|---|
| `week` | string | yes | ISO week of the run, `<yyyy>-W<ww>` |
| `period` | object | yes | `{"from": "<iso>", "to": "<iso>"}`: the 7 days ending at run time |
| `proposals` | array | yes | Proposed `ways/` changes, at most five; may be empty |
| `proposals[].id` | string | yes | `p1`, `p2`, … unique within the block |
| `proposals[].text` | string | yes | The proposed rule, one line |
| `proposals[].target` | string | yes | The `ways/` file it goes into, for example `ways/public/review.md` |
| `proposals[].source` | string | yes | Evidence: a link, `D-<yyyymmdd>-<n>` or a retro path |
| `filed` | object | yes | Counts of what the PR files: `notes`, `decisions`, `stubs`, `state_fixes` (integers ≥ 0) |
| `stuck` | array of strings | yes | Idea IDs with no state change for more than 14 days; may be empty |
| `stats` | object | yes | Free-form counts for the week, for example `{"runs": 12, "questions": 3, "assumptions": 9}` |

```segoy
{"v": 1, "kind": "review", "week": "2026-W01",
 "period": {"from": "2025-12-28T16:00:00Z", "to": "2026-01-04T16:00:00Z"},
 "proposals": [{"id": "p1", "text": "Ask platform questions before scope questions.", "target": "ways/public/principles.md", "source": "D-20260102-1"}],
 "filed": {"notes": 1, "decisions": 1, "stubs": 1, "state_fixes": 0},
 "stuck": ["I-20251201-1"], "stats": {"runs": 12, "questions": 3, "assumptions": 9}}
```

### 3.10 Outlines for later milestones

Kinds reserved for later milestones are listed here. Their fields are fixed in the milestone that first emits them, and the validator only checks the common fields until then. None are reserved at present.

## 4. Owner actions

Only owner actions start tasks (ADR-015). The app and GitHub mobile do the same things:

| Owner wants to | Does | Starts |
|---|---|---|
| Capture | Open an issue in the brain (prefix `note:` for knowledge, `me:` for personal context) | `brain-triage` |
| Answer questions | Comment (with an `answer` block from the app, or free text), **and add `answered`** | `brain-respond` |
| Give a command | Comment `/spec`, `/plan`, `/park`, `/unpark`, `/reject <reason>`, or `defaults`, **and add `answered`** | `brain-respond` |
| Approve a spec | Merge the `segoy:spec` PR | `brain-plan-promote-<repo>` |
| Gate 1 | Merge the `segoy:plan` PR in the project | `project-implement` |
| Ask for changes on a PR | Comment, **and add `answered`** | the matching respond or implement task |
| Gate 2 | Merge the `segoy:impl` PR | `project-retro` |
| Pause | Open an issue with the label `segoy:paused`; close it to resume | — |

Without the label, an answer or command is still picked up by the periodic `brain-respond` sweep. Skills remove `answered` once they have processed it.

## 5. Pause check (every skill, first step)

Before anything else, every skill does this:

1. List open issues in the current repo with the label `segoy:paused` (GitHub tools: list issues, state open, label filter).
2. If there is one, stop at once. Post nothing, change nothing. In the brain, this also stops promotion, so `promote` checks the brain as well as the project repo.
3. If the current event is the pause issue itself (opened or labelled), stop as well.

Skills copy this as their first Preconditions bullet: "No open issue labelled `segoy:paused` in this repo (protocol §5)."

## 6. Versioning

- `v: 1` is this document.
- Adding an optional field or a new kind is not breaking. Update this file and the validator in the same PR.
- Changing the meaning or type of a field, or making an optional field required, is breaking: introduce `v: 2` here and keep writing `v: 1` until readers support both.
