# Segoy design system

A terminal-style, mobile-friendly design system for Claude Code interfaces. Green on black by default (`phosphor` theme), a light `daylight` theme, and one colour per meaning, with orange reserved for Claude.

- `project/README.md` — the brand book: colour meanings, type, glyphs, layout, voice.
- `project/tokens.json` — all tokens (colours per theme, type, spacing, radius, touch sizes).
- `project/components/bundle.css` — the components as plain CSS classes (`sg-` prefix).
- `project/components/<Name>/` — guidelines (`README.md`) and a live preview (`preview.html`) per component.
- `dist/segoy.css` — tokens + components in one file, built by `python3 design-system/scripts/build.py` (also checks WCAG contrast in both themes; `--check` only checks).

Use it: link `dist/segoy.css`, set `<html data-theme="phosphor">` (or `daylight`), and use the classes shown in the previews.
