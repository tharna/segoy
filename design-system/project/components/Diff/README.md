# Diff

A unified diff of one file: a header with the path and `+n -n` counts, then numbered lines that scroll sideways together.

Markup: `div.sg-diff` > `div.sg-diff__file` (path + `sg-diff__stat`) and `div.sg-diff__body` holding `div.sg-diff__line--add|del|ctx` rows of three spans: number, sign, text.

- Added lines: `ok-tint` ground, `ok` `+`. Removed: `err-tint` ground, `err` `-`. Context: `fg-muted`. The `+` and `-` signs stay visible so the diff reads without colour.
- Code text stays `fg` on both tints; only the sign carries the status colour.
- Lines never wrap: the body scrolls horizontally on phones, the page does not.
- Show a few context lines on each side, not the whole file.
