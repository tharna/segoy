# segoy

Segoy is a kit that turns Claude Code and GitHub into a personal idea-to-implementation pipeline: capture an idea on your phone, answer a few questions, approve a plan, review a pull request.

It is files, not a service: skills, agents, a hook, templates, scheduled-task prompts and one shell script. You copy them into your own repos, and Claude Code cloud sessions run them when you act on GitHub.

Status: 0.1.0. Used daily by its author; expect rough edges. See [CHANGELOG.md](CHANGELOG.md).

## How it works

1. **Brain.** A private repo made from `kit/brain` holds your ideas, ways of working, decisions and personal context. The docs call the author's brain *Roke*; read that as "your brain".
2. **Capture.** Open an issue in the brain from your phone. A scheduled task triages it: labels, an idea ID, related items, at most three questions with defaults.
3. **Spec.** Answer, add the label `answered`, and the idea becomes a spec PR in the brain. Merge it to approve.
4. **Gate 1.** The plan, with private content stripped and leak-checked, arrives as a `segoy:plan` PR in the project repo. Merging it is your plan approval and privacy review.
5. **Gate 2.** The build arrives as a `segoy:impl` PR with evidence for every acceptance criterion. Merge to accept; a short retro PR follows.

Nothing merges itself, and nothing personal leaves the brain except through a PR you merge. Details: [docs/README.md](docs/README.md).

## Quick start

You need: a GitHub account, a Claude plan with Claude Code on the web (Pro is enough), and `git`, `jq` and the GitHub CLI `gh` wherever you run the script (a Claude Code cloud session has all three).

1. **Repos.** Create a private repo for your brain (any name) and clone Segoy. At [claude.ai/code](https://claude.ai/code), connect GitHub and install the Claude GitHub App on the brain and on each project repo.
2. **Brain.** In a checkout of your brain:
   ```sh
   segoy/scripts/segoy init brain <brain>      # copies kit/common + kit/brain, creates labels
   ```
   Fill `.segoy/config.yml` (your handle, languages) and `.segoy/denylist.txt` (private terms that must never leave the brain), commit on a branch, open a PR and merge it. Check with `segoy/scripts/segoy doctor <brain>`.
3. **Project.** For each repo you want things built in:
   ```sh
   segoy/scripts/segoy init project --ways <brain>/ways/public <project>
   ```
   Fill the Commands section of its `CLAUDE.md`, then PR and merge.
4. **Tasks.** Create the scheduled tasks described in [`tasks/`](tasks/README.md) at claude.ai/code: `brain-triage` and `brain-respond` first, then per project `brain-plan-promote-<repo>`, `brain-gate-sync-<repo>`, `project-implement`, `project-implement-pr`, `project-retro`, and one `kit-sync`. Each file lists the exact settings and prompt.
5. **Try it.** Open an issue in the brain with one line about an idea. Within minutes it has labels and a triage comment. The cheat sheet in your brain's `README.md` explains the rest.
6. **Optional: onboarding.** Start a session on the brain and say "run segoy-onboard" to fill `self/` and `ways/public/` through a short interview.

Keep the kit current with the weekly `kit-sync` task, or by hand: `segoy/scripts/segoy sync --pr <repo>`.

## Repository map

- [`kit/`](kit/README.md): what gets copied into your repos (`common`, `brain`, `project`).
- [`scripts/segoy`](scripts/README.md): `init`, `sync`, `doctor`.
- [`tasks/`](tasks/README.md): scheduled-task settings and prompts.
- [`docs/`](docs/README.md): requirements, architecture, workflows, protocol, ADRs, specs and retros.
- [`design-system/`](design-system/README.md): the terminal-style design language used by every Segoy UI, including the Otak Android app.

## Contributing and security

See [CONTRIBUTING.md](CONTRIBUTING.md) and [SECURITY.md](SECURITY.md). Licence: [MIT](LICENSE).
