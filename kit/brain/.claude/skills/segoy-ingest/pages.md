# Ingest page formats

Used by `segoy-ingest`. Replace `<…>`. Every page has the brain frontmatter (brain `CLAUDE.md` rule 3). `<stem>` is the raw file name without `.md`. Pages under `knowledge/wiki/<folder>/` link the raw file as `../../raw/<stem>.md`.

## Source summary page: `knowledge/wiki/sources/<stem>.md`

One per raw file. Summarise in your own words in `notes_language`; quote at most a few short lines. Text derived from a private part of the source goes inside a private block.

````markdown
---
id: source-<stem>
title: <source title>
kind: source
visibility: private
created: <run date>
updated: <run date>
source: knowledge/raw/<stem>.md
links: [knowledge/raw/<stem>.md, <wiki pages this source updated or created>]
---
# <source title>

<Two to five sentences: what the source is and its main claims.>

## Key points
- <claim or fact, in one line>

## Bears on
- [<page title>](../<folder>/<page>.md): <what this source adds there, in one line>

## Sources
- [knowledge/raw/<stem>.md](../../raw/<stem>.md)
````

## New topic, entity or synthesis page: `knowledge/wiki/<topics|entities|syntheses>/<slug>.md`

Only when no existing page matches. `<slug>` is lowercase kebab-case from the English title. `visibility: private` by default.

````markdown
---
id: <topic|entity|synthesis>-<slug>
title: <title>
kind: <topic|entity|synthesis>
visibility: private
created: <run date>
updated: <run date>
source: knowledge/raw/<stem>.md
links: [knowledge/raw/<stem>.md, knowledge/wiki/sources/<stem>.md]
---
# <title>

<What this topic or entity is, and what the sources say about it.>

## Sources
- [knowledge/raw/<stem>.md](../../raw/<stem>.md): <what it contributes, in one line>
````

## Updating an existing page

- Add what the source contributes to the page's body, next to the related text. Mark a claim that contradicts the page as "Contradicts …" with both sources cited; never resolve a contradiction silently.
- Add one line to its `## Sources` section (create the section at the end if missing): `- [knowledge/raw/<stem>.md](../../raw/<stem>.md): <what it contributes>`.
- Add `knowledge/raw/<stem>.md` to frontmatter `links`. Keep `id`, `created`, `visibility`; set `updated` to the run date.
- Never duplicate the page under another name.

## Private text

Text derived from a private source, or from a private part of one, is wrapped exactly like this, in any page:

````markdown
<!-- private -->
<derived text>
<!-- /private -->
````

## Index line: `knowledge/wiki/index.md`

One line per new page, under the matching `## <topic>` heading (create the heading if none fits; source pages go under `## Sources`):

````markdown
- [<title>](<folder>/<file>.md) (<kind>): <one-line summary>
````

## `log.md` line

Exactly one appended line per ingest PR:

````markdown
<run date> · segoy-ingest · ingest <stem> · <file>, <file>, …
````
