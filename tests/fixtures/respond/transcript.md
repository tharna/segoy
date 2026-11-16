# segoy-respond dry run (I-20261116-8)

Done by hand on the fixture cases in this folder, following the edited `kit/brain/.claude/skills/segoy-respond/SKILL.md` step by step in event mode (`issues.labeled`, label `answered`). Run time 2026-01-02T08:05:00Z. No GitHub writes: nothing posted, no label changed, no PR opened. Every case reads the owner reply's `answer` block; the free-text lines above it say the same thing.

Common to every case (except Paused): preconditions pass (no open `segoy:paused` issue; the issue is open, has `answered`, and the owner reply at 2026-01-02T08:00:00Z is newer than the triage `run` comment at 2026-01-01T12:01:00Z). Step 1 claims first: `answered` is removed before any other change. Step 3 collects the one owner comment.

## Case task-all-answered

- Step 4: no command.
- Step 5: answers q1 desktop, q2 yes; both questions of round 1 answered in the reply. The issue has `kind:task`, nothing new is unclear → **Small, clear change** bullet: do what `/spec` does in this run.
- `/spec` path: answers already applied, no question left to default; set `state:triaged`; run `segoy-spec` in create mode (its precondition `kind:task`, `state:triaged`, ID in a triage comment holds). Q&A: q1 desktop, q2 yes, both "(your answer)".
- `segoy-spec` opened a PR → no own comment (step 8 skipped per step 4). Step 10: `state:needs-input` removed, one `state:*` label left.
- Result: spec runs: yes. Matches `task-all-answered.md`.

## Case task-partial

- Step 4: no command.
- Step 5: q1 desktop answered; q2 omitted → takes its default (no). q2 only fell back to its default, so the Small, clear change bullet does not apply. Second bullet (a `kind:task` issue with a partial reply) → `state:triaged`, say that `/spec` (plus the label) starts the spec.
- Step 8: one comment ("Platform: desktop (your answer)", "Offline: no (default)", next step `/spec`), `run` block last, `outcome` `ok`. Step 10: `state:needs-input` removed.
- Result: spec runs: no. Matches `task-partial.md`.

## Case idea-all-answered

- Step 4: no command.
- Step 5: both questions answered, but the issue is `kind:idea` → the Small, clear change bullet does not apply; second bullet → `state:triaged`, say that `/spec` starts the spec.
- Step 8: one comment with a `run` block, `outcome` `ok`. Step 10: one `state:*` label.
- Result: spec runs: no. Matches `idea-all-answered.md`.

## Case answers-plus-spec

- Step 4: command `spec` → apply the reply's answers to round 1 first: q1 desktop. Only q2, left unanswered, takes its default (no). Set `state:triaged`, run `segoy-spec` create mode. Q&A: q1 desktop (your answer), q2 no (default).
- Before this change, "it wins over answers" made `/spec` take defaults for every open question: q1 would have been phone. The new text keeps desktop.
- `segoy-spec` opened a PR → no own comment. Step 10: one `state:*` label.
- Result: spec runs: yes, with the owner's answer. Matches `answers-plus-spec.md`.

## Case park-plus-answers

- Step 4: command `park` → `state:parked`; the command applies whatever answers the reply also holds, so the Small, clear change path (step 5) is not reached even though the issue is `kind:task` and fully answered.
- Step 8: one comment with a `decision` block (`gate` `triage`, `outcome` `parked`, `reason` `none given`) and a `run` block last. Step 10: `state:needs-input` removed.
- Result: spec runs: no; parked. Matches `park-plus-answers.md`.

## Paused: task-all-answered with an open `segoy:paused` issue

Paused: stopped at the first precondition. Labels changed: none (`answered` stays on, since claim-first comes after the preconditions). Comments posted: none. Spec: not started.
