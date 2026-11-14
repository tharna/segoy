# Badge

A small uppercase label that names the kind or state of a thing in one colour.

Markup: `<span class="sg-badge sg-badge--ok">✓ Passed</span>`.

- Pick the modifier by meaning, never by looks: `--claude` for Claude's work, `--tool` for a tool name, `--ok` / `--err` / `--warn` for outcomes, `--think` for planning. No modifier is neutral (branch names, counts).
- Status badges always start with their glyph (`✓`, `✗`, `!`) so the state survives colour blindness and greyscale.
- One or two words. Badges do not wrap and are not buttons.
