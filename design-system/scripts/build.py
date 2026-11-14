#!/usr/bin/env python3
"""Build the Segoy design system outputs from project/tokens.json and check contrast.

Writes:
  dist/segoy.css                tokens + project/components/bundle.css, for the web
  dist/android/SegoyTokens.kt   tokens for Jetpack Compose (colours per theme,
                                type in sp, spacing / radius / sizes in dp)

Usage: python3 design-system/scripts/build.py [--check]
  --check  only run the contrast check (exit 1 on any failure), write nothing
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


# ---------- Android (Jetpack Compose) ----------

KT_PACKAGE = "segoy.tokens"


def camel(name):
    parts = re.split(r"[-_.]", name)
    return parts[0] + "".join(p[:1].upper() + p[1:] for p in parts[1:])


def pascal(name):
    c = camel(name)
    return c[:1].upper() + c[1:]


def kt_color(hex_):
    h = hex_.lstrip("#").lower()
    if len(h) in (3, 4):
        h = "".join(c * 2 for c in h)
    if len(h) == 6:
        h += "ff"
    if not re.fullmatch(r"[0-9a-f]{8}", h):
        raise ValueError(f"Android export supports hex colours only, got {hex_!r}")
    return f"Color(0x{h[6:8]}{h[0:6]})".upper().replace("COLOR(0X", "Color(0x")


def kt_num(x):
    x = float(x)
    return str(int(x)) if x == int(x) else repr(x)


def kt_length(v, unit):
    """'16px' / 16 / '0' -> '16.dp'; '0.08em' -> '0.08.em'; None for units Android has no equivalent for."""
    if isinstance(v, (int, float)):
        return f"{kt_num(v)}.{unit}"
    m = re.fullmatch(r"(-?[0-9.]+)(px|em)?", str(v).strip())
    if not m:
        return None
    n, u = m.groups()
    return f"{kt_num(n)}.em" if u == "em" else f"{kt_num(n)}.{unit}"


def kt_line_height(v):
    if isinstance(v, (int, float)) or re.fullmatch(r"[0-9.]+", str(v)):
        return f"{kt_num(v)}.em"  # unitless multiplier
    return kt_length(v, "sp")


def font_name(stack):
    first = stack.split(",")[0].strip().strip('"\'')
    return first


def kotlin(tokens):
    themes = tokens["color"]["themes"]
    first = themes[0]["id"]
    colors = {t["name"]: t["value"] for t in tokens["color"]["tokens"]}
    names = [t["name"] for t in tokens["color"]["tokens"]]
    o = []
    o.append(f"// {tokens['name']} — generated from design-system/project/tokens.json by design-system/scripts/build.py.")
    o.append("// Do not edit by hand: change tokens.json and rebuild.")
    o.append("@file:Suppress(\"unused\", \"MemberVisibilityCanBePrivate\")")
    o.append("")
    o.append(f"package {KT_PACKAGE}")
    o.append("")
    o.append("import androidx.compose.runtime.Immutable")
    o.append("import androidx.compose.ui.graphics.Color")
    o.append("import androidx.compose.ui.text.font.FontWeight")
    o.append("import androidx.compose.ui.unit.TextUnit")
    o.append("import androidx.compose.ui.unit.dp")
    o.append("import androidx.compose.ui.unit.em")
    o.append("import androidx.compose.ui.unit.sp")
    o.append("")
    o.append("/** One theme's colours. Every field is a meaning token; see the brand book for usage. */")
    o.append("@Immutable")
    o.append("data class SegoyColors(")
    o.append("    val id: String,")
    o.append("    val isDark: Boolean,")
    for t in tokens["color"]["tokens"]:
        o.append(f"    /** {t.get('usage', '')} */")
        o.append(f"    val {camel(t['name'])}: Color,")
    o.append(")")
    o.append("")
    o.append("/** Font roles. Apps bundle the font files and map each role to a FontFamily. */")
    o.append("enum class SegoyFont(val familyName: String) {")
    fams = tokens["type"]["families"]
    o.append(",\n".join(f"    {pascal(k)}(\"{font_name(v)}\")" for k, v in fams.items()) + ",")
    o.append("}")
    o.append("")
    o.append("@Immutable")
    o.append("data class SegoyTextStyle(")
    o.append("    val font: SegoyFont,")
    o.append("    val fontSize: TextUnit,")
    o.append("    val lineHeight: TextUnit,")
    o.append("    val fontWeight: FontWeight,")
    o.append("    val letterSpacing: TextUnit = TextUnit.Unspecified,")
    o.append("    val uppercase: Boolean = false,")
    o.append(")")
    o.append("")
    o.append("object SegoyTokens {")
    o.append(f"    const val VERSION: Int = {int(tokens.get('version', 1))}")
    o.append("")
    for th in themes:
        tid = th["id"]
        bg = resolve(colors, "bg", tid, first) if "bg" in colors else "#000000"
        o.append(f"    /** {th['name']} */")
        o.append(f"    val {pascal(tid)}: SegoyColors = SegoyColors(")
        o.append(f"        id = \"{tid}\",")
        o.append(f"        isDark = {'true' if lum(bg) < 0.5 else 'false'},")
        for n in names:
            o.append(f"        {camel(n)} = {kt_color(resolve(colors, n, tid, first))},")
        o.append("    )")
        o.append("")
    o.append("    /** All themes by id; the first is the default. */")
    o.append("    val themes: Map<String, SegoyColors> = linkedMapOf(")
    o.append("".join(f"        \"{th['id']}\" to {pascal(th['id'])},\n" for th in themes).rstrip("\n"))
    o.append("    )")
    o.append("")
    o.append("    object Type {")
    upper_styles = {"text-label"}
    for g in tokens["type"]["groups"]:
        for st in g["styles"]:
            fam = st.get("family", g["family"])
            args = [f"font = SegoyFont.{pascal(fam)}",
                    f"fontSize = {kt_length(st['fontSize'], 'sp')}",
                    f"lineHeight = {kt_line_height(st['lineHeight'])}",
                    f"fontWeight = FontWeight({int(st['fontWeight'])})"]
            if "letterSpacing" in st:
                args.append(f"letterSpacing = {kt_length(st['letterSpacing'], 'sp')}")
            if st["name"] in upper_styles:
                args.append("uppercase = true")
            if st.get("usage"):
                o.append(f"        /** {st['usage']} */")
            o.append(f"        val {camel(st['name'])}: SegoyTextStyle = SegoyTextStyle({', '.join(args)})")
    o.append("    }")
    for fam, obj in (("spacing", "Spacing"), ("radius", "Radius"), ("size", "Size")):
        o.append("")
        o.append(f"    object {obj} {{")
        for t in tokens.get(fam, {}).get("tokens", []):
            v = kt_length(t["value"], "dp")
            if v is None or v.endswith(".em"):
                o.append(f"        // {t['name']} = {t['value']}: no Android equivalent, not exported")
                continue
            if t.get("usage"):
                o.append(f"        /** {t['usage']} */")
            o.append(f"        val {camel(t['name'])} = {v}")
        o.append("    }")
    o.append("}")
    return "\n".join(o) + "\n"


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
    (DIST / "android").mkdir(exist_ok=True)
    (DIST / "android" / "SegoyTokens.kt").write_text(kotlin(tokens))
    print(f"\nwrote {DIST / 'segoy.css'}\nwrote {DIST / 'android' / 'SegoyTokens.kt'}"
          + (f"\n{failed} contrast failures" if failed else ""))
    sys.exit(1 if failed else 0)


if __name__ == "__main__":
    main()
