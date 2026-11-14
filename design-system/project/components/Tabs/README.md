# Tabs

Bottom navigation written as terminal text: `capture │ inbox !2 │ pipeline 5 │ activity`.

Markup: `nav.sg-tabs` (with an `aria-label`) of `a.sg-tab` or `button.sg-tab`, each holding `span.sg-tab__label` and an optional `span.sg-tab__count`. Mark the current tab with `aria-current="page"`. Add `sg-tabs--docked` to stick the bar to the bottom; it pads itself for the home indicator.

- Two to five tabs, one lowercase word each. Labels never wrap; on a narrow screen they truncate with an ellipsis, so keep them short.
- The current tab is `claude` and bold, with a 2px `claude` bar along its top edge. The bar is the second signal besides colour. Other tabs are `fg-muted`.
- Tabs share the bar's full width in proportion to their labels, so a longer label never truncates while a short one has spare room. Each is at least `touch` high and wide (48dp on Android).
- A count is plain text in `fg` after the label. When the items need the person to act, use `sg-tab__count--warn`: it turns `warn`, bold, and gets a `!` prefix. Give the count an `aria-label` in words ("2 waiting on you").
- Separators (`│`, `line-strong`) are drawn by CSS and hidden from screen readers. Do not type them.
- The consumer provides the destinations and keeps `aria-current` in sync.
