---
id: I-20261116-6
title: Knowledge ingest skill
kind: idea
state: specced
visibility: shareable
created: 2026-11-16
updated: 2026-11-16
source: promoted
links: []
---
# Spec: Knowledge ingest skill

## Problem
Raw sources land in `knowledge/raw/` but nothing turns them into wiki pages, so the wiki only grows when someone writes it by hand.

## Users and context
The brain owner, who drops notes and sources into the brain (notes mostly arrive through the weekly review) and reviews one PR per source.

## Outcomes
- Each new raw file leads to one reviewable `segoy:knowledge` PR.
- The wiki stays linked to its sources and its index and log stay current.
- Raw files are never changed.

## In scope
- A kit skill `segoy-ingest` and the scheduled task that starts it.
- Trigger: the merge of a PR that adds files under `knowledge/raw/` (pull_request closed and merged), plus Run now. Not a push trigger.
- The PR contains: a summary of the source, new or updated wiki pages for every page the source bears on, `knowledge/wiki/index.md` and `log.md`.

## Out of scope
- Query (answering questions from the wiki); to be captured as its own idea.
- Starting ingest from each note issue.
- Editing, moving or deleting raw files.

## Acceptance criteria
1. Given a merged PR that added a file under `knowledge/raw/` with no ingest PR yet (or Run now with such a file), when the task runs, then exactly one PR labelled `segoy:knowledge` is opened for it.
2. Given that PR, then it changes no file under `knowledge/raw/`.
3. Given that PR, then it adds a source summary page and every wiki page it creates or updates cites the raw file by path.
4. Given the source bears on existing wiki pages, when ingest runs, then each such page is updated rather than a duplicate created.
5. Given the PR, then `knowledge/wiki/index.md` lists every new page and `log.md` has one appended line with date, actor, operation and files touched.
6. Given a raw file already covered by an open or merged ingest PR, when the task runs again, then no second PR is opened.
7. Given a source with content marked private, when pages are written, then that content appears only inside private blocks.
8. Given the PR body, then it ends with valid protocol blocks (checked with `protocol.sh`), including a `run` block.
9. Given an open issue labelled `segoy:paused`, when the task runs, then it posts and changes nothing.

## Constraints
- Changes only the Segoy kit; the brain is touched only through the PR.
- Nothing is committed to the default branch; the owner merges.
- Wiki pages follow the brain frontmatter rules and cite sources.

## Open questions
- Should one run ingest several new raw files in one PR? (proposed default: no, one PR per raw file)

## Assumptions
- Ingest updates every page the source bears on (likely, brain)
- Ingest starts from the merge of a PR adding raw files (or Run now), not from a push or note issues (firm, owner-stated)
- Query is specced separately (firm, owner-stated)
