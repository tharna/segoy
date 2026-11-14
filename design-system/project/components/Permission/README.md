# Permission

The box Claude shows when it needs the person's approval before a tool runs; the only `warn` panel in the system.

Markup: `section.sg-perm` with `sg-perm__title`, the exact command or file in `pre.sg-perm__cmd`, the question in `sg-perm__q`, and a `ul.sg-perm__opts` of `button.sg-option` rows (number key + label).

- Yellow means "waiting on you". Use it for nothing else, so a glance at a long transcript finds the open question.
- Show the exact command, unabridged, in the `bg` well. It scrolls sideways rather than wrapping so the person can read it verbatim.
- Options are full-width 44px rows numbered 1–3; the number key works on desktop, a tap works on a phone. The highlighted option gets `claude-tint`, a `claude` border and a `›` marker.
- The denying option is last and its label is `err`. Approval options state their scope in words ("don't ask again for npm test").
