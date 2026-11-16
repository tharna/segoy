# Segoy research brief

> **Roke** is the author's own brain repo (private). These docs use it as the worked example; read it as "your brain", the private repo you create from `kit/brain`.

Date: 2026-11-14. Purpose: ground the Segoy/Roke design in what exists today. Each section ends with what it means for the design. Platform facts were read from the Claude Code docs on this date; several features are in preview, so re-verify before relying on them (see "Spikes" in `docs/architecture.md`).

## 1. Agentic development environments

### 1.1 What the Claude Code platform gives us without hosting anything

| Capability | What it does | Relevance |
|---|---|---|
| Cloud sessions (Claude Code on the web) | A Claude Code session on Anthropic-managed VMs working on a GitHub repo. Can be started from browser, the mobile app's Code tab, desktop, or `claude --cloud`. Sessions persist and can be steered from the phone. Included in Pro/Max/Team usage limits. | The runtime for all Segoy agents. |
| Cloud scheduled tasks (formerly routines; research preview) | A saved prompt + one or more repos + connectors, started by a schedule, an API call, or a GitHub event (pull request, release, issue events). Runs in auto mode. Pushes to `claude/`-prefixed branches by default. Minimum schedule interval is one hour; hourly caps on runs and webhook events. | The automation backbone: "issue opened in Roke" → triage; "plan PR merged" → implement. |
| Claude Code GitHub Action (`anthropics/claude-code-action@v1`) | Runs Claude Code inside GitHub Actions; responds to `@claude` in issues/PRs or runs a prompt on any workflow event. Needs an API key or OAuth token as a repo secret. | Fallback automation path if scheduled tasks change or hit caps. |
| Auto-fix for pull requests | A cloud session watches a PR and reacts to CI failures and review comments. Requires the Claude GitHub App on the repo. | Review loop: comment on a PR from the phone, agent fixes. |
| Projects (public beta, Pro/Max) | One coordinating conversation that starts parallel cloud "threads" across repos, with project instructions and project memory. Threads load each repo's `CLAUDE.md` and `.claude/rules/`, but **not** repo skills, hooks, `.mcp.json`, or `.claude/settings.json`. | Optional cockpit for a human-driven burst of work. Not the backbone, because repo-committed skills and hooks do not load there. |
| Extension layers | `CLAUDE.md` (always-on context), skills (on-demand procedures), subagents (isolated context), hooks (deterministic scripts on lifecycle events), MCP (external tools), plugins (packaging of all of these). | Segoy is, physically, a set of these files plus templates. |

Important detail on what loads where:

- A cloud session or scheduled task **outside a project**, on a single repository, loads that repo's `CLAUDE.md`, `.claude/skills/`, `.claude/agents/`, and `.claude/settings.json` (hooks, permission rules).
- Sessions with several repositories and project threads behave differently; the docs point to a separate settings table. Treat multi-repo skill loading as unverified.
- Plugins declared in a repo's `.claude/settings.json` are documented to install in cloud sessions, but there are open public bug reports (Aug 2026) saying they do not. `/plugin` is not available in cloud sessions.
- Cloud sessions start from a fresh clone. Nothing from a local `~/.claude` carries over.
- Network access defaults to a "Trusted" allowlist (package registries etc.). GitHub credentials stay outside the VM behind a proxy.
- New repositories: cloud sessions work with existing GitHub repos; an empty repo must exist first.

**Design consequences**

1. Distribute Segoy by **vendoring files into each repo** (`.claude/skills`, `.claude/agents`, `.claude/settings.json`, `CLAUDE.md`), not by relying on plugin install. A plugin/marketplace manifest can be added later as a second channel.
2. Prefer **single-repo sessions**; they have the best-documented loading behaviour.
3. Use **scheduled tasks with GitHub triggers** as the event bus, and keep task prompts as versioned text in the Segoy repo so they can be recreated or moved to the GitHub Action.
4. GitHub issues, labels, and PRs are the UI. All of them work from the GitHub and Claude mobile apps, which satisfies "capture by phone, text".

### 1.2 Spec-driven development (SDD)

The dominant 2025–2026 pattern for reliable agentic coding is to make a written specification the source of truth and move through explicit phases with human checkpoints. GitHub's open-source Spec Kit is the reference implementation: a `specify` CLI plus slash commands for constitution → specify → plan → tasks → implement, working with 30+ agents including Claude Code. Similar ideas appear in AWS Kiro and community kits. The shared insight: the bottleneck is no longer code generation, it is preserving intent across planning, implementation, review, and handoff, so the handoff artifacts (spec, plan, task list) must be durable files in the repo rather than chat history.

**Design consequences**

1. Segoy's pipeline is SDD-shaped: idea → spec → plan → tasks → implementation → review → retro. The user's choice "approve plans too" maps exactly onto SDD's checkpoints.
2. Do **not** hard-depend on Spec Kit. It is large, moves fast, and is agent-agnostic where Segoy is deliberately Claude-Code-native. Borrow the phase structure and the idea of a "constitution" (Segoy calls it *ways of working*). Keep templates small and owned. Record this as a revisitable decision.
3. Every phase output is a markdown file with frontmatter, committed in a PR.

### 1.3 Other agent frameworks (for context)

Self-hosted personal-assistant frameworks (OpenClaw, Hermes Agent and similar) give always-on agents with chat-app front ends. They need a server and their own security hardening. Given "cloud, GitHub-centred" and "phone, text", they are out of scope for v1; a chat bridge could later call a scheduled task's API trigger.

## 2. Second brain

### 2.1 Classic methods

- **PARA** (Tiago Forte): Projects, Areas, Resources, Archive. Organises by actionability. Simple, good default folder scheme; weak on linking ideas.
- **Zettelkasten** (Luhmann): atomic notes, one idea each, densely linked. Strong for insight; historically fails because maintenance is tedious.
- **CODE** loop (Capture, Organise, Distil, Express): the lifecycle, independent of folder scheme.

### 2.2 What changed with agents

- **Plain markdown in git** has become the standard substrate for agent-readable brains. Reasons practitioners give: agents work on files with the same tools as code; every agent edit is a reviewable diff; no vendor lock-in; Obsidian or any editor can sit on top as an optional reader.
- **The LLM wiki pattern** (Karpathy, April 2026): three layers — immutable `raw/` sources, an LLM-maintained `wiki/` of interlinked pages with an `index.md` and append-only `log.md`, and a schema file (`CLAUDE.md`) that defines structure and procedures. Three operations: **ingest** (a new source updates many pages), **query** (answer from the wiki with citations; file good answers back), **lint** (periodic health check for contradictions, orphans, gaps). The claim is that compiled, human-readable knowledge beats re-deriving answers from raw chunks (RAG) at personal scale, roughly up to a few hundred sources, with no vector database needed.
- **The maintenance burden moves to the agent.** Filing, linking, and reviewing were the reasons second brains were abandoned; scheduled agent runs do them instead.
- Reported failure modes at scale: index files outgrowing context, drift between durable knowledge and working notes, and silent quality decay without lint and human review.

**Design consequences**

1. Roke is a private git repo of markdown with YAML frontmatter. No database, no embeddings in v1.
2. Roke combines a light PARA-style top level (actionable things separated from reference) with the LLM-wiki layering for knowledge (`raw/` immutable, `wiki/` agent-owned, schema in `CLAUDE.md`).
3. Separate **durable** knowledge (wiki, ways of working) from **working** material (inbox, idea drafts, journals) so they can have different lifecycles.
4. All agent changes to Roke arrive as PRs or small commits with a log entry, so the diff is the audit trail.
5. Keep index files hierarchical (per-folder `index.md`) to stay within context as Roke grows.

## 3. Digital twins (personal)

"Digital twin" originally meant a live model of a physical asset. In agent research it now also means a model of a specific person: their knowledge, preferences, style, and decision tendencies, used to act or answer on their behalf.

Findings from recent work:

- **Memory taxonomy.** Architectures converge on three kinds of memory: *semantic* (facts, preferences, goals), *episodic* (events, interactions, decisions with their context), and *procedural* (routines, how the person does things). Working memory is the current session.
- **Layered memory.** The "Second Me" line of work describes raw data → natural-language memory → model-internal memory (fine-tuning). The first two layers are achievable with files; the third is not needed for our purpose and reduces portability.
- **Data as the persistent asset, model as the replaceable tool.** Several papers argue the user should own a portable memory store that any model can be pointed at. A git repo of markdown is a direct implementation.
- **Limits.** Evaluations show LLM twins are still weak at behavioural consistency and at predicting what the person would decide in new situations. Inferred traits drift and can be wrong.
- **Risks.** Concentrating personal data; an agent acting with the person's identity (commits, comments, messages appear as the user); stale or inferred beliefs treated as fact.

**Design consequences**

1. Scope the twin as a **decision-support model**, not an impersonator: "what would the user most likely want here, and how sure are we?" It informs triage, spec and plan drafting, and prioritisation. It never approves anything on the user's behalf.
2. Implement it as files in Roke mapped to the taxonomy: `self/` (semantic), `journal/` and decision records (episodic), `ways/` and skills (procedural).
3. Only **stated or confirmed** facts enter `self/` and `ways/`. Agent inferences go into proposals (PRs) the user accepts or rejects. Each entry carries a source and date.
4. "Consult the twin before asking": agents check Roke for a precedent first; when they proceed on one, they record the assumption in the plan so the approval gate catches errors. This is how the twin reduces questions without removing control.
5. External personal data (calendar, email) is a later phase via connectors, read-only at first, pulled on demand rather than copied into Roke.

## 4. Privacy boundary between a public tool and a private brain

Not a research field so much as a design constraint that fell out of the above:

- Cloud sessions can reach any repo the connected GitHub identity can reach. The boundary must be enforced by workflow design and checks, not assumed.
- Scheduled tasks include **all** account connectors by default; each task must be trimmed.
- Agent actions on GitHub appear under the user's own account.
- Anything in a public repo's history is permanent.

**Design consequences**: see the privacy model in `docs/architecture.md` (one-way, reviewed promotion from Roke to project repos; `visibility` frontmatter; leak-guard hook and CI check; Roke never mounted in implementation sessions).

## 5. Sources

Platform
- Claude Code in the cloud: https://code.claude.com/docs/en/claude-code-on-the-web
- Scheduled tasks (routines): https://code.claude.com/docs/en/routines.md
- Projects: https://code.claude.com/docs/en/claude-projects.md
- GitHub Actions: https://code.claude.com/docs/en/github-actions
- Features overview (CLAUDE.md, skills, subagents, hooks, MCP, plugins): https://code.claude.com/docs/en/features-overview.md
- Plugins for organisations / marketplaces: https://code.claude.com/docs/en/plugins/org
- Reported plugin-install issues in cloud sessions: https://claudeissues.com/issue/88214-cloud-sessions-never-install-plugins-declared-in-claude-settings-json-and-plugin

Spec-driven development
- GitHub blog, Spec Kit announcement: https://github.blog/ai-and-ml/generative-ai/spec-driven-development-with-ai-get-started-with-a-new-open-source-toolkit/
- Spec Kit docs: https://github.github.com/spec-kit/
- Overview of SDD tooling: https://www.developersdigest.tech/blog/spec-driven-agent-workflows-github-spec-kit-gstack

Second brain
- Karpathy, LLM Wiki gist: https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f
- Summary of the pattern: https://www.noze.it/en/insights/llm-wiki/
- Markdown-in-git second brain, practitioner account: https://prommer.net/en/productivity/articles/notion-to-markdown-second-brain/
- PARA + agent setup walkthrough: https://codemeetai.substack.com/p/how-to-build-a-second-brain-with
- Lessons at scale: https://mpt.solutions/karpathys-llm-wiki-works-heres-what-broke-when-i-ran-it-at-real-scale/

Digital twins
- "Towards the Digital Me" (human digital twin architecture): https://arxiv.org/html/2506.23826v1
- Second Me overview (layered memory): https://api.emergentmind.com/topics/second-me
- Sovereign digital avatar / user-owned memory: https://arxiv.org/pdf/2512.22135v1
- Survey section on personalisation and digital twins: https://llm-agents-survey.github.io/personalization.html
