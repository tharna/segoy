# ToolCall

A tool invocation in the transcript: `⏺ Name(argument)` with its output indented under a `⎿` elbow.

Markup: `div.sg-tool` with `span.sg-tool__glyph`, `div.sg-tool__head` (`span.sg-tool__name` + `span.sg-tool__arg`) and an optional `div.sg-tool__out` holding a `<pre>`. Use `details.sg-tool` with a `summary` when the output should collapse.

- The tool name is always `tool` cyan. Arguments are `fg`; file paths inside them are `sg-path`.
- The glyph carries the state: plain `tool` while queued, `is-running` blinks, `is-ok` turns `ok`, `is-err` turns `err`. Give it an `aria-label` with the state in words.
- Output is `fg-muted` at the small size and scrolls sideways inside its own box; failing lines take `is-err` and start with `✗`.
- Summarise long output in one line ("Read 84 lines") and let the person expand it.
