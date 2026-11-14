# Row

A tappable list row: a 2ch glyph gutter, a title, an optional secondary line and an optional trailing badge.

Markup: `ul.sg-list` of `<li>`, each holding `a.sg-row` (navigation) or `button.sg-row` (an action) with `span.sg-row__glyph` (aria-hidden), `span.sg-row__main` > `span.sg-row__title` + optional `span.sg-row__meta`, and optional `span.sg-row__trail` holding one or two Badges.

- The glyph says what the row is or what state it is in, coloured by meaning: `sg-row--warn` `!` waiting on the person, `--claude` `▸` Claude is working on it, `--ok` `✓` done, `--err` `✗` failed, `--tool` `⏺` a tool run, `--user` `>` something the person wrote, `--think` `✻` planning. No modifier and `›` for a plain navigation entry (settings).
- Title is `fg-strong` and wraps; it never truncates. The secondary line is `fg-muted`, small, and joins facts with ` · ` (ID, state, age).
- The whole row is the target and is at least `touch` high (48dp on Android). Rows are separated by `line` hairlines, never cards.
- The state in the glyph must also appear in words, in the meta line or the badge, because the glyph is hidden from screen readers.
- Do not put buttons inside a row. One row, one action.
