# Roke — Brain design (Segoy brain template)

Version 0.1, 2026-11-14. This describes `kit/brain/` in Segoy. "Roke" is one instance of it. Nothing in the template is personal.

## 1. What the brain is for

Three jobs, in priority order:

1. **Backlog**: hold ideas from raw capture to promoted plan, and the portfolio of projects.
2. **Operating manual**: how the owner works and decides, so agents stop asking the same things.
3. **Memory**: knowledge the owner collects, and personal context that helps agents prioritise and draft.

## 2. Layout

```
roke/
├── CLAUDE.md                 # schema: this document, condensed, as rules for agents
├── README.md                 # for the human: how to use from phone and desktop
├── index.md                  # top-level map; links to each folder's index
├── log.md                    # append-only: date, actor, operation, files touched
├── .segoy/
│   ├── config.yml            # owner handle, repos, language, model choices
│   ├── labels.json           # label names, colours, descriptions (applied by segoy init brain)
│   ├── denylist.txt          # private terms that must never leave (used by promote)
│   └── version, manifest.json
├── inbox/                    # raw captures not yet triaged (mostly empty; issues are the inbox)
├── ideas/
│   ├── index.md              # table: id, title, state, target, updated
│   └── I-20261114-1-<slug>/
│       ├── idea.md           # restated idea, context, links, Q&A history
│       ├── spec.md           # when specced
│       └── plan.md           # private draft before promotion
├── projects/
│   ├── index.md              # portfolio: repo, purpose, status, visibility
│   └── <repo>.md             # one page per project: goals, links to ideas/specs, state
├── ways/                     # ways of working (the "constitution")
│   ├── index.md
│   ├── public/               # shareable: copied into project CLAUDE.md by segoy sync
│   │   ├── principles.md     # e.g. small PRs, tests with every change
│   │   ├── stack.md          # preferred languages, tools, versions
│   │   ├── conventions.md    # naming, commits, docs
│   │   └── review.md         # what the owner looks for in a PR
│   └── private/              # preferences that reveal personal context
├── decisions/                # decision records (episodic memory)
│   ├── index.md
│   └── D-20261114-1.md
├── knowledge/
│   ├── raw/                  # immutable sources: clipped articles, notes, transcripts
│   └── wiki/
│       ├── index.md          # catalogue, one line per page, grouped by topic
│       ├── topics/  entities/  syntheses/
├── self/                     # always private
│   ├── profile.md            # who, roles, skills, context
│   ├── goals.md              # current goals with horizon and priority
│   ├── values.md             # what matters; trade-off rules
│   ├── preferences.md        # communication, tools, working hours etc.
│   └── constraints.md        # time, budget, things never to do
├── journal/
│   └── 2026-W46.md           # weekly review digests
└── .claude/                  # vendored brain skills, agents, settings
```

Mapping to the research: `self/` + `ways/` = semantic memory; `decisions/` + `journal/` + `log.md` = episodic; skills + `ways/` = procedural; `knowledge/` = the LLM-wiki layers; `ideas/` + `projects/` = the actionable (PARA "Projects") side.

## 3. File contracts

All files have YAML frontmatter. Common fields:

```yaml
---
id: I-20261114-1            # or D-…, or omitted for wiki pages (path is identity)
title: Short title
state: triaged              # ideas only
kind: idea                  # idea | note | project | way | decision | self | wiki | source
visibility: private         # private | shareable (self/ is always private)
created: 2026-11-14
updated: 2026-11-14
source: issue#12            # where this came from: issue, PR, URL, "owner-stated"
links: [I-20261101-2, projects/segoy]
---
```

### idea.md
Sections: *Captured text* (verbatim), *Restatement*, *Why it matters* (linked to goals if any), *Related*, *Target* (new project / existing repo / not code), *Questions and answers* (dated), *Assumptions* (each with a link to the Roke file it rests on, or "none — needs confirmation").

### spec.md
Sections: *Problem*, *Users/Context*, *Outcomes*, *In scope / Out of scope*, *Acceptance criteria* (numbered, testable), *Constraints*, *Open questions*, *Assumptions*. Each section or bullet that must stay private is wrapped:

```markdown
<!-- private -->
…
<!-- /private -->
```

The `promote` skill drops these blocks.

### Decision record (D-…)
```yaml
gate: plan | pr | triage | other
subject: I-20261114-1
outcome: approved | rejected | changed | parked
```
Body: *What was decided*, *Reason in the owner's words* (quoted from the comment/review), *Generalisation* (optional proposed rule, marked `proposed` until merged into `ways/`).

### ways/ entries
One rule per bullet, each with `(source: D-… or owner-stated, date)`. Rules are imperative and checkable ("Every PR includes tests for changed behaviour"). `ways/public/*` must be safe to publish.

### self/ entries
Bullets with source and date. No agent inference is merged without the owner's approval. Goals have `horizon` (quarter/year/someday) and `priority`.

## 4. Operations (skills)

Each skill is `kit/brain/.claude/skills/<name>/SKILL.md`. Contracts below; full step lists are written during implementation.

| Skill | Trigger | Does | Writes |
|---|---|---|---|
| `capture` | "idea:"/"note:" in a session | Creates a Roke issue from text so everything flows through one path | Issue |
| `triage` | New issue; answer label or sweep (via `brain-respond`) | Classify; assign ID; link related (index files and open issues); consult brain before asking; label; comment; `self` proposals as PR | Labels and a comment only. No files* |
| `spec` | State `triaged` with enough input, or `/spec` | Write `idea.md`, `spec.md` and the index entry; open PR `segoy:spec` with `target:<repo>` | PR |
| `plan` | Spec merged, or `/plan` | Read target repo's `CLAUDE.md` and structure; write `plan.md` (private draft) | Commit on branch |
| `promote` | After `plan` | Build project-side `spec.md` + `plan.md` from shareable content; leak check with denylist; open Gate 1 PR in target repo; update idea state | PR in project repo; state update |
| `record-decision` | Gate outcome observed (PR merged/closed, `/reject`, review comments) | Write decision record; propose generalisation | PR or part of weekly review |
| `ingest` | New file in `knowledge/raw/` or note capture | Summarise source; update/create wiki pages; update index; log | PR `segoy:knowledge` |
| `query` | Owner asks in a Roke session | Answer from wiki + ways + ideas with file citations; offer to file the answer as a synthesis page | Optional PR |
| `lint` | Weekly | Find contradictions, orphans, stale pages, missing frontmatter, ideas stuck in a state, index drift | Report issue; fix-PR for mechanical problems |
| `weekly-review` | Weekly | Read merged PRs, retros, decision records, idea states; update `projects/` and `ideas/index.md`; propose `ways/` changes; write `journal/<week>.md` digest | One PR `segoy:review` |

\* No direct commits (ADR-018). Whether a scheduled run pushes to `main` depends on the model (spike S11), so every file change in the brain is a PR the owner merges. Capture is still never blocked: the issue is the idea's record until the spec PR creates `idea.md`. Notes, parked or rejected idea stubs and `log.md` entries are filed in one batch by the weekly review PR.

## 5. "Consult the brain before asking" (the twin in practice)

Procedure embedded in `triage`, `spec`, and `plan`:

1. Write down the question you would ask the owner.
2. Search `ways/`, `decisions/`, `self/`, and related ideas for an answer or close precedent.
3. If found: proceed, and record under *Assumptions* with a link and a confidence word (`firm` = explicit rule; `likely` = one precedent; `guess` = analogy).
4. If not found or only `guess` on something costly to reverse: ask, with at most three questions per round, each answerable in one line from a phone, with a suggested default.
5. Every answer the owner gives is saved in the idea's Q&A and considered by `record-decision` for generalisation.

At Gate 1 the plan lists its assumptions at the top, so a wrong one is cheap to catch. Over time the ratio of `firm`/`likely` assumptions to questions asked is the measure of the twin's usefulness (reported in the weekly digest).

Boundaries: the twin never approves, merges, rejects, or sends anything in the owner's name; `self/` content never appears outside Roke; inferred traits are proposals only.

## 6. Knowledge workflow (LLM-wiki pattern)

- `knowledge/raw/` is append-only. File names: `<yyyy-mm-dd>-<slug>.md` with frontmatter `url`, `author`, `captured`. Agents never edit raw files.
- `knowledge/wiki/` is agent-maintained, human-readable. Page types: *topic* (concept), *entity* (tool, person, organisation), *synthesis* (answer to a question, comparison). Pages cite raw files by relative link.
- Ingest updates every page the source bears on, then `wiki/index.md` and `log.md`.
- Index hierarchy: when a folder's index passes ~150 lines, split by sub-topic and link from the parent.
- Lint weekly. Contradictions are flagged for the owner, not resolved silently.
- Knowledge can inform specs: `spec` and `plan` may cite wiki pages; cited content that is `shareable` can be promoted.

## 7. Config (`.segoy/config.yml`)

The template is `kit/brain/.segoy/config.yml.tmpl`, which is authoritative. In outline:

```yaml
owner: <github-handle>
brain_repo: <owner>/roke
tool_repo: <owner>/segoy
capture_language: <lang>      # language you usually capture in; captures stay verbatim
notes_language: en            # language agents write notes in
keep_original: true           # keep the verbatim capture next to the translation
projects_default_visibility: private
models:
  triage: <mid-model>         # Sonnet to start (M1-D4); try a small model once triage is proven
  spec: <strong-model>
  plan: <strong-model>
  lint: <small-model>
question_limit_per_round: 3
duplicate_action: close       # close | label
answer_label: answered        # owner adds it with an answer or command (ADR-016)
sweep_interval: 4h            # brain-respond sweep for answers without the label (1h minimum)
```

## 8. Human use

- Phone: Otak for capture, answers, gate decisions, and status (see `docs/otak-app-spec.md`). GitHub mobile and Claude mobile remain usable on the same data.
- Desktop: any editor; Obsidian works as a reader because links are relative markdown links (no wiki-link syntax required).
- The `README.md` in the brain template is a one-page cheat sheet: how to capture, the comment commands, what each label means, what to do when stuck.

## 9. Migration and growth

- Brain template changes ship with a migration note agents can execute.
- If index-based navigation stops being enough (ADR-005 trigger), add a local search tool or embeddings as an optional layer; files stay the source of truth.
- Importing existing notes: drop them into `knowledge/raw/` and run `ingest` in batches.
