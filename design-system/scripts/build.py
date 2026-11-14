#!/usr/bin/env python3
"""Build dist/segoy.css from project/tokens.json + project/components/bundle.css,
and check text/background contrast for every theme.

Usage: python3 design-system/scripts/build.py [--check]
"""
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PROJECT = ROOT / "project"
DIST = ROOT / "dist"

# (text token, ground token, minimum ratio)
PAIRS = [
    *[(t, g, 4.5) for t in ("fg", "fg-strong", "fg-muted", "claude", "prompt")
      for g in ("bg", "surface", "surface-raised")],
    *[(t, g, 4.5) for t in ("tool", "path", "think", "ok", "err", "warn")
      for g in ("bg", "surface")],
    ("on-claude", "claude", 4.5),
    ("claude", "claude-tint", 4.5), ("fg", "claude-tint", 4.5),
    ("tool", "tool-tint", 4.5),
    ("ok", "ok-tint", 4.5), ("err", "err-tint", 4.5), ("warn", "warn-tint", 4.5),
    ("fg", "ok-tint", 4.5), ("fg", "err-tint", 4.5), ("fg", "warn-tint", 4.5),
    ("line-strong", "bg", 3.0), ("line-strong", "surface", 3.0),
    ("focus", "bg", 3.0), ("focus", "surface-raised", 3.0),
]


def lum(hex_):
    h = hex_.lstrip("#")
    if len(h) == 3:
        h = "".join(c * 2 for c in h)
    out = []
    for i in (0, 2, 4):
        c = int(h[i:i + 2], 16) / 255
        out.append(c / 12.92 if c <= 0.03928 else ((c + 0.055) / 1.055) ** 2.4)
    r, g, b = out
    return 0.2126 * r + 0.7152 * g + 0.0722 * b


def ratio(a, b):
    la, lb = sorted((lum(a), lum(b)), reverse=True)
    return (la + 0.05) / (lb + 0.05)


def resolve(colors, name, theme, first):
    v = colors[name]
    v = v if isinstance(v, str) else v.get(theme, v[first])
    m = re.fullmatch(r"\{(.+)\}", v)
    return resolve(colors, m.group(1), theme, first) if m else v


def check(tokens):
    themes = [t["id"] for t in tokens["color"]["themes"]]
    colors = {t["name"]: t["value"] for t in tokens["color"]["tokens"]}
    failed = 0
    for theme in themes:
        for fg, bg, need in PAIRS:
            r = ratio(resolve(colors, fg, theme, themes[0]), resolve(colors, bg, theme, themes[0]))
            flag = "ok " if r >= need else "FAIL"
            failed += r < need
            print(f"{flag} {theme:9} {fg:12} on {bg:15} {r:5.2f} (need {need})")
    return failed


def css_value(v):
    m = re.fullmatch(r"\{(.+)\}", v)
    return f"var(--{m.group(1)})" if m else v


def tokens_css(tokens):
    themes = [t["id"] for t in tokens["color"]["themes"]]
    first = themes[0]
    out = [f"/* {tokens['name']} — generated from tokens.json */"]
    out.append(f':root, [data-theme="{first}"] {{')
    for t in tokens["color"]["tokens"]:
        v = t["value"] if isinstance(t["value"], str) else t["value"][first]
        out.append(f"  --{t['name']}: {css_value(v)};")
    out.append("  color-scheme: dark;\n}")
    for theme in themes[1:]:
        out.append(f'[data-theme="{theme}"] {{')
        for t in tokens["color"]["tokens"]:
            if isinstance(t["value"], dict) and theme in t["value"]:
                out.append(f"  --{t['name']}: {css_value(t['value'][theme])};")
            elif isinstance(t["value"], str) and t["value"].startswith("{"):
                out.append(f"  --{t['name']}: {css_value(t['value'])};")
        out.append("  color-scheme: light;\n}")
    out.append(":root {")
    for fam in ("spacing", "radius", "size"):
        for t in tokens.get(fam, {}).get("tokens", []):
            out.append(f"  --{t['name']}: {t['value']};")
    for key, stack in tokens["type"]["families"].items():
        out.append(f"  --font-{key}: {stack};")
    out.append("}")
    for g in tokens["type"]["groups"]:
        for s in g["styles"]:
            fam = s.get("family", g["family"])
            rules = [f"font-family: var(--font-{fam})", f"font-size: {s['fontSize']}",
                     f"line-height: {s['lineHeight']}", f"font-weight: {s['fontWeight']}"]
            if "letterSpacing" in s:
                rules.append(f"letter-spacing: {s['letterSpacing']}")
            out.append(f".{s['name']} {{ {'; '.join(rules)}; }}")
    return "\n".join(out) + "\n"


def main():
    tokens = json.loads((PROJECT / "tokens.json").read_text())
    failed = check(tokens)
    if "--check" in sys.argv:
        sys.exit(1 if failed else 0)
    bundle = (PROJECT / "components" / "bundle.css").read_text()
    # @import must come first in a stylesheet
    imports = "\n".join(l for l in bundle.splitlines() if l.startswith("@import"))
    rest = "\n".join(l for l in bundle.splitlines() if not l.startswith("@import"))
    DIST.mkdir(exist_ok=True)
    (DIST / "segoy.css").write_text(imports + "\n" + tokens_css(tokens) + "\n" + rest + "\n")
    print(f"\nwrote {DIST / 'segoy.css'}" + (f"  ({failed} contrast failures)" if failed else ""))
    sys.exit(1 if failed else 0)


if __name__ == "__main__":
    main()
