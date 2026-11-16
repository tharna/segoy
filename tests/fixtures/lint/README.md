# Lint fixtures

Fixture brains for `kit/common/.claude/scripts/brain-lint.sh` and the `segoy-lint` dry run (I-20261116-7). All content is placeholder text. The fixed test date is **2026-01-10**; `tests/check-brain-lint-script.sh` copies each brain to a temporary git repo with one commit dated 2025-12-01, so a derived `created` is `2025-12-01`.

## `clean/`

A small brain with complete frontmatter, consistent `ideas/` and `decisions/` indexes, a wiki index that lists every wiki page, and no stale or orphan page. `self/goals.md` has a body line with `SELF-BODY-MARKER`, which must never appear in lint output. Expected: no output, exit 0.

## `dirty/`

`clean/` plus these planted problems. `expected-report.txt` is the exact report-mode output (`--today 2026-01-10`).

| # | Planted problem | File | Expected finding | Fixed by `--fix`? |
|---|---|---|---|---|
| 1 | Wiki page with no inbound link | `knowledge/wiki/topics/example-orphan.md` | `orphan … no inbound link`; also `index knowledge/wiki/index.md …example-orphan.md: no row (fixable)` | Index row added under `## Unfiled`; the page is not changed |
| 2 | Wiki page `updated` 120 days before the test date | `knowledge/wiki/topics/example-stale.md` (`updated: 2025-09-12`) | `stale … updated 2025-09-12, 120 days ago` | No |
| 3 | Idea missing `kind` and `links` | `ideas/I-20251201-1-example-idea-one/idea.md` | `frontmatter … missing kind (fixable)`, `missing links (fixable)` | Adds `kind: idea`, `links: []`, sets `updated: 2026-01-10` |
| 4 | Decision missing `source` | `decisions/D-20251205-1.md` | `frontmatter … missing source` | No (not derivable) |
| 5 | Index row whose idea folder is missing | `ideas/index.md` row `I-20251130-1` | `index ideas/index.md row I-20251130-1: no file (fixable)` | Row removed |
| 6 | Idea folder with no index row | `ideas/I-20251202-1-example-unlisted-idea/` | `index ideas/index.md I-20251202-1: no row (fixable)` | Row appended |
| 7 | Index row with a wrong state | `ideas/index.md` row `I-20251203-1` says `specced`, its `plan.md` says `planned` | `index ideas/index.md row I-20251203-1: state "specced" differs from file "planned" (fixable)` | State cell set to `planned` |
| 8 | Raw file without frontmatter | `knowledge/raw/20251201-example-raw-note.md` | `frontmatter … no frontmatter (raw file, not fixed)` | No (raw files are immutable) |
| 9 | `self/` file missing `updated` (body has `SELF-BODY-MARKER`) | `self/goals.md` | `frontmatter self/goals.md missing updated (fixable)` | Adds `updated: 2026-01-10`; body untouched, marker never printed |
| 10 | Two wiki pages with conflicting claims, both indexed, linked to each other, not stale | `knowledge/wiki/entities/example-tool-x.md` ("Example tool X stores data as plain text files.", marked `conflicting claim A`) and `knowledge/wiki/topics/example-tool-x-storage.md` ("Example tool X stores data in a binary database.", marked `conflicting claim B`) | None from the script; the `segoy-lint` dry run (T3) must flag the pair with both lines quoted by `path:line` | Never |

After `--fix`, a second report run shows only the decision's `missing source`, the raw file finding and the stale page (the orphan gets an index row, so it has an inbound link).
