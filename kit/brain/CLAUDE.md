# Brain

This repository is a personal brain managed with Segoy (https://github.com/<owner>/segoy). It holds the owner's ideas, ways of working, decisions, knowledge and personal context. It is **private**. Read this file completely before doing anything here.

## What lives where

| Path | Contents | Visibility |
|---|---|---|
| `index.md` | Top-level map with links to every folder's index | private |
| `log.md` | Append-only record: date, actor, operation, files touched | private |
| `.segoy/config.yml` | Owner handle, repos, languages, labels, models | private |
| `.segoy/denylist.txt` | Private terms that must never leave this repo (used by `promote`) | private |
| `ideas/` | `index.md` table and one folder per idea: `idea.md`, `spec.md`, `plan.md` | per file |
| `projects/` | `index.md` portfolio and one page per project repo | per file |
| `ways/public/` | Ways of working that are safe to publish; copied into project repos | shareable |
| `ways/private/` | Preferences that reveal personal context | private |
| `decisions/` | Decision records `D-<yyyymmdd>-<n>.md` | private |
| `knowledge/raw/` | Immutable sources. Never edit a raw file | private |
| `knowledge/wiki/` | Agent-maintained pages citing raw sources | per file |
| `self/` | Profile, goals, values, preferences, constraints | **always private** |
| `journal/` | Weekly review digests | private |

## Rules for agents

1. **Pause first.** If there is an open issue labelled `segoy:paused`, stop. Post nothing, change nothing (protocol §5).
2. **No direct commits to `main`.** Every file change is a PR the owner merges (ADR-018). Triage writes no files.
3. **Frontmatter on every file** except `log.md` and indexes: `id`, `title`, `kind`, `visibility`, `created`, `updated`, `source`, `links`; ideas also have `state`. `visibility` defaults to `private`. Files in `self/` are always `private`.
4. **Stated over inferred.** `self/` and `ways/` hold only what the owner stated or approved. An inference is a proposal in a PR, never a fact.
5. **Consult before asking.** Before asking the owner anything, search `ways/`, `decisions/`, `self/` and related ideas. If the answer is there, record it as an assumption with a link and a confidence word (`firm`, `likely`, `guess`). Ask at most three questions per round, each answerable in one line from a phone, each with a default.
6. **Language.** File and folder names in English. Keep the owner's captures exactly as typed (`capture_language`). Write your own text in `notes_language` (`.segoy/config.yml`).
7. **Private blocks.** Content that must never leave this repo, inside an otherwise shareable file, is wrapped in `<!-- private -->` … `<!-- /private -->`.
8. **Nothing personal leaves.** Only the `promote` skill writes to other repos, and only after its leak check passes. Never copy `self/` content anywhere.
9. **Protocol.** Comments and PR bodies that an app may read end with a `segoy` block (Segoy `docs/protocol.md`). Every run that does work ends with one `run` block.
10. **Labels carry state.** An issue has exactly one `state:*` label. Labels set by agents start no task; only owner actions do.
11. **Never** approve, merge, close a PR, or speak in the owner's name. Never push to `main`. Never force-push.

## IDs and names

- Ideas `I-<yyyymmdd>-<n>`, numbered per day from 1, the date being the day the idea was triaged. Decisions `D-<yyyymmdd>-<n>`.
- Idea folders `ideas/I-<yyyymmdd>-<n>-<slug>/`, slug in lowercase kebab-case from the English title.
- PR titles end with the idea ID in parentheses: `Spec: <title> (I-20260101-1)`. PRs are found by label and ID, not branch name (ADR-020).

## File contracts

- **idea.md** sections: Captured text (verbatim) · Restatement · Why it matters · Related · Target · Questions and answers (dated) · Assumptions (each with its source link and confidence).
- **spec.md** sections: Problem · Users and context · Outcomes · In scope / Out of scope · Acceptance criteria (numbered, testable) · Constraints · Open questions · Assumptions.
- **Decision records** frontmatter adds `gate`, `subject`, `outcome`. Sections: What was decided · Reason in the owner's words · Generalisation (optional, marked `proposed`).
- **ways/** entries: one imperative, checkable rule per bullet, with `(source: D-… or owner-stated, <date>)`.
- **self/** entries: bullets with source and date. Goals have `horizon` (quarter, year, someday) and `priority`.

## Skills

The procedures live in `.claude/skills/`, vendored from Segoy. Files there are replaced on `segoy sync`; change them in Segoy, not here. Scheduled tasks only name a skill; see Segoy `tasks/`.
