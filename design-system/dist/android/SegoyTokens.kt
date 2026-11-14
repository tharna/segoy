// Segoy — generated from design-system/project/tokens.json by design-system/scripts/build.py.
// Do not edit by hand: change tokens.json and rebuild.
@file:Suppress("unused", "MemberVisibilityCanBePrivate")

package segoy.tokens

import androidx.compose.runtime.Immutable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.TextUnit
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.em
import androidx.compose.ui.unit.sp

/** One theme's colours. Every field is a meaning token; see the brand book for usage. */
@Immutable
data class SegoyColors(
    val id: String,
    val isDark: Boolean,
    /** Page and terminal background. The ground every other token is checked against. */
    val bg: Color,
    /** Panels set off from the page: tool output, code blocks, the permission box. */
    val surface: Color,
    /** The prompt input bar, hovered rows, pressed secondary buttons. */
    val surfaceRaised: Color,
    /** Hairline dividers and decorative frames. Never the only border of a control. */
    val line: Color,
    /** Borders of controls (inputs, secondary buttons). At least 3:1 on bg and surface. */
    val lineStrong: Color,
    /** Body text, the green on black. Reads on bg, surface and surface-raised in both themes. */
    val fg: Color,
    /** Headings and emphasised text on bg, surface and surface-raised. */
    val fgStrong: Color,
    /** Secondary text: timestamps, hints, line numbers, tool output summaries. 4.5:1 on bg, surface and surface-raised. */
    val fgMuted: Color,
    /** Orange. Claude's own voice: the assistant bullet, the brand, primary actions and the cursor. Text on bg, surface and surface-raised. */
    val claude: Color,
    /** Text and glyphs on a claude fill (primary buttons). */
    val onClaude: Color,
    /** Faint orange ground behind a selected row or the active option. claude and fg read on it. */
    val claudeTint: Color,
    /** The person's input: the > caret and their typed message. Text on bg and surface-raised. */
    val prompt: Color,
    /** Cyan. Tool calls: Bash, Read, Edit, Grep and their names. Text on bg and surface. */
    val tool: Color,
    /** Ground of a tool badge. tool reads on it. */
    val toolTint: Color,
    /** Blue. File paths, URLs and links, always underlined when interactive. Text on bg and surface. */
    val path: Color,
    /** Violet. Thinking, planning and other meta activity that is not output. Text on bg and surface. */
    val think: Color,
    /** Success and added lines (+). Always paired with a glyph (✓ or +). Text on bg, surface and ok-tint. */
    val ok: Color,
    /** Ground of added diff lines and success badges. */
    val okTint: Color,
    /** Errors, denials and removed lines (-). Always paired with a glyph (✗ or -). Text on bg, surface and err-tint. */
    val err: Color,
    /** Ground of removed diff lines and error badges. */
    val errTint: Color,
    /** Yellow. Waiting on the person: permission requests, destructive commands, rate limits. Text on bg, surface and warn-tint. */
    val warn: Color,
    /** Ground of the permission box and warning badges. */
    val warnTint: Color,
    /** Keyboard focus ring: 2px solid, 2px offset. Orange so it is never confused with a status colour. */
    val focus: Color,
)

/** Font roles. Apps bundle the font files and map each role to a FontFamily. */
enum class SegoyFont(val familyName: String) {
    Mono("JetBrains Mono"),
    Display("VT323"),
}

@Immutable
data class SegoyTextStyle(
    val font: SegoyFont,
    val fontSize: TextUnit,
    val lineHeight: TextUnit,
    val fontWeight: FontWeight,
    val letterSpacing: TextUnit = TextUnit.Unspecified,
    val uppercase: Boolean = false,
)

object SegoyTokens {
    const val VERSION: Int = 1

    /** Phosphor (dark, default) */
    val Phosphor: SegoyColors = SegoyColors(
        id = "phosphor",
        isDark = true,
        bg = Color(0xFF070A08),
        surface = Color(0xFF0D130F),
        surfaceRaised = Color(0xFF141C17),
        line = Color(0xFF22322A),
        lineStrong = Color(0xFF4F7A5D),
        fg = Color(0xFFA3F0B5),
        fgStrong = Color(0xFFE4FFEB),
        fgMuted = Color(0xFF76A684),
        claude = Color(0xFFFF9A3C),
        onClaude = Color(0xFF1F0E00),
        claudeTint = Color(0xFF2B1906),
        prompt = Color(0xFF5CFF8F),
        tool = Color(0xFF5CD6E6),
        toolTint = Color(0xFF0B2328),
        path = Color(0xFF86BDFF),
        think = Color(0xFFC6A6FF),
        ok = Color(0xFF4FE07F),
        okTint = Color(0xFF0E2A17),
        err = Color(0xFFFF7070),
        errTint = Color(0xFF301214),
        warn = Color(0xFFFFD84A),
        warnTint = Color(0xFF2B2408),
        focus = Color(0xFFFF9A3C),
    )

    /** Daylight (light) */
    val Daylight: SegoyColors = SegoyColors(
        id = "daylight",
        isDark = false,
        bg = Color(0xFFF3F6F2),
        surface = Color(0xFFE8EEE8),
        surfaceRaised = Color(0xFFFFFFFF),
        line = Color(0xFFCDD8CE),
        lineStrong = Color(0xFF6F8A76),
        fg = Color(0xFF123A20),
        fgStrong = Color(0xFF03140A),
        fgMuted = Color(0xFF46604D),
        claude = Color(0xFFA84500),
        onClaude = Color(0xFFFFFFFF),
        claudeTint = Color(0xFFFBE4D1),
        prompt = Color(0xFF0A7330),
        tool = Color(0xFF00687A),
        toolTint = Color(0xFFD4EEF1),
        path = Color(0xFF1A56B0),
        think = Color(0xFF6338BD),
        ok = Color(0xFF1A7438),
        okTint = Color(0xFFD9F1E0),
        err = Color(0xFFB8262A),
        errTint = Color(0xFFFBE0DF),
        warn = Color(0xFF7F5C00),
        warnTint = Color(0xFFF7EDC6),
        focus = Color(0xFFA84500),
    )

    /** All themes by id; the first is the default. */
    val themes: Map<String, SegoyColors> = linkedMapOf(
        "phosphor" to Phosphor,
        "daylight" to Daylight,
    )

    object Type {
        /** Brand name and splash screens only. One per screen. */
        val textDisplay: SegoyTextStyle = SegoyTextStyle(font = SegoyFont.Display, fontSize = 56.sp, lineHeight = 0.95.em, fontWeight = FontWeight(400))
        /** Screen and session titles. */
        val textTitle: SegoyTextStyle = SegoyTextStyle(font = SegoyFont.Mono, fontSize = 20.sp, lineHeight = 28.sp, fontWeight = FontWeight(700))
        /** Tool call headers, section headings inside a transcript. */
        val textHeading: SegoyTextStyle = SegoyTextStyle(font = SegoyFont.Mono, fontSize = 16.sp, lineHeight = 24.sp, fontWeight = FontWeight(700))
        /** Transcript messages and prompt input. 15px so it stays readable on a phone without zoom. */
        val textBody: SegoyTextStyle = SegoyTextStyle(font = SegoyFont.Mono, fontSize = 15.sp, lineHeight = 24.sp, fontWeight = FontWeight(400))
        /** Code blocks, diffs and tool output. */
        val textCode: SegoyTextStyle = SegoyTextStyle(font = SegoyFont.Mono, fontSize = 14.sp, lineHeight = 22.sp, fontWeight = FontWeight(400))
        /** Secondary lines, the status line, hints. */
        val textSmall: SegoyTextStyle = SegoyTextStyle(font = SegoyFont.Mono, fontSize = 13.sp, lineHeight = 20.sp, fontWeight = FontWeight(400))
        /** Uppercase badges and field labels. Never running text. */
        val textLabel: SegoyTextStyle = SegoyTextStyle(font = SegoyFont.Mono, fontSize = 11.sp, lineHeight = 16.sp, fontWeight = FontWeight(700), letterSpacing = 0.08.em, uppercase = true)
    }

    object Spacing {
        /** Gap between a glyph and its text, badge padding. */
        val space1 = 4.dp
        /** Inline gaps, padding inside code lines and list rows. */
        val space2 = 8.dp
        /** Padding inside panels on phones. */
        val space3 = 12.dp
        /** Side gutter on phones, panel padding on desktop, gap between transcript turns. */
        val space4 = 16.dp
        /** Gap between sections; side gutter on wide screens. */
        val space6 = 24.dp
        /** Large separations: top of a screen, around the splash. */
        val space8 = 32.dp
    }

    object Radius {
        /** Default. Transcript rows, diff lines, the status line: a terminal has square cells. */
        val radiusNone = 0.dp
        /** Badges and buttons: just enough to soften on high-density screens. */
        val radiusSm = 2.dp
        /** Panels: code blocks, the permission box, the prompt bar. */
        val radiusMd = 4.dp
    }

    object Size {
        /** Minimum height and width of any tappable control on the web: buttons, options, toggles, rows, tabs. */
        val touch = 44.dp
        /** Minimum height and width of any tappable control on Android (48dp): the 44px minimum rounded up to the platform guideline. */
        val touchAndroid = 48.dp
        /** Height of the docked prompt bar on phones. */
        val promptHeight = 52.dp
        // measure = 88ch: no Android equivalent, not exported
    }
}
