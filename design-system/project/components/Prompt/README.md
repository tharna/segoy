# Prompt

The input bar where the person writes to Claude: a green `>` caret, a growing textarea, and the Send button.

Markup: a `form.sg-prompt` holding `span.sg-prompt__caret`, `textarea.sg-prompt__input` with a visually hidden `<label>`, and a `sg-btn--primary` submit. Add `sg-prompt--docked` to stick it to the bottom of the screen; it clears the phone's home indicator with `env(safe-area-inset-bottom)`.

- The consumer provides the textarea's `id`, its label text and the submit handler.
- The input is 16px so iOS does not zoom when it is focused. Do not shrink it.
- The caret is `prompt` green: green means the person, orange means Claude. The text cursor inside the field is `claude` orange because Claude is about to read it.
- Put mode and shortcut hints in `sg-prompt__hint` below the bar, in `fg-muted`; only the active mode name takes `claude`.
- The bar's border turns `prompt` on focus. It is at least `prompt-height` tall.
