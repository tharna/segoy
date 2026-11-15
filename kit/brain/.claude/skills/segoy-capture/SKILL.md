---
name: segoy-capture
description: Use when the owner types "idea:", "note:" or "me:" followed by text in a session on the brain repo; files it as an issue and triages it in the same session.
---
## Inputs
- The owner's message in this session: a prefix (`idea:`, `note:`, `me:`) and the text after it, possibly several lines.
- `.segoy/config.yml` (`owner`, `brain_repo`).

## Preconditions (exit quietly if not met)
- This session runs on the brain repo (`brain_repo` in config).
- No open issue labelled `segoy:paused` (Segoy protocol §5). If paused, tell the owner in one line instead of capturing.
- The message is a capture: it starts with one of the prefixes, or the owner asked explicitly to capture it.

## Procedure
1. Split the message: the **title** is the first line after the prefix, trimmed, at most 80 characters (cut at a word boundary and keep the rest for the body); the **body** is the remaining lines, exactly as typed.
2. Keep the prefix in the title for `note:` and `me:` (triage reads it); drop `idea:`.
3. Create the issue in `brain_repo` with that title and body, and no labels.
4. **Run `segoy-triage` on the new issue now, in this session.** An issue created through the session's GitHub tools does not start the `brain-triage` task (ADR-015), so triage must happen here.
5. Reply to the owner in one or two lines: the issue link, the idea ID if one was assigned, and whether questions are waiting.

## Output contract
- One new issue in the brain repo containing the capture verbatim, triaged by `segoy-triage` (its comment and labels).
- A short reply in the session.

## Stop conditions and budget
- One capture per message. If the owner sends several, capture each in turn, at most five per message, then ask before continuing.
- If creating the issue fails twice, stop and give the owner the text back so nothing is lost.

## Never
- Never change the wording of the capture.
- Never capture into any repo other than `brain_repo`.
- Never skip triage after creating the issue.
