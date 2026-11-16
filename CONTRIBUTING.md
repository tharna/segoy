# Contributing

Thanks for looking. Segoy is small and opinionated; issues and focused PRs are welcome.

## Before you start

- Read [`CLAUDE.md`](CLAUDE.md): it holds the hard rules for this repo, for people and agents alike.
- For anything beyond a small fix, open an issue first with the problem and a short plan. Changes to `kit/` reach every repo that syncs it, so they need agreement before code.
- Segoy is developed through its own pipeline: most changes start as an idea in the author's brain and arrive as a `segoy:plan` PR (Gate 1) followed by a `segoy:impl` PR (Gate 2). Outside PRs go through ordinary review.

## Rules that PRs are checked against

1. **Nothing personal.** No names, e-mail addresses, private project names or brain content. Examples use placeholders (`<owner>`, `I-20260101-1`, "example idea"). CI runs the leak guard on every PR.
2. **Shell is POSIX `sh`**, with `git`, `gh` (REST calls only) and `jq`. No other runtime for scripts.
3. **Skills** (`kit/**/SKILL.md`) follow the format in `CLAUDE.md`, stay under about 150 lines, and must pass `scripts/segoy doctor --skills`. A changed skill comes with an updated fixture or a dry-run transcript in the PR.
4. **Protocol.** Anything a skill posts (comments, PR bodies, labels) must keep [`docs/protocol.md`](docs/protocol.md) valid; check bodies with `scripts/segoy doctor --protocol <file>`.
5. **Vendored copy.** This repo's `.claude/` is the kit applied to itself. Change `kit/`, then run `scripts/segoy sync --no-github .`; CI fails if they differ.
6. **Docs follow behaviour.** If a change alters what Segoy does, update the docs in the same PR. Decisions with lasting effect get an ADR in `docs/adr/`.

## Checks

```sh
shellcheck -x scripts/segoy scripts/lib/*.sh tests/*.sh kit/common/.claude/scripts/*.sh kit/project/.claude/*/*.sh
scripts/segoy doctor --skills
tests/run.sh
python3 design-system/scripts/build.py --check
```

## Commits and PRs

- Commits: `<id or area>: <imperative summary>`, for example `sync: report orphaned files`.
- PR body: what, why, how verified, follow-ups.
- Never push to `main`; nothing merges without the maintainer.

## Releasing (maintainer)

1. Move the `Unreleased` entries in `CHANGELOG.md` under a new `## x.y.z - <date>` heading and set `VERSION` to `x.y.z`, in one PR.
2. If repos need more than `segoy sync` to upgrade, add `migrations/x.y.z.md` (format in [`migrations/README.md`](migrations/README.md)) in the same PR.
3. After merging: GitHub → Releases → *Draft a new release*, tag `vx.y.z` on `main`, notes from the changelog.
4. The weekly `kit-sync` task opens sync PRs in each repo; press **Run now** to do it at once.
