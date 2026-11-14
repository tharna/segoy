# TodoList

Claude's working plan as a checklist: done, in progress, and still to do.

Markup: `ul.sg-todo` of `<li>`; add `is-done` or `is-active`. The glyphs are drawn by CSS.

- Pending: `☐` in `fg-muted`, text `fg`. Active: `▸`, the whole row `claude` and bold; only one at a time. Done: `☒` in `ok`, text `fg-muted` and struck through.
- Items are short imperative phrases ("Run the login suite 20 times").
- Nest it in a Claude message body so it sits on the message's text column.
