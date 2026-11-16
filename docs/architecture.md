# Segoy — Architecture

> **Roke** is the author's own brain repo (private). These docs use it as the worked example; read it as "your brain", the private repo you create from `kit/brain`.

Version 0.2, 2026-11-15 (updated with the M0 spike results). Read `docs/prd.md` first.

## 1. Principles

1. **Files are the system.** Skills, prompts, specs, plans, notes: all markdown in git. GitHub issues, labels, and PRs are the only UI and the only event source.
2. **Thin triggers, fat skills.** A trigger's prompt says "run skill X on event Y". All procedure lives in a skill file so it can be tested, versioned, and run from any surface.
3. **One repo per session.** Each agent run works in a single repository wherever possible. The one exception is promotion.
4. **One-way, reviewed flow from private to project.** Roke content reaches a project repo only inside a promotion PR that a human merges.
5. **Stated over inferred.** Agents propose; the user's merge makes it true.
6. **Generic tool, personal instance.** Segoy has no personal data. Everything personal is in the brain repo and its config.

## 2. Repositories

```
<owner>/segoy        public   the kit + its own docs; project #1
<owner>/roke         private  the brain (instance of Segoy's brain template)
<owner>/otak         public   Android companion app (Kotlin, backend-free); a normal project repo
<owner>/<project>    any      one per project, scaffolded by Segoy
```

### 2.1 Segoy repo layout

```
segoy/
├── README.md  LICENSE  CLAUDE.md
├── docs/
│   ├── prd.md  architecture.md  brain-design.md  workflows.md
│   ├── adr/                     # architecture decision records
│   └── specs/  retros/          # produced by the pipeline (dogfooding)
├── design-system/             # exists today: tokens.json, brand book, sg- CSS components,
│   │                          # build.py (builds dist/segoy.css, checks contrast); to add:
│   └── dist/android/          # generated SegoyTokens.kt for Otak
├── kit/
│   ├── common/                  # vendored into every repo
│   │   └── .claude/
│   │       └── scripts/leak-guard.sh  strip-private.sh   # no hook: brains hold personal data
│   ├── project/                 # vendored into project repos (segoy init project)
│   │   ├── CLAUDE.md.tmpl       # filled with repo name + brain ways/public, leak-checked
│   │   ├── .claude/hooks/leak-check-commit.sh  .claude/scripts/project-leak-check.sh
│   │   ├── .segoy/labels.json  config.yml.tmpl  # leak_skip_rules / leak_exclude
│   │   ├── .claude/skills/{implement,review-pr,retro}/SKILL.md
│   │   ├── .claude/agents/{implementer,verifier}.md
│   │   ├── .claude/settings.json
│   │   ├── .github/workflows/segoy-ci.yml      # leak check + basic checks
│   │   └── docs/{specs,retros}/.gitkeep
│   └── brain/                   # template for a brain repo
│       ├── CLAUDE.md            # the brain schema (see brain-design)
│       ├── .claude/skills/{capture,triage,spec,plan,promote,
│       │                    ingest,query,lint,weekly-review,record-decision}/SKILL.md
│       ├── .claude/settings.json
│       ├── .segoy/config.yml.tmpl  labels.json  denylist.txt
│       ├── .github/ISSUE_TEMPLATE/capture.md
│       └── <folder skeleton with index.md files>
├── tasks/                       # trigger definitions: prompt + setup notes
│   ├── brain-triage.md  brain-spec.md  brain-plan-promote.md
│   ├── project-implement.md  project-retro.md
│   └── brain-weekly-review.md  brain-lint.md
├── scripts/
│   ├── segoy               # entry point: init brain | init project | sync | doctor
│   └── lib/
├── tests/                  # fixture repos + checks for scripts and skill frontmatter
├── .claude/                # Segoy's own vendored copy of kit/common + kit/project
├── .segoy/version          # kit version vendored here
└── .github/workflows/ci.yml
```

### 2.2 Vendoring and versioning

- `segoy init` copies `kit/common` plus `kit/project` or `kit/brain` into the target repo and writes `.segoy/version` and `.segoy/manifest.json` (path → content hash when Segoy last wrote the file).
- `segoy sync` (M4) updates **kit-managed** files: everything under `.claude/`, `.github/workflows/segoy-*`, `.github/ISSUE_TEMPLATE/*`, `.segoy/labels.json`, and the brain's `CLAUDE.md`. A managed file whose hash still matches the manifest is replaced; one the repo changed is left alone and the new version is written beside it as `<file>.segoy-new`. A managed file the repo deleted is restored. A managed file that left the kit is reported as `orphan`, never deleted.
- Every other kit file (config, denylist, a project's generated `CLAUDE.md`, the brain's skeleton and notes) belongs to the repo after init: sync adds it only if it was never there, and never changes it.
- `segoy sync --pr` commits on a `claude/` branch and opens the PR through the REST API; the `kit-sync` task runs it weekly (M4-D3).
- Kit skills are namespaced by directory name prefix `segoy-` once vendored, so a repo's own skills cannot collide.
- Segoy uses semantic versions (`VERSION`), `CHANGELOG.md`, and a `v<x.y.z>` tag and release per version. A version that needs more than sync ships `migrations/<version>.md`, which an agent or the owner can follow; `segoy sync` lists the ones a repo has not had (by its `.segoy/version`) and counts a version change as a change, so the PR records the new version.
- Implementation language for scripts: POSIX shell + `git` + `gh` + `jq` for v1 (all present in cloud sessions and on any dev machine). Revisit if logic outgrows shell (ADR-003).

## 3. Runtime components

| Component | Where it runs | Role |
|---|---|---|
| Otak (Android app) | The owner's phone; talks to the GitHub API only | Capture, inbox for questions and gates, status, activity. Polls; no backend |
| Fallback surfaces | GitHub mobile (issue in Roke), Claude mobile Code tab (session on Roke) | Same data, no app needed |
| Scheduled tasks with GitHub triggers | Anthropic cloud | Event bus: starts a cloud session with a saved prompt on issue/PR events or on a schedule |
| Cloud sessions | Anthropic cloud VM, fresh clone | Execute skills |
| Skills / agents / hooks | In each repo's `.claude/` | The procedures and guardrails |
| GitHub | — | State (issues, labels, PRs, branches), review UI, CI |
| Claude GitHub App | Installed on segoy, roke, and each project repo | Webhooks for triggers and auto-fix |
| GitHub Action (`claude-code-action`) | GitHub runners | Fallback trigger path; also CI for leak check (no model needed) |

## 4. Trigger map

Each row is one scheduled task (file in `tasks/`). "Repos" is what the task mounts. "Started by" is the owner action that fires it. Only owner actions are meant to start tasks (ADR-015). Issues opened and comments made through Claude's GitHub tools start nothing; **labels added through them do fire `issues.labeled`**, so label triggers always filter on the one label they serve (ADR-015 amendment).

| Task | Trigger | Started by | Repos | Skill | Output |
|---|---|---|---|---|---|
| brain-triage | `issues.opened` in Roke | Owner captures (Otak or GitHub) | roke | `triage` | Labels, idea ID, triage comment. No files (ADR-018) |
| brain-respond | `issues.labeled` and `pull_request.labeled` in Roke, **filter: label `answered`** **and** a periodic schedule (sweep, every 4 hours by default) | Owner answers, comments a command or asks for spec changes, then adds the answer label; or the sweep finds an unlabelled answer | roke | `triage` → `spec` or `plan`, depending on state and commands | Updated issue, spec PR in Roke (ADR-016) |
| brain-plan-promote-`<repo>` | `pull_request.closed` in Roke, filters: Is merged, label `segoy:spec`, label `target:<repo>` | Owner merges a spec PR | roke + `<repo>` | `plan` then `promote` | Promotion PR in the project repo (Gate 1) |
| brain-gate-sync-`<repo>` | `pull_request.closed` in the **project**, filter: label `segoy:plan` or `segoy:impl` (merged or not) | Owner merges or closes Gate 1 or Gate 2 | roke + `<repo>` | `gate-sync` | Brain issue → `building` / `done` (closed), or asks why |
| project-implement | `pull_request.closed`, filters: Is merged, label `segoy:plan` | Owner merges Gate 1 | project | `implement` | Gate 2 PR (`segoy:impl`), single-PR plans only (M3-D1) |
| project-implement-pr | `pull_request.labeled`, filter label `answered` | Owner asks for changes on a Gate 2 PR | project | `implement` (revise) | New commits on the same PR |
| project-retro | `pull_request.closed`, filters: Is merged, label `segoy:impl` | Owner merges Gate 2 | project | `retro` | Retro PR; state noted for the brain to pick up |
| kit-sync | Weekly schedule (plus Run now) | — | segoy + roke + every project | `segoy-sync` | One sync PR per repo whose kit is behind (M4-D3) |
| brain-weekly-review | Weekly schedule | — | roke (reads project repos through GitHub tools) | `weekly-review` | One review PR in Roke, which also files notes, stubs and log entries (ADR-018) |
| brain-lint | Weekly schedule | — | roke | `lint` | Lint report issue or PR |

Notes:
- **Comments start nothing** (S3), so answers and commands need the answer label or wait for the periodic sweep (ADR-016).
- **One promotion task per project repo**, because a task's repos are fixed when it is created. `segoy init project` prints its settings.
- **Every run gets a fresh session with a random `claude/*` branch per repo.** Skills find PRs by label and idea ID, not branch name (ADR-020).
- **The trigger context** is the stored prompt plus a `<github-trigger-context>` block with the event, repository and issue or PR number only. Skills fetch labels, comments and bodies themselves.
- **Issue triggers fire on every issue event**, including the owner opening the `segoy:paused` issue. `triage` must check labels first and exit quietly when there is nothing to do.
- **Creating tasks is manual**: web UI, desktop app, or `/schedule` in the CLI (S5). An agent can only edit tasks it created itself. Remove the default connectors from every Segoy task (§5 rule 5).
- **One GitHub event trigger per task** (M2 staging). A task needing two GitHub events is split into two tasks with the same prompt (`brain-respond` and `brain-respond-pr`; `project-implement` will need the same in M3). Schedules can be added alongside the one GitHub trigger.
- **`Pull request → labeled` fires** (M2 T2.5), though one earlier owner `answered` may have been missed (unclear). The `brain-respond` sweep also covers spec PR feedback, as a safety net.
- **Never trust timestamps written inside `segoy` blocks** for ordering. Skills compare GitHub's `created_at` times (M2 T2.5: a wrong `finished` time made a run skip the owner's reply).
- **Label filters test the item's current labels** ("has `answered`"), not just the label that was added. A skill that is started by a label must remove that label before it changes any other label (M2 staging).
- **Hourly and per-account caps** apply. Events over a cap are dropped, and the weekly review catches what is stuck.
- **This whole layer is replaceable** (ADR-021).

## 5. Data flow and the privacy boundary

```
            PRIVATE                                   PROJECT (public or private)
┌────────────────────────────┐                 ┌──────────────────────────────────┐
│ Roke                        │                 │ <project>                         │
│  issues ── triage ── spec   │   promotion     │  docs/specs/<id>/spec.md, plan.md │
│  self/ ways/ knowledge/     │ ───────────────▶│  (Gate 1 PR)                      │
│  decisions, journal         │  reviewed PR,   │  implement → PR (Gate 2) → retro  │
│                             │  shareable only │                                   │
│  weekly-review ◀────────────┼─────────────────┤  retros, merged PRs (read-only)   │
└────────────────────────────┘  reads public    └──────────────────────────────────┘
                                 artefacts back
```

Rules:

1. **Visibility frontmatter.** Every Roke file has `visibility: private | shareable`. Default is `private`. `ways/public/` is shareable by convention; everything in `self/` is always private and cannot be marked otherwise.
2. **Promotion is the only writer from Roke context into a project repo.** The `promote` skill builds the project-side spec and plan from shareable content, rewrites or drops anything else, runs the leak check, and opens the PR. It lists in the PR body what it left out ("2 private assumptions omitted") without revealing them.
3. **Implementation sessions mount only the project repo.** They get ways of working from the project's own `CLAUDE.md`, which `segoy init project` / `segoy sync` fills from Roke's `ways/public/` at scaffold or sync time (a deliberate, diffable copy).
4. **Leak guard**, three layers (ADR-017):
   - **Skill step in `promote`:** run `leak-guard.sh` with the Roke denylist (`.segoy/denylist.txt`: names, places, private project names) plus the generic patterns over every file it is about to commit, and stop on any hit. This is the only place both lists are present. It has to be a skill step: promotion mounts two repos, and hooks do not run in multi-repo sessions (S2).
   - **CI in every project repo:** `segoy-ci.yml` runs the generic check (secrets, e-mail addresses, tokens) on every PR as a required check, with no model involved.
   - **Gate 1:** the owner reads the promotion PR before merging.
   - In single-repo **project** runs, the same script also runs as a `PreToolUse` hook on git commit and push, as an extra net (wired by `kit/project`, M3). Never in the brain, which legitimately holds personal data.
   - The script lives at `.claude/scripts/leak-guard.sh`; `strip-private.sh` beside it removes private blocks deterministically before the check.
5. **Connectors.** Tasks that touch public repos carry no connectors. Roke tasks carry only those explicitly needed (none in v1).
6. **Identity.** Issues, comments and PRs made by agents appear as the owner. Git commits are authored `Claude <noreply@anthropic.com>` (ADR-019). Agents are told to push only to `claude/*`, but the platform does not enforce it (S11). Rulesets on `main` (PR required, no force-push) are the real control; they are set up in T4.3.
7. **Segoy's own ideas** start in Roke like any other, and are promoted to the public Segoy repo through the same gate.

Residual risk to accept knowingly: Roke content is processed in Anthropic's cloud sessions (same trust as using Claude at all). The promotion session has both repos mounted and no hooks. It relies on the skill's leak-check step, the generic CI check and the owner's Gate 1 review. Personal terms that are not generic patterns are caught only by the skill step and Gate 1.

## 5a. Agent–app protocol and pause

Otak must not parse prose, and there is no backend to translate. So the contract between agents and the app is carried in GitHub itself:

- **State** = labels (`state:*` on Roke issues, `segoy:*` on PRs). Already required by the pipeline.
- **Content** = a fenced code block with info string `segoy` containing one versioned JSON object (ADR-022), appended to the comment or PR body a skill already writes. Kinds: `question`, `answer`, `plan`, `impl`, `run`, `review`. Defined in `docs/protocol.md`, with field tables and examples. Validator: `kit/common/.claude/scripts/protocol.sh`, vendored into every repo as `.claude/scripts/protocol.sh` (wrapped by `segoy doctor --protocol` from T1.2).
- **Answers** from the app are comments containing an `answer` block plus the same text in plain words, **together with the answer label** (`answered`), because comments alone start no task (ADR-016). Free-text replies typed in GitHub mobile stay valid: with the label they are handled at once, without it by the periodic sweep. Skills must handle both forms.
- **Run records**: every skill ends by posting or updating one `run` comment (on the Roke issue for brain flows, on the PR for project flows). This is what the app's activity feed and failure inbox read.
- **Pause**: an open issue labelled `segoy:paused` in a repo pauses automation there; in Roke it pauses the brain flows and promotion. Every skill checks this first and exits quietly. The app opens and closes that issue. No commit, no backend. Opening it fires `brain-triage` like any issue; triage recognises the label and exits.
- **Compatibility rule**: the block is additive. Unknown kinds and fields are ignored by the app; skills never depend on the app being present.

## 6. Use of Claude Code features

| Feature | Use in Segoy |
|---|---|
| `CLAUDE.md` | Per repo: purpose, commands, conventions, pointer to `docs/specs`. In Roke it is the brain schema. Kept short; detail goes in skills and `.claude/rules/`. |
| Skills | One per pipeline step. Each has: when to use, inputs, numbered procedure, output contract, stop conditions, budget. |
| Subagents | `implementer` (does a task group), `verifier` (fresh context; checks acceptance criteria against the diff and test output before the PR is opened). In Roke: `researcher` for ingest. |
| Hooks | Run only in single-repo sessions (S2). Leak guard as an extra net; in project repos a `Stop` hook reminding to run the plan's checks. Deterministic only. Nothing a two-repo run needs may depend on a hook. |
| Scheduled tasks | Triggers, as in §4. Created by hand; default connectors removed. |
| Auto-fix | Enabled by the `implement` skill on the PR it opens. |
| Projects (beta) | Optional. Useful for a manual sprint across repos. Not required, because project threads do not load repo skills or hooks. |
| Plugins | Later: `kit/` also published as a plugin for local use (FR-35). |
| MCP / connectors | None in v1. Calendar/email read-only in M6 for Roke tasks only. |
| Models | Smaller/faster model for triage, lint, retro; strongest model for spec, plan, implement, verify. Set per task. |

## 7. Conventions

- **IDs**: ideas get `I-<yyyymmdd>-<n>` (e.g. `I-20261114-1`) assigned at triage; the Roke issue number is stored in frontmatter. Project-side spec folders use the same ID.
- **Branches**: `claude/<kind>-<id>-<slug>` where kind ∈ spec, plan, impl, retro, review.
- **PR labels**: `segoy:spec`, `segoy:plan`, `segoy:impl`, `segoy:retro`, `segoy:review`.
- **Issue labels in Roke**: `state:*` (one of the lifecycle states), `kind:idea|note|task|self`, `target:<repo>`.
- **Commands in issue/PR comments**: `/spec`, `/plan`, `/park`, `/reject <reason>`, `/answer` (free text is also accepted as answers).
- **Frontmatter** (all pipeline files): `id, title, state, created, updated, visibility, source, links`.
- **Language**: file and folder names in English. Captures are kept verbatim in the language typed (config: `capture_language`); notes agents write are in `notes_language`, and when the two differ the original capture is kept alongside the translation (`keep_original`).

## 8. Decision log (initial ADRs)

| # | Decision | Why | Revisit when |
|---|---|---|---|
| ADR-001 | Vendor kit files into repos instead of plugin install | Repo-committed files are what cloud sessions reliably load; plugin install in cloud has open bug reports | Plugin install in cloud is confirmed reliable |
| ADR-002 | Scheduled tasks with GitHub triggers as primary event bus; GitHub Action as fallback | No API key, runs on subscription, works from phone; preview status mitigated by thin triggers | Limits or behaviour change |
| ADR-003 | Shell + `gh` + `jq` for scripts | Zero install in cloud and locally | Sync logic becomes hard to test |
| ADR-004 | Own minimal SDD templates, not Spec Kit | Small, Claude-native, stable under our control | We want multi-agent portability |
| ADR-005 | Markdown + frontmatter, no database or embeddings | Diffable, portable, enough at personal scale | Roke index files exceed context or query quality drops |
| ADR-006 | Ideas tracked as Roke issues *and* files | Issue = conversation and trigger; file = durable, linkable content | Double bookkeeping causes drift |
| ADR-007 | Gate 1 is a PR in the project repo containing spec+plan | One artefact is approval, privacy review, and implementation trigger | — |
| ADR-008 | Implementation sessions never mount Roke | Hard privacy boundary | — |
| ADR-009 | Twin = stated facts + decision records used for decision support only | Research shows inferred behaviour models are unreliable | — |
| ADR-010 | Otak is native Kotlin (Compose), Android only | Owner's choice; best access to share sheet, widget, tile, speech, biometrics | A second platform is wanted |
| ADR-011 | Otak is backend-free: GitHub API only, background polling instead of push | Keeps zero hosted infrastructure and no third party holding a token | Notification delay becomes a real problem |
| ADR-012 | Agent–app contract is labels + `segoy` blocks in comments/PR bodies (content is JSON, ADR-022) | Works without a server; stays readable in plain GitHub; versionable | Blocks become too large or brittle |
| ADR-014 | Otak's UI is the Segoy design system: tokens generated from `tokens.json`, components re-implemented in Compose with the same names and rules | One visual language across web and app; single source of truth for tokens | The design system gains a second consumer with different needs |
| ADR-013 | Pause via an open `segoy:paused` issue | Needs no commit to a protected branch and no backend | — |
| ADR-015 | Only owner actions start tasks; agent hand-offs happen inside one run | Agent-made events do not fire triggers (S3) | Platform changes, or ADR-021 |
| ADR-016 | Answers are signalled by a label, with a periodic sweep | Comments do not fire triggers (S3) | Comment triggers exist, or the friction is felt |
| ADR-017 | Promotion's leak check is a skill step + CI + Gate 1, not a hook | No hooks in multi-repo sessions (S2) | Hooks run there |
| ADR-018 | Triage writes no files; the issue is the record until a merged PR | Pushing to `main` depends on the model (S11) | Reliable default-branch pushes |
| ADR-019 | Agent commits keep the `Claude` identity | Observed default; separates agent and owner commits | Owner wants attribution |
| ADR-020 | Find artefacts by label and idea ID, not by branch | Runs get random branch names (S11) | Branch names can be set |
| ADR-021 | The trigger layer is replaceable (cloud tasks → dispatcher → own server) | The spikes' limits are all in this layer | See the ADR's switch criteria |
| ADR-022 | `segoy` blocks contain JSON, not YAML | Validated with `jq`; no YAML parser in shell-only scripts | Scripts gain a YAML parser |

## 9. Spikes (verify before building on them)

All run in M0. Results: `adr/spikes-2026-11.md`. Design changes from them: ADR-015 to ADR-021. Original questions kept below for reference.

- **S1** In a single-repo cloud session and in a single-repo scheduled task, do skills in `.claude/skills/`, agents in `.claude/agents/`, and hooks in `.claude/settings.json` load and run? (Docs say yes outside projects.)
- **S2** In a two-repo scheduled task, which repo's `CLAUDE.md`, skills, and hooks load? Decide whether `brain-plan-promote` should be Roke-first with the project repo cloned by the skill through the GitHub proxy instead.
- **S3** Which issue events fire a GitHub trigger: opened, labeled, and (important) new comments? Are there filters for issue triggers?
- **S4** Can a cloud session create labels, comment on issues, and open PRs in another repo of the same owner with the built-in GitHub tools? Can it create a new repository (expected: no)?
- **S5** How much of scheduled-task creation can be scripted (`/schedule` from CLI with a prompt file) versus done by hand in the web UI?
- **S6** Does a `PreToolUse` hook that exits non-zero block a commit in a cloud session in auto mode?
- **S7** Rough usage cost of one triage run and one small implement run on the current plan.

- **S8** Does an Android (Gradle) build run in a cloud session: SDK install via setup script, and are Google's Maven/download hosts reachable on the default allowlist or do they need adding?
- **S9** Can a cloud session discover its own session URL (to include in run records)?
- **S10** Can a scheduled task's API trigger be called from a phone app with the task token, and is that acceptable for "run now" and asynchronous Ask Roke? Otherwise use a labelled issue.

- **S11** Which branches can a cloud session and a scheduled task push to (the session's own branch only, `claude/*`, `main`)? Who is the commit author and pusher (owner or Claude GitHub App)? Decides whether triage can commit to the brain's `main` (decision 5) and which actor a ruleset bypass list must name.

Already observed (2026-11-14, in a cloud session): an interactive cloud session is assigned one working branch with a session-derived name (not `claude/<kind>-<slug>`) and is told to push only there, so one session yields one PR. Scheduled tasks get the same, one random `claude/*` branch per repo (S11, ADR-020).

Also observed (2026-11-14, in a cloud session): GitHub's GraphQL API is not available from Claude Code cloud sessions; the REST API is (`gh api repos/<owner>/<repo>/...`). `gh` subcommands that use GraphQL (`gh issue list`, `gh label list`, `gh pr create`) fail. Skills must use REST calls or the session's built-in GitHub tools. This does not affect Otak, which calls GitHub from the phone.

Results are recorded in `docs/adr/spikes-2026-11.md`. §4, §5 and §6 above already reflect them.
