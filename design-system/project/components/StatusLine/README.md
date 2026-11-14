# StatusLine

The one-line footer with session facts: model, branch, context left, cost, anything waiting.

Markup: `footer.sg-status` of `span.sg-status__item` (label text plus a `<b>` value), separated by `span.sg-status__sep` (`│`).

- Labels are `fg-muted`, values `fg`. Two items have fixed colours: `--model` value is `claude`, `--branch` value is `prompt`. `--warn` makes a value `warn` and starts with `!`.
- Items never break internally; the line wraps between items, and the separators disappear under 480px.
- Keep it to five items or fewer. It is a glance, not a dashboard.
