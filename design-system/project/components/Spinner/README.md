# Spinner

A cycling star glyph with a verb, shown while Claude thinks or works.

Markup: `div.sg-spin[role=status]` with an empty `span.sg-spin__glyph`, the verb, and an optional `span.sg-spin__meta` (elapsed time, tokens, how to interrupt).

- Default is `think` violet: reasoning that has no output yet. `sg-spin--work` is `claude` orange: Claude is producing something.
- The verb is a present participle ending in an ellipsis: "Thinking…", "Editing login.spec.ts…".
- The glyph steps through `· ✢ ✳ ✶ ✻ ✽`; with reduced motion it stays on `✻`.
- Always say how to stop it in the meta text.
