# Weekly review fixture

A small fixture brain for the `segoy-weekly-review` dry run (I-20261116-2, I-20261116-3). Checked by `tests/check-weekly-review.sh`.

- `brain/`: the brain's files before the run. `ways/public/principles.md` holds one bullet with a leftover `(proposed; ` marker; `decisions/D-20251215-1.md` has a `(proposed)` generalisation that must stay.
- `no-marker/brain/`: the same `ways/` file without the leftover marker (runs B and D); `no-marker/dry-run/`: what run D writes differently from `dry-run/`.
- `project/`: one project repo, read-only (a retro with a proposed rule).
- `github/active.json`: the GitHub state the run sees (issues, comments, label events, PRs). Run time 2026-01-04T16:00:00Z, Sunday 18:00 Europe/Helsinki.
  It holds one note issue (#12), one parked idea with no stub and an undocumented `decision` block (#5), one idea whose file state drifted (#3), one idea stuck for 20 days (#4) and a merged Gate 2 PR.
- `github/empty.json`: a quiet week with no activity and no drift, but one stuck idea: the run opens nothing.
- `github/paused.json`: the active week plus an open `segoy:paused` issue: the run posts and changes nothing.
- `dry-run/`: the files the run writes on its branch, at their brain paths. `pr-body.md` and `transcript.md` sit next to it.
