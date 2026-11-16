# Otak — Android app spec

> **Roke** is the author's own brain repo (private). These docs use it as the worked example; read it as "your brain", the private repo you create from `kit/brain`.

Version 0.1, 2026-11-14. Otak is the mobile companion for Segoy: the primary way to capture ideas, see what agents are doing, answer their questions, and make gate decisions. Named after the small companion animal in Earthsea that rides along everywhere.

The app lives in its own repository, `<owner>/otak`.

## 1. Decisions already made

| Topic | Decision |
|---|---|
| Platform | Android, native Kotlin |
| Backend | None. The app talks only to the GitHub API (and optionally a scheduled task's API trigger). No relay, no server, no analytics. |
| Source of truth | GitHub: issues, labels, comments, PRs, files. The app holds only a cache and an offline queue. |
| Look and feel | Segoy design system (`design-system/` in the Segoy repo): terminal-style, thumb-first. See §5a. |
| Gate 2 from the phone | Allowed on all repos, behind biometric confirmation. |
| Photo capture | Deferred; not in O1–O6. |
| Minimum Android version | Android 10 (API 29). |
| App language | English UI; content in whatever language the owner writes. |
| Distribution | Signed APK from GitHub Releases; Play Store is a later, separate decision. |
| Genericity | Otak is as generic as Segoy: it is configured with a brain repo and reads everything else from it. No personal data in the app's repo. |

Consequence of backend-free: there is no instant push. The app polls. Background checks run at most about every 15 minutes (Android's periodic work minimum) and may be delayed by battery saving; opening the app refreshes immediately.

## 2. Screens

1. **Capture** (default screen, also reachable from widget, tile, share sheet)
   - One text field, send button. Optional kind chips: idea / note / me. Optional target project.
   - Voice: dictation button using on-device speech recognition; text is editable before sending; audio is never stored or uploaded.
   - Works offline: capture goes to a local queue and is sent when online. A capture is never lost and never blocks.
2. **Inbox** (things waiting on you), ordered by what blocks agents most
   - Agent questions → card with question text, option buttons, the suggested default, free-text field. "Accept all defaults" for a round.
   - Plan approvals (Gate 1) → readable plan view: summary, assumptions (with confidence), task list, size, risks. Actions: Approve (merge), Request changes (comment + `answered` label), Reject (close + one-line reason).
   - PR reviews (Gate 2) → summary, acceptance criteria with evidence, deviations, CI status; diff one tap away (in-app simple diff or open in GitHub). Actions: Merge, Comment, Close.
   - Weekly review → each proposal accept/reject, then merge.
   - Failed or stuck runs → what happened and the single next action.
3. **Pipeline** (status)
   - Board of ideas by state, filter by project. Stuck items flagged (in a state longer than a threshold).
   - Idea detail: timeline built from the Roke issue's comments and linked PRs.
   - Project view: open ideas, PRs, last retro, link to repo.
4. **Activity**
   - Feed of agent runs from run records (see protocol): skill, repo, outcome, duration, links to PR and to the Claude session where available.
   - Counts per day/week as a simple usage indicator.
5. **Brain** (later milestone)
   - Read `self/goals.md`, `ways/`, journal digests rendered as pages.
   - Quick edit → opens a PR in Roke.
   - Ask Roke: sends a question to a brain task; the answer arrives as an issue comment and shows in the Inbox. Asynchronous, because there is no backend to hold a chat.
6. **Settings**
   - GitHub sign-in, brain repo, discovered project repos, polling interval, notification categories, biometric lock, pause switch, export/clear local data.

Entry points: launcher, home-screen widget (capture box + inbox count), quick-settings tile (capture), share target (text and links from any app), app shortcut for voice capture, notifications.

## 3. Notifications (polling-based)

- Background worker polls for: new agent questions, new Gate 1/Gate 2 PRs, failed runs, weekly review.
- Notification actions where safe: "Accept default" for a single-question round; "Open" for everything else. Merging is never done from a notification without opening the review (and passing the biometric lock if enabled).
- Uses conditional requests so unchanged data is cheap and stays well inside API rate limits.

## 4. Agent–app protocol

The app must not parse prose. Skills therefore add a small machine-readable block to what they already post. Humans using plain GitHub see normal text and can ignore the block. Full definition lives in Segoy at `docs/protocol.md`; outline:

- A fenced code block with info string `segoy` containing one JSON object (ADR-022), at the end of a comment or PR body. Full definition: `docs/protocol.md`.
- Kinds:
  - `question` — idea id, round id, list of questions each with id, text, optional options, default.
  - `answer` — posted by the app: round id, map of question id → answer. **The app adds the answer label (`answered`) in the same action**, because comments alone start no task (ADR-016). Plain-text replies from GitHub mobile remain valid input; without the label they are picked up by the periodic sweep.
  - `plan` — in the Gate 1 PR body: idea id, summary, assumptions with confidence, tasks, size, omitted-private count.
  - `impl` — in the Gate 2 PR body: idea id, criteria with evidence and pass/fail, deviations.
  - `run` — a run record comment: skill, repo, idea id, started, finished, outcome, next action, session link if known.
  - `review` — weekly review PR: list of proposals with ids so each can be accepted or rejected.
- Versioned (`v: 1`). The app ignores unknown fields and unknown kinds.
- State is still labels (`state:*`, `segoy:*`); the block only carries content the app renders.

Pause switch without a backend or a commit: an open issue labelled `segoy:paused` in a repo means automation is paused there (in Roke: paused everywhere it governs). Every skill checks for it in its preconditions and exits quietly. The app opens/closes that issue.

## 5. Technical design

- Kotlin, Jetpack Compose, single-activity. UI is built from Segoy components on Compose foundation; Material is used only for behaviour it gives for free (insets, accessibility semantics), never for its look. Min SDK 29 (Android 10).
- Layers: UI (Compose) → view models → repositories → GitHub client + local store.
- GitHub client: GraphQL for reads (one query for inbox), REST where needed (merge, labels, contents). HTTP via OkHttp/Ktor; kotlinx.serialization.
- Local store: Room for cache and the offline capture queue; DataStore for settings.
- Background: WorkManager (periodic poll; one-off upload work with network constraint for queued captures).
- Auth, in order of implementation:
  1. Fine-grained personal access token pasted once, limited to the brain repo and project repos (simplest, no app registration).
  2. GitHub device-flow sign-in (needs only a public client id, so still backend-free).
  Token stored encrypted with the Android Keystore. Optional biometric lock on app open and before merge actions.
- Speech: on-device recognizer; fall back to the keyboard's dictation if unavailable.
- No third-party analytics or crash reporting. Optional local log export.
- Distribution: signed APK built by GitHub Actions and attached to GitHub Releases; installed directly (or via an updater app). Play Store is a later, separate decision.

## 5a. Design: the Segoy design system on Android

Otak follows the Segoy design system that already lives in the Segoy repo (`design-system/`): monospace everywhere, Unicode glyphs instead of icons, one colour per meaning with orange reserved for Claude and green for the person, `phosphor` (green on near-black) as default theme and `daylight` as the light one, no shadows, no pills, stepped motion only. The brand book is `design-system/project/README.md`; tokens are `design-system/project/tokens.json`. Otak adds nothing to the palette.

The system is currently web-only (CSS classes with the `sg-` prefix). Two pieces of work bring it to Android:

1. **Token export.** Extend `design-system/scripts/build.py` to also emit `dist/android/SegoyTokens.kt` from `tokens.json` (colours per theme, type scale, spacing, radius, sizes), with the same contrast check. Otak vendors that generated file at a pinned design-system version; it is never edited by hand. Units: font sizes become `sp`, everything else `dp`.
2. **Compose component library** (module `ui-segoy` in the Otak repo): one composable per design-system component with the same names and rules as the CSS — `SgMessage`, `SgPrompt`, `SgPermission`, `SgToolCall`, `SgTodoList`, `SgDiff`, `SgCodeBlock`, `SgBadge`, `SgButton`, `SgSpinner`, `SgStatusLine`. Each has a screenshot test in both themes, compared against the web preview by eye at review.

How the app's screens use the existing components:

| App element | Component | Notes |
|---|---|---|
| Capture | `Prompt`, docked | Green `>` caret, growing field, primary `[ Send ]`. Kind and project as slash/at commands (`/note`, `/me`, `@otak`) with tappable suggestions above the keyboard, so typing and touch both work. |
| Agent question | `Permission` | The yellow "waiting on you" box. Options are full-width numbered rows; the default is pre-highlighted; free text below. |
| Gate 1 plan | `Message` (Claude) + `TodoList` for tasks + `Permission` for approve / request changes / reject | Assumptions as a list with confidence badges. |
| Gate 2 PR | `Message` + criteria as `✓`/`✗` rows + `Diff` + `Permission` | Diff scrolls sideways inside its own box. Reject option last, in `err`. |
| Idea timeline | `Message` rows | `>` you, `●` agent, `※` system/state changes. |
| Activity feed | `ToolCall` | `⏺ triage(I-20261114-1)` with a `⎿` one-line result; glyph colour shows running / ok / failed; tap to expand. |
| Pipeline | `TodoList` glyphs + `Badge` | `☐` waiting, `▸` in progress, `☒` done; state names as badges. |
| Footer | `StatusLine` | Up to five items: brain repo, waiting count (`! 2`), queued captures, last sync, paused. |
| Syncing / agent working | `Spinner` | Glyph cycle; static under reduced motion. |

Terminal-like, but usable by touch:

- Every tappable thing is at least 48dp high (the system's 44px minimum, rounded up to Android's guideline). Dense rows get their height from padding, not smaller text.
- Body text is never below the system's `text-body` size; text scales with the user's font-size setting, and layouts must survive 200% scaling.
- Nothing requires typing a command. Commands exist as a fast path; every command has a tappable equivalent.
- Swipe is an accelerator only (e.g. swipe a question card to accept its default), always with a visible button doing the same.
- One primary (orange) action per screen.
- Colour never carries state alone: glyph or word always present; glyphs get spoken labels for TalkBack.
- Motion: only cursor blink, running-glyph blink, spinner; all off when the system's "remove animations" is on.
- Both themes ship; default follows the system dark/light setting with `phosphor` for dark, and can be pinned.
- Fonts are bundled in the app (JetBrains Mono for everything, VT323 for the splash only), not fetched at runtime.
- Copy follows the system's voice: short plain sentences, sentence case, exact numbers with units, no exclamation marks, no emoji.

Gaps in the design system that Otak needs, to be added to the design system first (guidelines + web preview), then implemented in Compose:

- `Tabs` — bottom navigation as terminal text (e.g. `capture │ inbox 2 │ pipeline │ activity`), active item in `claude`.
- `Row` — a tappable list row with glyph gutter, title, secondary line, trailing badge.
- `Field` and `Toggle` — settings inputs in terminal style (`[x]` / `[ ]` toggles).
- `Sheet` — a bottom panel for option lists and confirmations.
- `Empty` — empty-state line (`※ nothing waiting on you`).
- App icon and splash using the display face.

## 6. Privacy and security

- The app shows private brain content: biometric lock, no content in notifications beyond a category and title unless enabled, screenshots allowed but off in the task switcher preview (configurable).
- Token scope is the minimum: issues, pull requests, contents (read; write only if quick edits are enabled), metadata, on selected repos only.
- Cache can be wiped from settings; sign-out wipes token and cache.
- Otak's repo is public-safe: no repo names, tokens, or sample personal data; fixtures use placeholders.

## 7. How it gets built

Otak is the first real project built through the Segoy pipeline after milestone M3, which makes it the pipeline's proving ground.

Constraints to plan for:
- Agents in cloud sessions cannot run a phone. Verification is unit tests, view-model tests, and screenshot tests that run on the JVM; CI builds the APK; the owner installs it and does the device check at Gate 2.
- The cloud environment needs the Android SDK and access to Google's Maven and download hosts, which may be outside the default network allowlist (spike S8).
- Therefore plans for Otak are sliced thin: each PR is one screen or one capability with tests.

Milestones:
- **O0 Design groundwork** (in the Segoy repo): Android token export in `build.py`; new components `Tabs`, `Row`, `Field`, `Toggle`, `Sheet`, `Empty` added to the design system.
- **O1 Capture MVP**: `ui-segoy` module with the components O1 needs (Prompt, Button, Message, StatusLine, Tabs, Field); sign-in with token, choose brain repo, capture text → issue, offline queue, share target. *Replaces GitHub mobile for capture.*
- **O2 Inbox**: questions with one-tap answers; Gate 1 and Gate 2 review and merge; polling notifications.
- **O3 Status**: pipeline board, idea timeline, activity feed, pause switch.
- **O4 Fast capture**: widget, quick-settings tile, voice.
- **O5 Brain**: goals/ways/journal reader, quick edits as PRs, weekly review handling, Ask Roke.
- **O6 Polish**: device-flow sign-in, biometric lock options, release automation, public README.

## 8. Spike results and remaining assumptions

Results of the M0 spikes are in `adr/spikes-2026-11.md`.

- S8 **confirmed**: a Compose debug APK builds in a cloud session. Needs a separate environment for Otak that allows `dl.google.com`; JDK 17 from apt; the SDK through the new `android sdk` CLI. About 4 min cold, about 2 GB disk. Put the SDK install in that environment's setup script. Known snag: the templates' `compileSdk = 37` fails because the platform is published as API `37.0`; use 36, or check AGP's minor-API syntax, before targeting 37.
- S9 **confirmed**: run records can link to the session (`CLAUDE_CODE_REMOTE_SESSION_ID` → `https://claude.ai/code/session_<id>`).
- S10 **partly**: tasks offer an API trigger (`/fire` with a per-task bearer token, 30 runs/hour per task, optional `text`). Not yet decided whether a long-lived per-task token may live on the phone. Until then, "run now" and Ask Roke create a labelled issue that the normal triggers pick up, which should work: the app uses the owner's own token, not Claude's GitHub tools, so its events count as the owner's. Verify this in O1. A dispatcher is the planned alternative (ADR-021).
- Answers need a label as well as a comment (ADR-016). Issues and comments made by agents never start tasks; labels made by agents do, so label triggers filter on their label (ADR-015 and its amendment). Events caused by the app with the owner's token are expected to (verify in O1).
- No public API is known for live cloud-session status or plan usage; the app derives status from GitHub and shows run counts instead of a true usage meter.

## 9. Open questions

None at the moment. Photo capture and Play Store distribution are deferred, not open.
