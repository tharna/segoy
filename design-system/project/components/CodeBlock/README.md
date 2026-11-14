# CodeBlock

A fenced code sample with a language bar and a Copy button; it scrolls sideways instead of wrapping.

Markup: `figure.sg-code` > `figcaption.sg-code__bar` (language and file name, a ghost Copy button) + `pre > code`. Highlighter output maps to six classes: `.k` keyword (`claude`), `.s` string (`ok`), `.f` function (`tool`), `.n` number or constant (`think`), `.t` type or import path (`path`), `.c` comment (`fg-muted`, italic). Plain identifiers stay `fg`.

- The consumer provides the highlighted HTML and the copy handler (`navigator.clipboard.writeText`, falling back to selecting the text).
- Syntax colour reuses the meaning palette on purpose: no second set of hues to learn.
- Copy grows to the full `touch` height on touch screens.
