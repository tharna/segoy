# Sheet

A panel that slides up from the bottom for an option list or a confirmation, over a dimmed page.

Markup: `div.sg-scrim` (fixed, dims the page) > `section.sg-sheet[role=dialog][aria-modal=true][aria-labelledby]` holding `span.sg-sheet__grip`, `div.sg-sheet__head` (`h2.sg-sheet__title` + a ghost Close button), a body (`div.sg-sheet__body` for text, or a `ul.sg-perm__opts` of `sg-option` rows), and `div.sg-sheet__actions`.

- Ground is `surface-raised` with a `line-strong` top border and `radius-md` top corners. No shadow: the scrim (`bg` at 72%) and the border separate it from the page.
- The grip `────` is decoration. Dragging down to dismiss is an accelerator only; the Close button (and `esc`, and Android back) always does the same.
- Options reuse the Permission box's `sg-option` rows: full width, numbered, at least `touch` high.
- At most one primary action, last in the actions row. A destructive confirmation uses `sg-btn--danger` and names what will be lost.
- On screens 720px and wider the sheet centres as a dialog up to 60ch wide.
- The consumer moves focus into the sheet on open, traps it there, and returns it to the opener on close. It pads for the home indicator itself.
