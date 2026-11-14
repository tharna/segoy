# Toggle

An on/off setting drawn as `[x]` / `[ ]`, where the whole row is the target.

Markup: `label.sg-toggle` wrapping `input.sg-toggle__input[type=checkbox]`, `span.sg-toggle__box`, `span.sg-toggle__main` (`sg-toggle__title` + optional `sg-toggle__meta`) and `span.sg-toggle__state`. The box and the state word are drawn by CSS from the checkbox, so they can never disagree with it. Use inside `ul.sg-list` for hairline separators.

- The native checkbox is kept (visually hidden), so screen readers announce "checked" / "not checked" and Space toggles it. On Android, use a toggleable row with `Role.Switch` and a state description.
- On: `[x]` in `claude` and the word `on` in `fg-strong`. Off: `[ ]` and `off` in `fg-muted`. The word repeats the state for anyone who cannot tell the boxes apart.
- The title says what is on when checked ("Pause the pipeline"), not a question.
- The row is at least `touch` high (48dp on Android). Focus draws the `focus` outline around the whole row.
- A disabled toggle stays visible at 45% opacity; its meta line says why.
- A toggle applies at once. If a change needs confirming, open a Sheet instead.
