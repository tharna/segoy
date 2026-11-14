# Segoy — Architecture

Version 0.1, 2026-11-14. Read `docs/prd.md` first.

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
│   │       ├── skills/segoy-leak-check/
│   │       └── hooks/leak-guard.sh
│   ├── project/                 # vendored into project repos
│   │   ├── CLAUDE.md.tmpl
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
│       ├── .segoy/config.yml.tmpl
│       ├── .github/ISSUE_TEMPLATE/  labels.yml
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

- `segoy sync` copies `kit/common` plus `kit/project` or `kit/brain` into the target repo and writes `.segoy/version` and `.segoy/manifest.json` (path → content hash at sync time).
- On the next sync, a file whose current hash differs from the manifest is treated as locally modified: the script writes the new version beside it as `<file>.segoy-new` and reports, never overwrites.
- Files the user owns (`CLAUDE.md` after first creation, everything outside `.claude/skills/segoy-*`, notes, config) are never touched after init.
- Kit skills are namespaced by directory name prefix `segoy-` once vendored, so a repo's own skills cannot collide.
- Segoy uses semantic versions and a changelog. Brain template changes that need migration ship a `migrations/<version>.md` that an agent can follow.
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

Each row is one scheduled task (file in `tasks/`). "Repos" is what the task mounts.

| Task | Trigger | Repos | Skill | Output |
|---|---|---|---|---|
| brain-triage | Issue opened in Roke | roke | `triage` | Idea/note file, labels, triage comment |
| brain-respond | Issue comment / label change in Roke* | roke | `triage` → `spec` or `plan` depending on state and commands | Updated files, PR in Roke |
| brain-plan-promote | Roke PR merged with label `segoy:spec` | roke + target project repo | `plan` then `promote` | Promotion PR in project repo (Gate 1) |
| project-implement | Project PR merged with label `segoy:plan` | project | `implement` | Implementation PR (Gate 2) |
| project-retro | Project PR merged with label `segoy:impl` | project | `retro` | Retro file via small PR; comment on spec |
| brain-weekly-review | Weekly schedule | roke (reads project repos through GitHub tools) | `weekly-review` | One review PR in Roke |
| brain-lint | Weekly schedule | roke | `lint` | Lint report issue or PR |

\* The docs list Issue events (opened, edited, labeled, …) as supported triggers; whether issue *comments* fire a trigger is unverified (spike S3). Fallbacks, in order: (a) drive state changes by labels instead of comments; (b) a minimal GitHub Actions workflow in Roke that calls the task's API trigger on `issue_comment`; (c) `claude-code-action` responding to `@claude`.

PR triggers support filters (labels, base/head branch, is-merged), so label-gated tasks are cheap. Issue triggers may not have filters; the `triage` skill therefore starts by reading the issue's labels and exits early if there is nothing to do.

One task is needed per project repo for `project-implement` and `project-retro` (a GitHub trigger names a repository). `segoy init project` prints the exact task settings to create; creating them is a manual step in the web UI or via `/schedule` (spike S5 checks how much can be scripted).

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
4. **Leak guard**, two layers:
   - Hook (`PreToolUse` on git commit/push and file writes) in every repo's `.claude/settings.json`, running `leak-guard.sh`: blocks content matching patterns from a denylist. In project repos the denylist is generic (secrets, e-mail addresses, tokens). The Roke-specific denylist (names, places, private project names) lives in Roke at `.segoy/denylist.txt` and is used by the `promote` skill, which is the only place both are present.
   - CI workflow in public repos: the same generic check on every PR, with no model involved.
5. **Connectors.** Tasks that touch public repos carry no connectors. Roke tasks carry only those explicitly needed (none in v1).
6. **Identity.** Commits and comments appear as the user. Branch protection on `main` in all repos: PR required, no force-push. Agents push only to `claude/*`.
7. **Segoy's own ideas** start in Roke like any other, and are promoted to the public Segoy repo through the same gate.

Residual risk to accept knowingly: Roke content is processed in Anthropic's cloud sessions (same trust as using Claude at all); the promotion session has both repos mounted and relies on the skill, the denylist, and the human Gate 1 review.

## 5a. Agent–app protocol and pause

Otak must not parse prose, and there is no backend to translate. So the contract between agents and the app is carried in GitHub itself:

- **State** = labels (`state:*` on Roke issues, `segoy:*` on PRs). Already required by the pipeline.
- **Content** = a fenced code block with info string `segoy` containing versioned YAML, appended to the comment or PR body a skill already writes. Kinds: `question`, `answer`, `plan`, `impl`, `run`, `review`. Defined in `docs/protocol.md` (written in M1), with JSON-schema-style field lists and examples, and a validator in `scripts/segoy doctor --protocol`.
- **Answers** from the app are comments containing an `answer` block plus the same text in plain words; free-text replies typed in GitHub mobile stay valid, and skills must handle both.
- **Run records**: every skill ends by posting or updating one `run` comment (on the Roke issue for brain flows, on the PR for project flows). This is what the app's activity feed and failure inbox read.
- **Pause**: an open issue labelled `segoy:paused` in a repo pauses automation there; in Roke it pauses the brain flows and promotion. Every skill checks this first and exits quietly. The app opens and closes that issue. No commit, no backend.
- **Compatibility rule**: the block is additive. Unknown kinds and fields are ignored by the app; skills never depend on the app being present.

## 6. Use of Claude Code features

| Feature | Use in Segoy |
|---|---|
| `CLAUDE.md` | Per repo: purpose, commands, conventions, pointer to `docs/specs`. In Roke it is the brain schema. Kept short; detail goes in skills and `.claude/rules/`. |
| Skills | One per pipeline step. Each has: when to use, inputs, numbered procedure, output contract, stop conditions, budget. |
| Subagents | `implementer` (does a task group), `verifier` (fresh context; checks acceptance criteria against the diff and test output before the PR is opened). In Roke: `researcher` for ingest. |
| Hooks | Leak guard; in project repos a `Stop` hook reminding to run the plan's checks; in Roke a hook that appends to `log.md` on commit. Deterministic only. |
| Scheduled tasks | Triggers, as in §4. |
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
- **Language**: file and folder names in English; note content in whatever language it was captured in (config: `content_language`).

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
| ADR-012 | Agent–app contract is labels + `segoy` YAML blocks in comments/PR bodies | Works without a server; stays readable in plain GitHub; versionable | Blocks become too large or brittle |
| ADR-014 | Otak's UI is the Segoy design system: tokens generated from `tokens.json`, components re-implemented in Compose with the same names and rules | One visual language across web and app; single source of truth for tokens | The design system gains a second consumer with different needs |
| ADR-013 | Pause via an open `segoy:paused` issue | Needs no commit to a protected branch and no backend | — |

## 9. Spikes (verify before building on them)

Run these first; each takes minutes and is listed as a task in `docs/bootstrap-plan.md`.

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

Already observed (2026-11-14, in a cloud session): GitHub's GraphQL API is not available from Claude Code cloud sessions; the REST API is (`gh api repos/<owner>/<repo>/...`). `gh` subcommands that use GraphQL (`gh issue list`, `gh label list`, `gh pr create`) fail. Skills must use REST calls or the session's built-in GitHub tools. This does not affect Otak, which calls GitHub from the phone.

Record results in `docs/adr/spikes-2026-11.md` and adjust §4 if any assumption fails.
