# Splash

The app icon and the splash screen: the only places outside the brand cover where the display face (`font-display`, VT323) appears.

## App icon

- The mark is a `prompt` green `>` set in the display face, followed by a `claude` orange block cursor, on `bg` (phosphor). The person types, Claude answers: the two meaning colours, nothing else.
- Always the phosphor colours, in both themes: the icon sits on a launcher, not inside the app.
- Square, no border, no gradient, no shadow. On Android, build an adaptive icon: background layer `bg`, foreground layer the mark inside the central 66dp safe zone of the 108dp canvas. For the themed (monochrome) icon, draw `>` and the cursor in one ink and let the launcher tint it.
- At 24px and below, keep the mark but drop nothing: `>` and the cursor stay legible because the display face is a pixel face. Do not add the app name to the icon.
- Markup for web previews: put `data-theme="phosphor"` on the icon or its container so it keeps the phosphor colours inside a daylight page, then `span.sg-icon` (set `width` and `font-size` to about 0.75 of the width) holding `>` and `span.sg-icon__cursor`.

## Splash

- `div.sg-splash` on `bg`: the app name in lowercase in `sg-splash__name` (display face, 56px / 56sp), bottom-left, and one status line under it in `sg-splash__line` (`fg-muted`), optionally ending with the blinking `sg-cursor`.
- One display-face element per screen. The status line is in the mono face.
- The splash follows the current theme (phosphor or daylight), unlike the icon.
- Show it only while the app starts or does a first sync. It never carries tips, version notes or a primary action.
- With reduced motion (Android: "remove animations") the cursor stays solid.
