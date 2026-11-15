# Segoy — Workflows

Version 0.2, 2026-11-15 (updated with the M0 spike results). Step-by-step behaviour of each flow. This is the acceptance reference for skills.

## 1. State machine for an idea

| State | Meaning | Entered by | Next |
|---|---|---|---|
| `inbox` | Issue exists, untouched | Owner creates issue | `triaged`, `needs-input` |
| `triaged` | Classified, filed, linked | `triage` | `specced` |
| `needs-input` | Waiting for owner's answer | `triage`/`spec`/`plan` | back to previous on answer |
| `specced` | Spec merged in Roke | Owner merges spec PR | `planned` |
| `planned` | Private plan drafted | `plan` | `promoted` |
| `promoted` | Gate 1 PR open in project repo | `promote` | `building` (merged), `specced` (closed with change request), `rejected` |
| `building` | Implementation in progress | Gate 1 merge | `in-review` |
| `in-review` | Gate 2 PR open | `implement` | `done`, back to `building` on changes |
| `done` | Merged; retro written | Gate 2 merge + `retro` | — |
| `parked` | Deliberately paused | `/park` | any, on `/unpark` |
| `rejected` | Will not do | `/reject` | — |

**What moves an idea.** Only owner actions start tasks (ADR-015):
- opening an issue (capture);
- adding the answer label `answered` to an issue or PR (answers and commands, ADR-016);
- merging a spec PR;
- merging the Gate 1 PR;
- merging the Gate 2 PR.

Everything between two owner actions happens inside one run, or in the periodic `brain-respond` sweep or the weekly review. Comments alone start nothing; the sweep picks up an answer that arrived without the label. States the brain cannot see happen (`building`, `in-review`, `done`, all in the project repo) are brought up to date by the next brain run or the weekly review.

The Roke issue carries exactly one `state:*` label. Once the spec PR has created the idea file (ADR-018), its frontmatter mirrors the label. The issue stays open until `done` or `rejected`. Each transition adds one comment on the Roke issue with a link to the artefact (PR, file), so the issue is the timeline.

## 2. Flow A — Capture and triage

1. Owner captures in Otak (or, as fallback, opens GitHub mobile → Roke → new issue). Either way the result is a Roke issue. Title only is fine. Optional prefixes: `note:` for knowledge, `me:` for personal context.
2. Trigger `brain-triage` starts a session on Roke with the prompt in `tasks/brain-triage.md`.
3. `triage`:
   1. Read the issue and its labels. Exit quietly if it already has a `state:*` label, or if it is the `segoy:paused` issue. The issue trigger fires on every issue event.
   2. Classify: idea / note / task-for-existing-project / self-update.
   3. **Idea**: assign the ID; search `ideas/index.md`, `projects/index.md` and **open Roke issues** for related or duplicate items. Triage writes **no files** (ADR-018): the issue is the idea's record until the spec PR creates `ideas/<id>-<slug>/idea.md`.
   4. Apply "consult the brain before asking" (brain design §5).
   5. Comment on the issue (see format below), writing in `notes_language`. The capture stays as typed. Set labels `kind:idea`, `state:triaged` or `state:needs-input`, and `target:*` if clear.
   6. **Note**: label `kind:note` and acknowledge. The weekly review PR saves it verbatim to `knowledge/raw/` and links it, then the issue is closed. Ingest follows from there.
   7. **Task for existing project**: propose creating an issue in that project repo; do it if the content is shareable, otherwise ask.
   8. **Self-update**: open a PR against `self/` quoting the owner's words; never commit directly.

Triage comment format (short enough for a phone screen):

```
**I-20261114-1 — <title>**
<2–3 sentence restatement>
Related: <links or "none">
Suggested target: <new project "x" | repo | not code>
Assumed from your notes: <1–3 bullets with links, or "nothing">
Questions (reply in one line each, or say "defaults"):
1. … (default: …)
Next: reply and add the label `answered`, or comment /spec and add `answered` to proceed with defaults.
```

**Answering.** The owner replies in a comment and adds the label `answered`. Otak does both in one tap (ADR-016). The label fires `brain-respond`, which reads the answer, removes the label, and continues: back to triage, or on to spec. A reply without the label is picked up by the periodic sweep. Commands (`/spec`, `/plan`, `/park`, `/unpark`, `/reject <reason>`) work the same way.

The comment ends with a `segoy` block of kind `question` carrying the same questions, options and defaults as JSON (see `docs/protocol.md`), so Otak can render one-tap answers. The same rule applies to every artefact below: Gate 1 PR bodies end with a `plan` block, Gate 2 PR bodies with an `impl` block, the weekly review PR with a `review` block, and every skill run ends with a `run` record comment.

## 3. Flow B — Spec

1. Runs inside `brain-respond`. Start condition: state `triaged` and no open questions; or the owner commented `/spec`; or the owner answered the questions. Triage does not start spec in the same run.
2. `spec` writes `idea.md` (from the issue, ADR-018), `spec.md` and the `ideas/index.md` entry, using the answers, ways and related knowledge. Marks private parts. Acceptance criteria must be testable statements. Sets the `target:<repo>` label on the PR; promotion depends on it.
3. Opens a PR in Roke: label `segoy:spec`, title `Spec: <title> (<id>)`; the branch name is best effort (ADR-020). Body = summary + assumptions + open questions.
4. Owner reviews on the phone. To request a revision: comment on the PR **and add the label `answered`**, which `brain-respond` also listens to on PRs. Whether the run that opened the PR can instead pick up review comments through auto-fix in a scheduled task is unverified; check it in T2.5. Merge → state `specced`.
5. Decisions with reasons (changes requested, `/reject`, `/park`) are recorded as a `decision` block in the agent's comment on the issue or PR (protocol §3.7). The weekly review files them into `decisions/` (M2-D2).

Small ideas: if triage judges the idea is a small change to an existing project (config value: under ~1 day of agent work and no open questions), spec and plan are produced together in one Roke PR, then promoted. Two artefacts, one review.

## 4. Flow C — Plan and promotion (Gate 1)

1. Trigger: the owner merges a spec PR labelled `segoy:spec` and `target:<repo>`. This fires `brain-plan-promote-<repo>`, one task per project repo (architecture §4).
2. `plan`:
   1. Precondition: the target repo and its promotion task exist. A new project has to be set up **before** its spec is merged: the spec PR body says so and links Flow G. If the task is missing, nothing fires, and the weekly review lists the idea as stuck in `specced`.
   2. Read target repo `CLAUDE.md`, structure, existing specs.
   3. Write the plan into a scratch file (not committed in the brain, M2-D1): approach, components touched, task groups (each with files, steps, acceptance checks, commands to run), test plan, risks, rollout, size estimate, *assumptions at the top*.
3. `promote`:
   1. Build project-side `docs/specs/<id>-<slug>/spec.md` and `plan.md`: drop `<!-- private -->` blocks, rewrite references to Roke files as plain statements, remove personal context.
   2. **Mandatory:** run `leak-guard.sh` with the Roke denylist plus the generic patterns over every file to be committed. This is a skill step, not a hook, because hooks do not run in two-repo sessions (ADR-017). Any hit: stop, state `needs-input`, comment in Roke (not in the project repo). The run record states that the check ran and passed.
   3. Open the PR in the project repo: label `segoy:plan`, title `Plan: <title> (<id>)`; the branch name is best effort. The project's CI runs the generic leak check as a required check. Body: what and why in five lines, task list, assumptions, "omitted N private items", how to approve (merge) or request changes (comment).
   4. Update Roke: state `promoted`; one comment on the idea's issue with the PR link and the **private side** of the plan (the omitted private items, summarised). The issue is the record (M2-D1).
4. **Gate 1**: owner merges (approve), comments and adds `answered` (revise), or closes (reject). A merge fires `project-implement` (M3) and `brain-gate-sync-<repo>`, which moves the brain issue to `building`. A close also fires `brain-gate-sync-<repo>`, which asks in the brain: re-plan, park or reject. A revision request on a project PR is handled by the project-side `implement` task, which also listens for `answered` on `segoy:plan` PRs. A close fires nothing; the next brain run or the weekly review sees it, asks for the reason in Roke, and records a decision.

## 5. Flow D — Implementation (Gate 2)

1. Trigger: PR with label `segoy:plan` merged in the project repo (`project-implement`; **Run now** catches up a merge made before the task existed). Session mounts the project repo only. Skill: `segoy-implement`.
2. `implement`:
   1. Read `docs/specs/<id>/spec.md` and `plan.md`, repo `CLAUDE.md`.
   2. Branch `claude/impl-<id>-<slug>` if the run may create it, otherwise the assigned branch (ADR-020).
   3. For each task group: delegate to `implementer` subagent or do inline; run the group's checks; commit with message `<id>: <task>`.
   4. If the plan is wrong or blocked: stop, open a draft PR with what exists, explain, and propose the plan change in the PR body (the spec folder is not edited). Do not improvise beyond the plan's scope.
   5. `verifier` subagent (fresh context): for each acceptance criterion, find evidence (test name, command output, file/line). Missing evidence → back to step 3 or flag in PR.
   6. Run the repo's tests and lint (from `CLAUDE.md`), then open the PR: label `segoy:impl`, title `Impl: <title> (<id>)`; body = summary, criterion-by-criterion evidence table, deviations, how to try it, follow-ups, `impl` + `run` blocks (protocol §3.8). Draft if any check or criterion fails.
3. **Gate 2**: owner reviews and merges. To ask for changes, including a CI failure: comment and add the label `answered`, which fires `project-implement-pr` (revise mode, pushes to the same PR). Merging fires `project-retro` and `brain-gate-sync-<repo>` (brain issue → `done`, closed). Closing without merging asks in the brain: retry, park or reject.
4. Plans marked `multi-pr` are not supported yet (M3-D1): `segoy-implement` stops and says so; `segoy-plan` proposes splitting large ideas instead.

## 6. Flow E — Retro and learning

1. Trigger: PR with label `segoy:impl` merged (`project-retro`).
2. `retro` writes `docs/retros/<id>.md`: built vs planned, what went wrong, review comments received (paraphrased), suggested rule changes. Small PR `segoy:retro`. No direct commits (see ADR-018 for why).
3. `brain-weekly-review` (in Roke, weekly):
   1. List merged/closed Segoy-labelled PRs across project repos since last run (GitHub tools, read-only).
   2. Update idea states and `projects/*.md`.
   3. Create decision records for gate outcomes not yet recorded.
   4. From retros and decision records, propose at most five changes to `ways/` (each with evidence links). Public-safe ones go to `ways/public/`.
   5. Write `journal/<year>-W<week>.md`: what moved, what is stuck and why, questions waiting on the owner, automation stats (runs, questions asked vs assumptions made), top three suggested next ideas given `self/goals.md`.
   6. One PR `segoy:review`. Merging accepts the proposals; editing the PR before merge is how the owner corrects them.
4. After `ways/public/` changes, the review PR lists project repos whose `CLAUDE.md` is now behind and offers to run `segoy sync` there (each as its own small PR).

## 7. Flow F — Knowledge

- **Ingest**: `note:` issue or file added under `knowledge/raw/` → `ingest` → PR `segoy:knowledge` updating wiki pages, index, log.
- **Query**: in a Roke session, "ask: …" → answer with citations; offer to save as synthesis.
- **Lint**: weekly → issue titled `Lint <date>` with findings; mechanical fixes as a PR.

## 8. Flow G — New project

1. Idea's target is "new project `<name>`".
2. Owner creates the empty repo (name, visibility) and installs the Claude GitHub App on it. The agent gives the exact steps.
3. A session on the new repo runs `segoy init project`: `CLAUDE.md` from template + `ways/public/`, `.claude/`, `docs/`, CI workflow, README stub, labels, branch protection instructions.
4. The agent prints the settings for the two per-repo tasks (`project-implement`, `project-retro`) for the owner to create.
5. `projects/<repo>.md` added in Roke.

## 9. Flow H — Segoy improving itself

Same as any project. Ideas about Segoy are captured in Roke, promoted to the public Segoy repo, implemented there. After a Segoy release, `segoy sync` PRs are opened in Roke and project repos by the weekly review. Rule: a Segoy change that alters a skill used in the pipeline must include a test fixture or a dry-run transcript in the PR.

## 10. Failure handling (all flows)

- Every skill first checks for an open `segoy:paused` issue in its repo and exits quietly if one exists.
- Every skill has a budget and a stop condition. On stop: comment where the owner will see it (Roke issue for brain flows; PR for project flows) with what was done, what blocked, and the single next action needed.
- Idempotence: skills check current state first and exit if their output already exists.
- No silent retries across runs. A failed run leaves a `state:needs-input` label and a comment.
- Safety nets for missed triggers: the periodic `brain-respond` sweep (answers without the label) and the weekly review (ideas stuck in a state for more than N days, missing promotion tasks, events dropped by trigger caps, disabled tasks).
