# Brain: cheat sheet

Everything here works from a phone: the Otak app, or GitHub mobile.

## Capture
Open a new issue. A title alone is enough. Write in whatever language you like; it is kept exactly as typed.
- No prefix: an idea.
- `note:` a link, quote or fact to keep (knowledge).
- `me:` something about you (goals, preferences); it becomes a PR to `self/` for you to approve.

Within a few minutes the issue gets labels and a short comment: a restatement, related items, a suggested target, and at most three questions, each with a default.

## Answer
Reply in a comment, **then add the label `answered`**. The label is what wakes the agent; Otak adds it for you. Forgot it? The next sweep (every few hours) picks up your reply anyway.
- One line per question is enough, or just `defaults`.
- Commands, also followed by the label: `/spec`, `/plan`, `/park`, `/unpark`, `/reject <reason>`.

## Approve
- **Spec**: a PR here labelled `segoy:spec`. Merge to approve. To ask for changes, comment and add `answered`.
- **Gate 1**: a PR in the project repo labelled `segoy:plan`. Merge to start the build.
- **Gate 2**: a PR in the project repo labelled `segoy:impl`. Merge to accept.

## Labels
| Label | Means |
|---|---|
| `state:inbox` … `state:done` | Where an idea is. Exactly one per issue |
| `state:needs-input` | Waiting for you |
| `kind:idea` / `note` / `task` / `self` | What a capture is |
| `target:<repo>` | Where an idea will be built |
| `segoy:spec` / `plan` / `impl` / `retro` / `review` / `knowledge` | What a PR is |
| `answered` | You replied: go on |
| `segoy:paused` | Automation is paused |

## Pause
Open an issue titled "Pause" with the label `segoy:paused`. Close it to resume.

## Stuck?
Every run ends with a short "run" comment saying what happened and the single next action. If nothing happened within ten minutes of an action, check the scheduled task in claude.ai/code and its last run.
