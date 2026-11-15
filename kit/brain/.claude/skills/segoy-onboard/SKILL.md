---
name: segoy-onboard
description: Use in an interactive session on a newly set-up brain repo when the owner wants to fill self/ and ways/public/ through a short interview; the result is one PR.
---
## Inputs
- The owner, live in this session (phone or desktop).
- The topics in `topics.md` next to this file.
- The current `self/*.md` and `ways/public/*.md` (normally the empty template stubs).

## Preconditions (exit quietly if not met)
- This is an interactive session with the owner, not a scheduled task. A scheduled run stops here without doing anything.
- No open issue labelled `segoy:paused` (Segoy protocol §5).
- `.segoy/config.yml` exists and `scripts/segoy doctor --offline` (from a Segoy checkout) or a manual check shows no placeholders in it. If there are placeholders, help the owner fill them in first.

## Procedure
1. Say in two lines what will happen: about 15 minutes, at most three questions at a time, every answer can be "skip", and nothing is saved until the owner merges one PR.
2. Go through the topics in `topics.md` in order. Each round:
   1. Ask at most three questions, each answerable in a line or two from a phone.
   2. Record the owner's answers in their own words. Restate briefly only when unclear, and ask once if unsure.
   3. Never fill a gap with your own guess. "Skip" leaves the topic empty.
3. Mention once, before the `ways/public/` topics, that those files are **copied into project repos** (some of which may be public). The owner should answer them with that in mind; anything personal belongs in `self/` or `ways/private/` instead.
4. After the last topic, show a compact summary per file (bullets only) and ask: "Save this as a PR?" Apply any corrections.
5. Write the files:
   - `self/*.md`: bullets, each ending `(source: owner-stated, <date>)`; goals with `horizon` and `priority` from the owner's answers; keep `visibility: private`.
   - `ways/public/*.md`: one imperative, checkable rule per bullet, each ending `(source: owner-stated, <date>)`; `visibility: shareable`.
   - `ways/private/` entries for preferences the owner marked as personal.
   - Update `updated:` in each changed file's frontmatter.
6. Open one PR: title `Onboarding: self and ways of working`, body listing the changed files and how many entries each got, ending with a `run` block (`skill` `segoy-onboard`, `outcome` `ok`, `next` `owner: review and merge`). Never merge it.
7. Tell the owner the PR link and that agents use these files from the moment the PR is merged.

## Output contract
- One PR in the brain repo changing only `self/`, `ways/public/` and `ways/private/` files. Every entry carries `(source: owner-stated, <date>)`.
- No issue comments. No other files change.

## Stop conditions and budget
- About 15 minutes or 8 rounds of questions, whichever comes first. If the owner wants to stop early, offer to save what exists as the PR.
- If the owner seems unsure about a topic, offer "skip" rather than suggesting answers.

## Never
- Never infer traits, goals or values; write only what the owner said.
- Never put anything personal into `ways/public/`.
- Never run unattended or from a scheduled task.
- Never merge the PR or push to `main`.
- Never repeat `self/` content outside this repo, including in a summary posted elsewhere.
