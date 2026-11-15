# Segoy — Product Requirements Document

Version 0.1 (draft for bootstrap), 2026-11-14.

## 1. Summary

Segoy is an open-source kit that turns Claude Code and GitHub into a personal idea-to-implementation system. You capture an idea from your phone; agents refine it into a spec and a plan; you approve the plan; agents implement it in the right repository and open a pull request; you approve the PR; what was learned flows back into your private brain.

Three parts form the core:

- **Segoy** (public): the generic tool. Skills, agents, hooks, templates, task prompts, and scripts. Contains nothing personal. Segoy is also project number one, built using itself.
- **Roke** (private): one person's brain, instantiated from Segoy's brain template. Ideas and backlog, ways of working, knowledge notes, and personal context.

- **Otak** (public, own repository): a native Android app that is the primary way to capture ideas, monitor agents and projects, answer agent questions, and make gate decisions. It talks only to GitHub; there is no backend. Spec: `docs/otak-app-spec.md`.

Every other project gets its own repository, scaffolded by Segoy.

The name: in Earthsea, Segoy raised the islands by speaking their true names. Stating an idea precisely is what brings it into being.

## 2. Problem

- Ideas arrive at random moments, mostly away from a computer, and are lost or pile up unprocessed.
- Turning an idea into a working change requires many small steps (clarify, design, plan, set up, implement, test, review) that an agent can do, but only if it has durable context about the idea and about how the owner likes things done.
- Agent sessions forget. Preferences and decisions get re-explained every time.
- Personal context is valuable to agents and must not leak into public repositories.

## 3. Goals

1. **Capture in under 30 seconds from a phone**, as text, with no structure required.
2. **Idea → approved plan with at most two human touches** (answering clarifying questions; approving the plan).
3. **Approved plan → reviewable PR with no human touch.**
4. **Agents get better over time** because ways of working and decisions accumulate in Roke and are applied automatically.
5. **Nothing private reaches a public repo** without an explicit, reviewed promotion step.
6. **Segoy is reusable by anyone**: a stranger can create their own brain repo from the template and run the same pipeline.
7. **Zero hosted infrastructure**: only GitHub, a Claude subscription, and an app on the phone.
8. **One place on the phone** for capture, status, answers, and decisions.

### Non-goals (v1)

- Chat-bot front ends, iOS or web apps, any hosted backend or push relay.
- Self-hosted or local agent runtimes (local Claude Code still works on the same files, but nothing depends on it).
- Auto-merge of anything. Every change lands through a PR the user merges.
- Fine-tuning or embedding-based retrieval.
- Impersonation: Segoy does not send messages or make decisions as the user outside GitHub PRs/issues in the user's own repos.
- Multi-user collaboration inside one brain.

## 4. User and context

A single technical user with a Claude Pro or Max plan and a GitHub account. Works mostly from a phone for capture and review, and from a computer for deeper sessions. Comfortable reading diffs. Wants control at two gates (plan, PR) and autonomy everywhere else.

## 5. Scope decisions already made

| Topic | Decision |
|---|---|
| Capture channel | The Otak Android app (text first; voice, share sheet, widget later). Underneath, a capture is a GitHub issue in Roke, so GitHub mobile and the Claude mobile app remain working fallbacks, and are the capture path until Otak's first milestone ships. |
| Mobile app | Otak: native Kotlin, backend-free, polling instead of push. |
| Runtime | Cloud, GitHub-centred: Claude Code cloud sessions and scheduled tasks with GitHub triggers. GitHub Action as fallback. |
| Autonomy | Two approval gates: plan and PR. No auto-merge. |
| Roke v1 contents | Ideas and backlog; ways of working; knowledge notes; personal context. |
| Substrate | Markdown with YAML frontmatter in git. |
| Distribution | Segoy files are vendored into each repo by a sync script. |

## 6. The lifecycle

```
capture → triage → spec → plan ──(GATE 1: you approve plan)──▶ implement → PR ──(GATE 2: you merge)──▶ retro → brain update
└───────────── private, in Roke ─────────────┘└─ promotion ─┘└──────────── in the project repo ────────────┘
```

States of an idea (tracked as a label on its Roke issue and in the idea file's frontmatter):
`inbox → triaged → needs-input → specced → planned → promoted → building → in-review → done` plus `parked` and `rejected`.

## 7. Functional requirements

Priority: **M** must for v1, **S** should, **C** could/later.

### 7.1 Capture
- FR-1 (M) Creating an issue in Roke with any text captures an idea. No template required; a title alone is valid.
- FR-2 (M) A capture never blocks on the user. The agent files it and acknowledges with a comment.
- FR-3 (S) A message to a Roke cloud session beginning with "idea:" or "note:" is captured the same way.
- FR-4 (S) Captures can be knowledge ("note:", a link, a quote) rather than ideas; triage routes them to the knowledge inbox.

### 7.2 Triage
- FR-5 (M) On a new Roke issue, an agent classifies it (idea / note / task for an existing project / personal-context update), links related existing items, and labels the issue. Files are created later, by PRs the owner merges (ADR-018).
- FR-6 (M) For ideas, the agent posts a short triage comment: one-paragraph restatement, related ideas/projects, suggested target (new project, existing project, Segoy itself, not code), and up to three clarifying questions only if needed.
- FR-7 (M) Before asking a question, the agent checks Roke for an answer (ways of working, earlier decisions, personal context). Questions the brain can answer are not asked; the assumption is recorded instead.
- FR-8 (S) Duplicates are merged into the existing idea with a comment.

### 7.3 Spec
- FR-9 (M) When an idea has enough input (or the user comments `/spec`), an agent writes `ideas/<id>-<slug>/spec.md`: problem, users, outcomes, scope/non-scope, acceptance criteria, open questions, assumptions with their source in Roke.
- FR-10 (M) The spec arrives as a PR in Roke linked to the issue. Review comments are handled by the agent once the owner adds the answer label (ADR-016).
- FR-11 (S) The spec lists which parts are `shareable` and which are `private`.

### 7.4 Plan and Gate 1
- FR-12 (M) After the spec is merged (or on `/plan`), an agent writes a plan: target repo, architecture notes, task breakdown with acceptance checks, test approach, risks, estimated size.
- FR-13 (M) **Promotion**: the plan and the shareable part of the spec are opened as a PR in the target project repo under `docs/specs/<id>-<slug>/`. This PR is Gate 1. Merging it is approval. Closing it is rejection.
- FR-14 (M) The promotion PR contains no content marked `private` and passes the leak check.
- FR-15 (M) If the target repo does not exist, the agent prepares everything and tells the user the one manual step (create an empty repo), then scaffolds it once it exists.
- FR-16 (S) The user can request changes by commenting on the PR and adding the answer label; the agent revises.

### 7.5 Implement and Gate 2
- FR-17 (M) When a promotion PR is merged, an agent in the project repo implements the plan's tasks on a `claude/` branch, runs the checks the plan names, and opens a PR that references the spec and lists each acceptance criterion with its evidence.
- FR-18 (M) The implementation session uses only the project repo. Roke is not available to it.
- FR-19 (M) The agent never merges. Gate 2 is the user merging.
- FR-20 (S) Review comments plus the answer label are handled by the agent. Auto-fix for CI failures is used if it works for PRs opened by scheduled tasks (to verify in M3).
- FR-21 (S) Large plans are implemented as a sequence of PRs, one per task group.

### 7.6 Learn
- FR-22 (M) After merge, a short retro is written into the project repo (`docs/retros/`): what was built, deviations from plan, problems, and suggested changes to ways of working.
- FR-23 (M) A weekly review task in Roke reads recent retros and activity and opens one PR in Roke with: status updates for ideas and projects, proposed additions or changes to `ways/`, and a short digest for the user.
- FR-24 (S) Corrections the user gives in reviews are proposed as ways-of-working entries, never applied silently.

### 7.7 Roke as second brain
- FR-25 (M) Knowledge follows ingest / query / lint: sources stored unmodified under `knowledge/raw/`; agent-maintained pages under `knowledge/wiki/` with index and log; a scheduled lint that reports contradictions, orphans, and stale pages.
- FR-26 (M) Every agent write to Roke appends to a log and lands as a PR or a clearly attributed commit.
- FR-27 (S) "Ask Roke": in a Roke session the user can ask questions and get answers that cite files.

### 7.8 Personal context (twin)
- FR-28 (M) `self/` holds profile, goals, values, preferences, and constraints, each entry with source and date. Only user-stated or user-confirmed content is merged.
- FR-29 (M) Decisions made at gates (approve, reject, change requested, with the reason) are recorded as decision records in Roke.
- FR-30 (S) Triage and planning use goals to suggest priority and flag ideas that conflict with stated goals or constraints.
- FR-31 (C) Read-only calendar and email context through connectors, pulled on demand.

### 7.9 Segoy as a tool
- FR-32 (M) `segoy init brain` creates a brain repo's contents from the template; `segoy init project` scaffolds a project repo; `segoy sync` updates vendored files in a repo to a given Segoy version and reports local modifications instead of overwriting them.
- FR-33 (M) Scheduled-task prompts live in the Segoy repo as versioned files with setup instructions.
- FR-34 (M) Segoy's own repo is set up with `segoy init project` and developed through the pipeline.
- FR-35 (S) A plugin/marketplace manifest so the kit can also be installed as a Claude Code plugin locally.

### 7.10 Otak (Android app)
Detail in `docs/otak-app-spec.md`.
- FR-36 (M) Capture text from the app into Roke in one screen; works offline with a queue.
- FR-37 (M) Inbox of everything waiting on the owner: agent questions with one-tap answers and defaults, Gate 1 plan approvals, Gate 2 PR reviews, failed runs.
- FR-38 (M) Approve, request changes, or reject at both gates from the app; a reject asks for a one-line reason that becomes a decision record.
- FR-39 (M) Status: ideas by state per project, idea timeline, agent activity feed.
- FR-40 (M) All skills emit the machine-readable blocks defined in `docs/protocol.md` so the app never parses prose; plain GitHub use keeps working.
- FR-41 (S) Notifications by background polling; pause switch for automation.
- FR-42 (S) Share target, home-screen widget, quick-settings tile, voice capture with on-device transcription. (Photo capture is deferred.)
- FR-43 (S) Biometric lock; minimal-scope token; no analytics.
- FR-45 (M) The app follows the Segoy design system (`design-system/`): terminal-style, monospace, glyphs, meaning-based colour, both themes; every control is touch-sized and nothing requires typing a command. Tokens are generated for Android from `tokens.json`; missing components are added to the design system before they are built in the app.
- FR-44 (C) Brain reader and quick edits as PRs; weekly review handling; asynchronous "Ask Roke".

## 8. Non-functional requirements

- NFR-1 Privacy: Roke is private; implementation sessions never mount it; promotion is one-way and reviewed; a leak check runs as a hook and in CI on public repos.
- NFR-2 Least privilege: each scheduled task lists only the repos and connectors it needs; default network allowlist.
- NFR-3 Transparency: every agent action is visible as an issue comment, commit, or PR. No hidden state outside git and GitHub.
- NFR-4 Portability: Roke is useful with any editor and any future model; no proprietary formats.
- NFR-5 Recoverability: any agent change can be reverted with git; raw sources are never edited.
- NFR-6 Cost awareness: tasks are event-driven, not polling; each task prompt states a budget ("stop and report if this needs more than N steps"); weekly digest reports run counts.
- NFR-7 Genericity: no personal names, paths, or preferences in Segoy; all such values come from the brain repo's config.
- NFR-8 Robustness to platform change: task prompts and skills are plain files, so the trigger mechanism can be swapped (scheduled task ↔ GitHub Action) without rewriting the logic.

## 9. Success measures

- Median capture time on phone under 30 seconds.
- Share of captured ideas triaged within one hour: over 90%.
- Human touches from capture to approved plan: two or fewer for at least 70% of ideas.
- Share of implementation PRs merged with at most one round of review comments: over 60% after the first month.
- Zero private-content leaks to public repos.
- At least one ways-of-working change proposed per week that the user accepts.

## 10. Milestones

- **M0 Foundations**: repos, GitHub App, docs in place, platform spikes done.
- **M1 Brain**: Roke template, capture and triage working from the phone.
- **M2 Spec and plan**: spec/plan skills, promotion with leak check, Gate 1.
- **M3 Implement**: implementation and review loop in a project repo, Gate 2, retro.
- **M4 Self-hosting**: Segoy developed through its own pipeline; `segoy sync`.
- **M5 Learning loop and knowledge**: weekly review, ways-of-working proposals, ingest/query/lint.
- **M6 Twin**: decision records feeding triage and planning; goal-based prioritisation; optional connectors.
- **Otak O1–O6** run in parallel from M3 onward as the first project built through the pipeline: capture MVP, inbox and gates, status, fast capture, brain, polish. The agent–app protocol is defined in M1 so skills emit it from the start.

Detail in `docs/bootstrap-plan.md`.

## 11. Risks

| Risk | Mitigation |
|---|---|
| Scheduled tasks are a research preview; triggers or limits may change. | Logic lives in skills; triggers are thin and replaceable (ADR-021: dispatcher or own server). |
| Triggers miss things or fire too often: comments and agent-opened issues start nothing, agent-added labels do; caps drop events (spike S3, M1 staging). | Owner actions drive every step and label triggers filter on their label (ADR-015); answer label plus periodic sweep (ADR-016); weekly review lists stuck ideas. |
| Behaviour depends on the model, not the platform: pushing to `main`, branch names (spike S11). | Nothing relies on it: no direct commits (ADR-018), artefacts found by label and ID (ADR-020), rulesets before going public (T4.3). |
| Repo-committed skills might not load in some session types. | Single-repo sessions by default; spike S1/S2 verifies; fall back to prompts that read the skill files explicitly. |
| Private content leaks during promotion. | `visibility` frontmatter default private; promotion skill checklist with a mandatory leak-check step (hooks do not run in the two-repo promotion run, ADR-017); required CI check; Gate 1 is also a human privacy review. |
| Agent acts under the user's GitHub identity (issues, comments, PRs; commits are authored `Claude`, ADR-019). | Rulesets on `main` everywhere from T4.3; no auto-merge; tasks trimmed to needed repos; default connectors removed. |
| Brain quality decays (wrong inferred preferences, stale notes). | Stated-only rule for `self/` and `ways/`; lint; weekly review PR. |
| Usage limits consumed by automation. | Event-driven tasks, budgets in prompts, smaller model for triage and lint. |
| No backend means no instant push; notifications can lag by 15 minutes or more. | Accepted trade-off; app refreshes on open; GitHub's own notifications remain available. |
| Agents cannot test on a device; Android builds need `dl.google.com`, outside the default allowlist. | JVM unit and screenshot tests, CI-built APK, owner device check at Gate 2, thin PRs; a separate Otak environment with that host and an SDK setup script (spike S8). |
| Over-engineering before first value. | M1 delivers capture+triage alone; each milestone is usable by itself. |

## 12. Open questions

See `docs/README.md`, section "Decisions".
