# Segoy design docs

Start here. These documents describe Segoy (this repo), the brain template (the owner's instance is the private Roke repo), and Otak, the Android companion app.

| File | What it is |
|---|---|
| `../CLAUDE.md` | Standing instructions for agents working in this repo |
| `prd.md` | What Segoy is, requirements, milestones, risks |
| `architecture.md` | Repos, trigger map, privacy boundary, agent–app protocol, ADRs, spikes |
| `brain-design.md` | Brain template: layout, file contracts, skills, twin |
| `workflows.md` | Step-by-step flows and state machine |
| `otak-app-spec.md` | Otak, the Android app: screens, protocol, design system on Android, milestones |
| `bootstrap-plan.md` | Milestones M0–M6 and O0–O6, manual steps, first session prompt |
| `research-brief.md` | Research findings and sources behind the design |
| `../design-system/` | The Segoy design system used by every Segoy UI |

## The design in short

1. Capture = a GitHub issue in the private Roke repo, created from Otak, the Android app (GitHub mobile works as a fallback and until the app exists).
2. A scheduled task with a GitHub trigger starts a Claude Code cloud session that triages it.
3. Agents consult Roke (ways of working, past decisions, personal context) before asking you anything.
4. Spec is a PR in Roke. Plan + shareable spec are **promoted** as a PR into the target project repo.
5. Merging that PR is Gate 1 (plan approval) and doubles as a privacy review.
6. The merge triggers implementation in the project repo, which never sees Roke.
7. The implementation PR is Gate 2. Nothing auto-merges.
8. Retros and your gate decisions flow back to Roke in a weekly review PR that proposes changes to your ways of working.
9. Segoy itself is files: skills, agents, hooks, templates, task prompts, a shell script. They are vendored into each repo.
10. Segoy is project number one and is developed through its own pipeline from milestone M4.
11. Otak (native Kotlin, no backend) is the phone front end for capture, questions, gate decisions, and status. It reads labels and small YAML blocks that skills add to their comments and PRs, and it polls GitHub instead of receiving push. It uses the Segoy design system already in the repo (terminal-style, touch-sized), with tokens generated for Android. It is the first project built through the pipeline.

## Decisions

Resolved 2026-11-14. Values that differ per user live in the brain's `.segoy/config.yml`; this table records what Segoy is designed and tested for.

| # | Question | Decision |
|---|---|---|
| 1 | Which Claude plan? (affects usage headroom and whether Projects beta is available) | Must work on Pro; Max optional. Projects not required. Spike S7 measures headroom on Pro |
| 2 | Licence for Segoy | MIT (already in the repo) |
| 3 | Segoy public from day one, or private until M4? | Private until the M4 public-readiness pass |
| 4 | Language for notes agents write in Roke | Configurable: captures kept verbatim in `capture_language`, agent notes written in `notes_language` with the original kept alongside (`keep_original`). See `brain-design.md` §7 |
| 5 | May triage commit new idea files straight to Roke `main`, or must everything be a PR? | Everything is a PR; triage writes no files (ADR-018, after spike S11) |
| 6 | Script language | POSIX shell + `gh` + `jq`; revisit if it gets complicated |
| 7 | Do you want Obsidian (or similar) as a reader for Roke on phone/desktop? | Optional; design does not depend on it |
| 8 | Personal context connectors (calendar, email) | Deferred to M6, read-only, after a privacy review |
| 9 | Should Roke be created from a GitHub template repo, or by running `segoy init brain` in an empty repo? | `segoy init brain` |
| 10 | Is using your own GitHub identity for agent commits acceptable, or do you want a separate bot account later? | Issues, comments and PRs appear as the owner; commits keep the `Claude` author (ADR-019). Rulesets deferred to T4.3 |

Otak-specific: decided — merging from the phone is allowed on all repos behind biometric confirmation; photo capture is deferred; the app follows the Segoy design system. Also decided: minimum Android 10, English UI, distribution as an APK from GitHub Releases.

## Things that could be researched further

- Android specifics for Otak: screenshot-testing library choice, on-device speech and text-extraction quality for Finnish, updater options for sideloaded APKs.
- Whether GitHub's own notification feed can stand in for polling several endpoints.
- Spec Kit compatibility layer, if you want to use other agents alongside Claude Code.
- Local/desktop runs for sensitive work (Remote Control, desktop scheduled tasks).
- Search layer for Roke once index files stop scaling.
- Evaluation harness: replay past ideas through changed skills and compare outputs.
- Cost model: usage per pipeline run on your plan, and which steps can use a smaller model.

## Caveats

- Scheduled tasks are a research preview and Projects are a beta; the architecture keeps triggers thin so they can be swapped (ADR-021).
- The M0 spikes verified the platform assumptions (`adr/spikes-2026-11.md`). The design changes they caused are ADR-015 to ADR-021: owner actions drive every step, answers need a label, promotion's leak check is not a hook, triage writes no files, and artefacts are found by label and ID.
