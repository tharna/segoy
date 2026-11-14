Segoy is the interface language for Claude Code sessions: a terminal you can use with one thumb. It keeps the terminal's monospace grid, its glyphs and its green on black, and gives every colour one job so a long transcript can be read at a glance on a phone.

## Principles

- **Colour is meaning.** Each hue stands for one kind of thing (see the table below). Never pick a colour because it looks nice next to another; pick the token for what the thing is.
- **Orange is Claude.** `claude` marks Claude's voice, the brand, the cursor and the one primary action. Green (`prompt`) marks the person. If you can see orange, Claude did it or is waiting to do it.
- **A terminal, not a costume.** Monospace everywhere, square cells, Unicode glyphs instead of icons. No CRT curvature, no scan-line overlays on content, no fake window chrome.
- **Thumb first.** Anything tappable is at least `touch` (44px). Text never makes the page scroll sideways; code, diffs and commands scroll inside their own box.
- **Never colour alone.** Every status also has a glyph or word: `✓` `✗` `!` `+` `-`.

## Colour

Two themes. `phosphor` (green on near-black) is the default and the first theme; `daylight` is the same system on a pale green-grey for bright rooms. Both meet WCAG AA: every text token is at least 4.5:1 on the grounds its usage note names, and `line-strong` and `focus` are at least 3:1 on `bg` and `surface`. `scripts/build.py --check` verifies this in both themes.

| Token | Means | Example |
| --- | --- | --- |
| `fg` | Ordinary text | Claude's prose, code |
| `fg-strong` | Emphasis and the person's own words | Headings, user messages |
| `fg-muted` | Secondary information | Tool output summaries, line numbers, hints |
| `claude` | Claude: voice, brand, primary action, cursor | `●` bullet, Send button, active todo |
| `prompt` | The person | `>` caret, branch name |
| `tool` | A tool call | `⏺ Bash(npm test)` |
| `path` | A file, URL or link | `src/auth/login.ts` |
| `think` | Thinking and planning, no output yet | `✻ Thinking…` |
| `ok` | Success, added lines | `✓ 42 passed`, `+` lines |
| `err` | Failure, denial, removed lines | `✗ 1 failed`, `-` lines |
| `warn` | Waiting on the person or about to do something risky | Permission box, `rm -rf` |

Grounds are `bg` (the page), `surface` (panels: tool output, code, the user's turn), `surface-raised` (the prompt bar, hover). Each status colour has a `-tint` ground for badges and diff lines; text on a tint stays `fg` and only the glyph takes the status colour. Text on a `claude` fill is `on-claude`, never literal white or black. Borders: `line` for decoration, `line-strong` for anything you can interact with.

Do not introduce new hues. A new kind of thing either fits an existing meaning or is `fg`.

## Type

Everything is set in JetBrains Mono (`--font-mono`), loaded from Google Fonts with the platform monospace as fallback. VT323 (`--font-display`) is a pixel face for the product name and splash screens only, one use per screen, never for running text.

- `text-body` (15px / 24px) for messages and input. On a phone this is the smallest size for anything the person must read in full.
- `text-code` (14px / 22px) for code, diffs and commands; `text-small` (13px / 20px) for secondary lines and the status line.
- `text-heading` and `text-title` are bold, not bigger-and-lighter. Hierarchy comes from weight and colour, as in a terminal.
- `text-label` is the only uppercase style, for badges.
- The prompt textarea is 16px so iOS does not zoom on focus.
- Turn ligatures off (`font-variant-ligatures: none`): `=>` and `!=` should look like what Claude typed.

## Glyphs

There is no icon set. Use these Unicode glyphs, always in the colour of their meaning:

| Glyph | Meaning |
| --- | --- |
| `>` | The person's prompt and messages (`prompt`) |
| `●` | A Claude message (`claude`) |
| `⏺` | A tool call; its colour shows state (`tool`, `ok`, `err`) |
| `⎿` | Output of the line above (`fg-muted`) |
| `✻` `✢` `✳` `✶` `✽` | Thinking / working spinner frames |
| `☐` `▸` `☒` | Todo: pending, active, done |
| `✓` `✗` `!` | Passed, failed, needs attention |
| `+` `-` | Added, removed |
| `⎇` | Git branch |
| `※` | System note |
| `│` | Separator in the status line |

Glyphs are decoration for sighted readers: mark them `aria-hidden="true"` and put the state in words (`aria-label`, visible text or both).

## Layout and spacing

- Spacing is a 4px grid: `space-1` 4, `space-2` 8, `space-3` 12, `space-4` 16, `space-6` 24, `space-8` 32.
- Phones get a `space-4` side gutter; from 720px it grows to `space-6`. Both add the device's safe-area inset. The transcript never exceeds `measure` (88ch).
- Transcript rows use a 2ch glyph gutter so messages, tool calls, todos and diffs share one text column.
- Turns are separated by `space-4`. No cards around turns: the user's turn gets a flat `surface` band, nothing else gets a box unless it is code, a diff or a question.
- Radii are small and square-leaning: `radius-none` for rows, `radius-sm` for buttons and badges, `radius-md` for panels. No pills.
- No drop shadows. Depth comes from `surface` steps and `line` borders.
- The prompt bar docks to the bottom on phones (`sg-prompt--docked`) and clears the home indicator.

## Motion

Only three things move: the block cursor blinks, a running tool's `⏺` blinks, and the spinner cycles its glyph. All three stop under `prefers-reduced-motion`. Motion uses `steps()`, never easing: terminals do not glide.

## Focus and states

- Keyboard focus is a 2px solid `focus` (orange) outline, offset 2px, on every control.
- Hover raises to `surface-raised`; press shifts the control down 1px.
- Disabled controls drop to 45% opacity and keep their place.
- A selected option gets `claude-tint`, a `claude` border and a `›` marker.

## Voice

Claude Code talks like a careful colleague at a terminal.

- Short, plain sentences. Say what happened and what comes next: "The test waits 200ms for the cookie. I'll replace the sleep with `waitFor`."
- First person for Claude ("I'll run the tests"), second person for the reader ("Do you want to run this command?").
- Sentence case everywhere. No exclamation marks, no emoji.
- Progress verbs end in an ellipsis: "Thinking…", "Editing login.spec.ts…".
- Numbers are exact and unit-bearing: `3.2s`, `42 passed`, `$0.42`, `59%`.
- Quote commands and paths exactly, in code style.

## Using it in code

Components are plain CSS classes with the `sg-` prefix in `components/bundle.css`; there is no JavaScript. Load the tokens CSS, then `bundle.css`, put `class="sg"` on the root (or rely on the `body` rule), and set `data-theme="phosphor"` or `data-theme="daylight"` on `<html>`. In the repository, `python3 design-system/scripts/build.py` writes both into `design-system/dist/segoy.css`.
