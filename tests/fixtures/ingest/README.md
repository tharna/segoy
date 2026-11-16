# Ingest fixture

A small fixture brain for the `segoy-ingest` dry run (I-20261116-6). Checked by `tests/check-ingest.sh`.

- `brain/`: the brain's files before the run.
  - `knowledge/raw/20260101-example-article-about-checklists.md`: the new source, filed by a weekly review PR. Its frontmatter says `shareable`, and one part is inside a private block (marker phrase "household budget").
  - `knowledge/raw/20251220-example-covered-note.md`: a source that already has an open ingest PR (#11).
  - `knowledge/wiki/topics/checklists.md`: an existing `shareable` topic page the new source bears on. `knowledge/wiki/index.md` lists it.
- `github/merged.json`: the merged review PR #14 that added the new raw file, and the open ingest PR #11 for the covered note. Run time 2026-01-02T10:00:00Z.
- `github/run-now.json`: the same state without a trigger PR (Run now).
- `github/no-raw.json`: a merged spec PR that added no raw file: the run exits quietly.
- `github/paused.json`: as `merged.json` plus an open `segoy:paused` issue: the run posts and changes nothing.
- `dry-run/`: the files the run writes on its branch, at their brain paths. `pr-body.md` and `transcript.md` sit next to it.
