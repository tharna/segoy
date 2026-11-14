# Empty

A one-line empty state, `※ nothing waiting on you`, shown where a list has no items.

Markup: `div.sg-empty` > `p.sg-empty__text`, plus an optional `button.sg-btn.sg-empty__action`. The `※` glyph is drawn by CSS on the same 2ch gutter as transcript rows.

- One lowercase line in `fg-muted` that states the fact ("nothing waiting on you", "no runs today"). No illustrations, no jokes, no exclamation marks.
- Add one secondary button only when there is an obvious next step ("Capture one"). Never a primary action.
- An empty state is good news or neutral. If loading failed, show an error row (`sg-row--err`) with what went wrong instead.
