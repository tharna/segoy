# migrations

One file per Segoy version that needs more than `segoy sync`: `migrations/<version>.md` (for example `0.2.0.md`). Most versions have none.

`segoy sync` lists every migration newer than the repo's `.segoy/version`, up to and including the Segoy version it syncs to, as `migrate` lines. The sync PR shows them; the owner, or a session the owner asks, follows each one. Sync itself never runs them.

A migration file:

```markdown
---
version: <x.y.z>
applies_to: brain | project | both
---
# Migration to <x.y.z>

## Who needs this
<which repos: a condition you can check, for example "a brain whose config has no `answer_label`">

## Steps
1. <imperative, checkable step>

## Check
<a command or observation that shows it worked, for example `scripts/segoy doctor <dir>`>
```

Rules: steps are idempotent (running twice does no harm), never touch `self/` or notes, and change files only through a PR the owner merges.
