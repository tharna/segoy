# Field

A labelled text input for settings and free-text answers; single line or multi line.

Markup: `div.sg-field` > `label.sg-field__label[for]`, then `input.sg-field__input` or `textarea.sg-field__input` with a matching `id`, then an optional `span.sg-field__hint` linked by `aria-describedby`. Add `sg-field--error` and `aria-invalid="true"` for a validation error.

- Use the Prompt for the main message to Claude. Field is for everything else: settings, names, a free-text answer under a Permission box.
- The label is always visible, above the input, in the uppercase `text-label` style. A placeholder is an example, never the label.
- The input is 16px (no iOS zoom), at least `touch` high (48dp on Android), `bg` ground with a `line-strong` border; the text cursor is `claude`. A textarea starts two rows tall and grows with its content.
- Focus is the standard 2px `focus` outline.
- Hints are `fg-muted`. An error replaces the hint, turns it and the border `err`, and starts with `✗`. Error text says how to fix it ("Use a number from 5 to 1440.").
- The consumer provides `id`s, the label, validation and the value.
