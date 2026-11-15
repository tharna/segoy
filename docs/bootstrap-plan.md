# Segoy — Bootstrap plan

Version 0.1, 2026-11-14. How to get from nothing to a self-hosting Segoy. Written so Claude Code can execute it milestone by milestone. Until M3 the pipeline does not exist, so M0–M3 are built in ordinary Claude Code sessions with the owner approving a short plan before each milestone and merging PRs. From M4, Segoy changes go through Segoy.

## Manual steps for the owner (once)

1. `segoy` and `roke` already exist (both private for now; `segoy` flips to public at M4). (done)
2. Connect GitHub at claude.ai/code and install the Claude GitHub App on both repos. (done)
3. Branch protection on `main` in both: deferred to T4.3, before Segoy goes public. Until then "never push to `main`" rests on the skills and the cloud git proxy.
4. The design docs are in `docs/` and `CLAUDE.md` is at the repo root. (done)
5. Answer the open decisions in `docs/README.md`. (done, 2026-11-14)
6. For M0: create a private scratch repo (`<owner>/<scratch>`) with the Claude GitHub App installed; spikes run there so the brain stays clean. It is reused as the scratch project in T3.2. (done)

## M0 — Foundations and spikes

Goal: confirm platform assumptions before writing skills.

Tasks
- T0.1 Repo skeleton per architecture §2.1 (empty dirs with README stubs), LICENSE, `.gitignore`, CI workflow that runs shellcheck and a frontmatter linter on `kit/**/SKILL.md`.
- T0.2 Spikes S1–S11 (architecture §9; S8–S10 concern the Otak app; S11 is push rights and commit identity). For each: a throwaway skill/hook/task in a scratch branch or scratch repo, run it, record result in `docs/adr/spikes-2026-11.md`.
- T0.3 Update architecture §4 and ADRs with spike outcomes; open questions that spikes resolve are closed.

Done when: spike record merged; trigger map confirmed or revised.

Status (2026-11-15): done. Spike record `docs/adr/spikes-2026-11.md`; design changes in ADR-015 to ADR-021; trigger map revised in architecture §4.

## M1 — Brain: capture and triage

Goal: an issue created on the phone is filed and answered within minutes.

Tasks
- T1.1 `kit/brain/` skeleton: folders, `index.md` files, `CLAUDE.md` schema (condensed from brain design), `README.md` cheat sheet (including "answer = comment + `answered` label"), labels file (with `answered`), `.segoy/config.yml.tmpl`.
- T1.2 `scripts/segoy init brain` and `segoy doctor` (checks: gh auth, labels present, branch protection, App installed where detectable).
- T1.3 Skills `capture` and `triage` with the comment format from workflows §2. Triage writes no files (ADR-018) and exits quietly on issues that already have a state or are the pause issue.
- T1.3a `docs/protocol.md`: the `segoy` block kinds, fields, examples, versioning (JSON, ADR-022); the answer label rule (ADR-016); validator in `segoy doctor --protocol`; pause check snippet shared by all skills. Triage emits `question` and `run` blocks from day one.
- T1.4 `tasks/brain-triage.md` (prompt + exact task settings: trigger `issues.opened`, repo, model, **no connectors**). Owner creates the scheduled task by hand (agents can only edit tasks they created).
- T1.5 Instantiate Roke with `segoy init brain`; seed `self/` and `ways/public/` from a 15-minute interview session with the owner (agent asks, owner answers, result is a PR).
- T1.6 Test: five real captures from the phone, including a duplicate, a `note:`, and a vague one-liner.

Done when: all five are handled per workflows §2 and the owner has not had to open a computer.

Status (2026-11-15): **done.**
- Shipped: protocol v1 with the JSON blocks (ADR-022), the `kit/brain/` template, `segoy init brain` and `segoy doctor`, the skills `segoy-triage`, `segoy-respond`, `segoy-capture` and `segoy-onboard`, and the tasks `brain-triage` and `brain-respond`.
- Staged in a scratch brain first. That found that agent-added labels fire label triggers (ADR-015 amendment), and the `answered` filter fixed it.
- The brain is set up and the onboarding interview is merged.
- T1.6: five phone captures, all handled per workflows §2:
  - an English idea and a Finnish idea, both with assumptions drawn from the onboarding answers;
  - a duplicate written in the other language, recognised and closed;
  - a `note:`;
  - a vague one-liner, resolved after one answer.
- With the filter in place, no extra runs from triage's own labels.

Carried into M2:
- `segoy-respond` should set `target:<repo>` when an answer makes the target clear.
- Notes stay open until the weekly review (M5) files them. Decide in M2 whether to file them earlier.
- Sweep runs hourly in the owner's setup (24 runs a day). Revisit with real usage numbers.

## M2 — Spec, plan, promotion (Gate 1)

Tasks
- T2.1 Skills `spec`, `plan`, `promote` (`segoy-spec`, `segoy-plan`, `segoy-promote`). `record-decision` is a `decision` block in comments for now; the weekly review files decisions (M2-D2).
- T2.2 `kit/common` leak check: `leak-guard.sh` and `strip-private.sh`, generic patterns, the generic check in Segoy's own CI (hook wiring and the project CI template move to `kit/project`, M3); Roke denylist support as a mandatory step in `promote` (ADR-017).
- T2.3 Tasks `brain-respond` (answer label on issues and PRs, plus a periodic sweep; ADR-016) and `brain-plan-promote-<repo>` (one per project, filtered on `segoy:spec` + `target:<repo>`), and `brain-gate-sync-<repo>` (Gate 1 merged or closed → brain state; added in T2.5).
- T2.4 Fixture test: a fake brain and fake project under `tests/fixtures/` with a spec containing private blocks and denylisted terms; assert the promoted output contains none.
- T2.5 End-to-end on a real small idea targeting the Segoy repo itself. Also check whether a run that opened a PR can pick up review comments through auto-fix in a scheduled task (workflows §3).

Done when: a Gate 1 PR appears in `segoy` from an idea captured on the phone, with no private content, and merging/closing it updates Roke state.

## M3 — Implementation (Gate 2) and retro

Tasks
- T3.1 `kit/project/`: `CLAUDE.md.tmpl`, skills `implement`, `review-pr`, `retro`; agents `implementer`, `verifier`; settings with hooks.
- T3.2 `scripts/segoy init project`; apply to the Segoy repo (dogfood) and to one scratch project repo.
- T3.3 Tasks `project-implement` (merged `segoy:plan` or `segoy:impl`; `answered` on PRs) and `project-retro` for both repos.
- T3.4 Run the idea from T2.5 through to a merged implementation PR and a retro.

Done when: one idea has gone capture → done with exactly the two gates.

## M4 — Self-hosting

Tasks
- T4.1 `scripts/segoy sync` with manifest and local-modification handling; tests on fixtures.
- T4.2 Versioning: `CHANGELOG.md`, tags, `migrations/`.
- T4.3 Public-readiness pass on Segoy: README with quick start for a stranger, scrub history check, generic examples, contribution notes. Set up branch rulesets on `main` in Segoy (require PR, 0 approvals, block force-push and deletion, no bypass; free once Segoy is public) and in the brain (same; no bypass needed since ADR-018). Rulesets on a **private** repo need GitHub Pro (observed 2026-11-15: the rules API answers 403 "Upgrade to GitHub Pro"), so decide then whether the brain gets Pro or relies on the skills' rules. Flip to public if not already.
- T4.4 From here on, every Segoy change is an idea in Roke.

Done when: a Segoy improvement is delivered through the pipeline and synced into Roke and the scratch project by PRs.

## M5 — Learning loop and knowledge

Tasks
- T5.1 Skill and task `weekly-review` (journal digest, state reconciliation, ways proposals, stuck-idea detection, stats).
- T5.2 Skills `ingest`, `query`, `lint`; task `brain-lint`.
- T5.3 Import a first batch of existing notes/bookmarks into `knowledge/raw/` and ingest.

Done when: two consecutive weekly review PRs each contain at least one accepted ways-of-working change.

## M6 — Twin

Tasks
- T6.1 Assumption confidence levels and the questions-vs-assumptions metric in triage/spec/plan.
- T6.2 Goal-aware prioritisation in triage and weekly review.
- T6.3 Decide on connectors (calendar/email read-only) after a privacy review; if yes, one Roke-only task that pulls on demand.
- T6.4 Optional: publish `kit/` as a plugin for local sessions.

## Otak (Android app) — runs through the pipeline from M3

Otak is the first project delivered by the pipeline, in thin slices. Each O-milestone is one or more ideas captured in Roke and promoted to the `otak` repo. Spec: `docs/otak-app-spec.md`.

Manual steps for the owner: create the `otak` repo (not created yet); install the Claude GitHub App on it; create a fine-grained token for the app limited to Roke and project repos; install each release APK and do the device check at Gate 2.

- O0 (during M0–M1): spike S8 (Android build in a cloud session), S9, S10. Design groundwork in the Segoy repo: extend `design-system/scripts/build.py` to emit `dist/android/SegoyTokens.kt`; add `Tabs`, `Row`, `Field`, `Toggle`, `Sheet`, `Empty` to the design system with guidelines and previews.
- O1 Capture MVP: `ui-segoy` Compose module (tokens + the components this slice needs, screenshot-tested in both themes); project scaffold (`segoy init project` + Gradle, Compose, CI that builds a signed APK to Releases), token sign-in, brain repo setup, text capture → issue, offline queue, share target.
- O2 Inbox: one GraphQL inbox query; question cards with one-tap answers; Gate 1 and Gate 2 views with approve / request changes / reject; polling worker and notifications.
- O3 Status: pipeline board, idea timeline, activity feed from run records, pause switch.
- O4 Fast capture: widget, quick-settings tile, voice.
- O5 Brain: reader for goals/ways/journal, quick edits as PRs, weekly review handling, Ask Roke.
- O6 Polish: device-flow sign-in, lock options, release automation, public README.

Until O1 ships, capture with GitHub mobile; nothing else changes when the app arrives, because both write the same issues.

## First session prompt for Claude Code

Paste this into a Claude Code session on the `segoy` repo after the manual steps:

```
Read CLAUDE.md and everything in docs/. We are at milestone M0 in docs/bootstrap-plan.md.
1. Propose a short plan for M0 (tasks T0.1–T0.3) and wait for my approval.
2. For the spikes, tell me exactly which things I must click (scheduled task setup) and
   which you can do yourself. Keep each spike minimal and record results in
   docs/adr/spikes-2026-11.md.
3. Work on a claude/ branch and open a PR per task. Do not start M1.
If anything in the docs contradicts what you observe on the platform, stop and tell me
before working around it.
```

## Working agreement during bootstrap

- One milestone at a time; plan first, then PRs of reviewable size.
- Skills are written to the template in `CLAUDE.md` ("Skill format").
- Anything personal that comes up while working in the Segoy repo is redirected to Roke, not written down in Segoy.
- When docs and reality diverge, update the docs in the same PR.
