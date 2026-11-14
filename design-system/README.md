# Segoy design system

A terminal-style, mobile-friendly design system for Claude Code interfaces. Green on black by default (`phosphor` theme), a light `daylight` theme, and one colour per meaning, with orange reserved for Claude.

- `project/README.md` — the brand book: colour meanings, type, glyphs, layout, voice.
- `project/tokens.json` — all tokens (colours per theme, type, spacing, radius, touch sizes).
- `project/components/bundle.css` — the components as plain CSS classes (`sg-` prefix).
- `project/components/<Name>/` — guidelines (`README.md`) and a live preview (`preview.html`) per component.
- `dist/segoy.css` — tokens + components in one file, for the web.
- `dist/android/SegoyTokens.kt` — the tokens for Jetpack Compose (colours per theme, type in `sp`, spacing, radius and sizes in `dp`). Generated; vendor it, don't edit it.

Both `dist/` files are built by `python3 design-system/scripts/build.py`, which also checks WCAG contrast in both themes (`--check` only checks). Commit them together with the change to `tokens.json` or `bundle.css`.

Use it: link `dist/segoy.css`, set `<html data-theme="phosphor">` (or `daylight`), and use the classes shown in the previews.
