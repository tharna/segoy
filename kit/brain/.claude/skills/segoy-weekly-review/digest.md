# Journal digest template: `journal/<yyyy>-W<ww>.md`

Written in `notes_language`. Leave out a section that has nothing in it, except "Stuck ideas" and "State corrections", which say "none". Keep it short enough to read on a phone.

````markdown
---
id: journal-<yyyy>-W<ww>
title: Weekly review <yyyy>-W<ww>
kind: journal
visibility: private
created: <run date>
updated: <run date>
source: segoy-weekly-review
links: []
---
# Weekly review <yyyy>-W<ww>

Period: <from> to <to> (UTC).

## What moved
- <idea ID> <title>: <old state> → <new state> (<link>)
- <project>: <PR title> merged / closed (<link>)

## Filed in this PR
- Notes: <n> (`knowledge/raw/…`)
- Decision records: <n> (`decisions/D-…`)
- Idea stubs: <n> (`ideas/…/idea.md`)
- Waiting for next week: <n> (budget of 20 items per run)

## State corrections
- <idea ID>: file said `<old>`, issue label says `<new>`; files set to `<new>`.

## Stuck ideas (no state change for more than 14 days)
- <idea ID> <title>: `<current state>` for <n> days (<issue link>)

## Needs you
- <idea ID>: label `<state>` but <PR link> is <merged|closed>; the label was not changed.

## Proposed ways changes
- p1 → `<ways/ file>`: <rule> (source: <link>)

## Withheld
- <n> item(s) withheld by the leak check (<file>, line <n>).

## Stats
- Runs: <n> · Questions asked: <n> · Assumptions made: <n> · Gate PRs merged: <n>
````
