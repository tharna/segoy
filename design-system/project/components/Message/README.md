# Message

One turn of the transcript: a one-character glyph gutter and a body that wraps on any screen width.

Markup: `div.sg-msg.sg-msg--<who>` with `span.sg-msg__glyph` (aria-hidden) and `div.sg-msg__body` holding paragraphs, lists, code and other components.

| Who | Glyph | Colour |
| --- | --- | --- |
| `--user` | `>` | glyph `prompt`, text `fg-strong` on a `surface` band so the person's words are easy to find while scrolling |
| `--claude` | `●` | glyph `claude`, text `fg` |
| `--system` | `※` | all `fg-muted`, small size; compaction, session start, hook output |

- The gutter is exactly 2ch so tool calls, todos and diffs nested underneath line up on the same column.
- Inline `code` gets a `surface` ground and `fg-strong`. File paths are `sg-path` links.
- Long words and URLs break anywhere (`overflow-wrap: anywhere`) so a phone never scrolls sideways.
