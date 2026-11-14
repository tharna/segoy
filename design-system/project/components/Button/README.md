# Button

A bracketed `[ Label ]` button that meets the 44px touch target while looking like terminal text.

Markup: `<button class="sg-btn" type="button">Label</button>`. The brackets are drawn by CSS; do not type them.

| Modifier | Use |
| --- | --- |
| `sg-btn--primary` | The one action that moves the session forward: Send, Approve, Continue. `claude` fill, `on-claude` text. At most one per view. |
| (none) | Secondary actions: Retry, Copy, Open file. `line-strong` border. |
| `sg-btn--danger` | Stop a running turn, discard changes, deny. `err` text and border. |
| `sg-btn--ghost` | Tertiary actions inside dense rows (Cancel). No brackets, no border. |

- Labels are verbs, sentence case, one or two words. Add a `<kbd>` hint (`⏎`, `esc`, `⌃C`) when a key does the same thing.
- Never make a button narrower than `touch`, even with an icon-only glyph.
- Disabled buttons keep their place; say why nearby in `fg-muted`.
