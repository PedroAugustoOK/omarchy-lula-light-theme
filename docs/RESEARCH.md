# RESEARCH — Lula Light

Engineering notes for the **light** sibling of Lula.
Verified on **Omarchy 4.0.5-1** and re-audited on **4.0.6-1** (2026-10-21).
Dark-sibling mechanics (staging flow, deny list, template resolution,
Plymouth, OWE) are documented in the
[Lula (dark) repo's RESEARCH.md](https://github.com/PedroAugustoOK/omarchy-lula-theme/blob/main/RESEARCH.md);
this file only registers what is light-specific.

## 1. Light-mode conventions (read from the official themes)

Studied on-disk: `/usr/share/omarchy/themes/catppuccin-latte/colors.toml`
and `/usr/share/omarchy/themes/flexoki-light/colors.toml`.

| Convention | Official behavior | Lula Light follows it |
|---|---|---|
| `mode` | `"light"` | `"light"` (resolves `theme_type = light`; no `light.mode` side files exist) |
| `foreground` | **dark** ink on paper | `#32161C` |
| `bright_foreground` | == `foreground` | `#32161C` (identical) |
| `light_foreground` | slightly lighter secondary text | `#4B2B31` |
| `dark_foreground` | low-contrast gray for chrome only | `#8A6A71` |
| `dark_background` / `darker_background` | surfaces recede to *darker* tones | `#F0E5E8` / `#E7D9DC` |
| `lighter_background`| sits between `background` and `dark_background` | `#F3E9EC` |
| ANSI `bright_*` | same value as the base color or a slightly stronger sibling | slightly lightened siblings |
| `accent` | one saturated accent, pulled **darker** than its dark-theme twin because it sits on paper | `#B62A3E` (dark twin uses `#E63950`) |

Official light themes do **not** hold ANSI to ≥ 4.5:1 (catppuccin-latte's
green is ~2.8:1). Lula Light tightens this: every base ANSI color is
≥ 5.07:1; only its `bright_*` siblings and `dark_foreground` drop into the
4.13–4.4:1 chrome band, comparable to the official themes' weakest entries.

## 2. Measured contrast (WCAG 2.x relative-luminance formula)

Against `background #F9F2F4` (L = 0.905). The official
`omarchy dev theme-preview` prints **foreground/background = 15.02:1**;
the table below uses the same formula and reproduces its numbers exactly.

| Role | Key | Hex | Ratio |
|---|---|---|---|
| main text | `foreground`/`bright_foreground` | `#32161C` | **15.02:1** |
| secondary text | `light_foreground` | `#4B2B31` | **11.27:1** |
| chrome text | `dark_foreground` | `#8A6A71` | 4.35:1 |
| accent / red | `accent`/`red` | `#B62A3E` | **5.62:1** |
| `bright_red` | | `#C53344` | 4.84:1 |
| `yellow` / `bright_yellow` | | `#86600B` / `#876108` | 5.16:1 / 5.08:1 |
| `orange` | | `#A8491F` | 5.23:1 |
| `green` / `bright_green` | | `#2A7033` / `#2E7336` | 5.50:1 / 5.26:1 |
| `cyan` / `bright_cyan` | | `#0D6E75` / `#0F6E75` | 5.43:1 / 5.43:1 |
| `blue` / `bright_blue` | | `#24578D` / `#2E68A5` | 6.74:1 / 5.23:1 |
| `magenta` / (`purple`) | | `#A63E96` | 5.07:1 |
| `bright_magenta` | | `#B44FA6` | 4.13:1 |
| `brown` | | `#6B3D2A` | 8.18:1 |

Swap-check: `foreground #32161C` on `selection #EFDADE` keeps **12.43:1**;
`background` against `dark_background` is a **1.11:1** pair — adjacent
surfaces in a light theme are meant to be close, not to invert.

Every base ANSI color clears **5.07:1** (the weakest is `magenta`). The
`bright_*` siblings sit lower: `bright_magenta` is the floor at **4.13:1**,
and `dark_foreground` (chrome) is at 4.35:1. Those two are the only entries
below 4.5:1, and both are chrome-grade roles, in the same band as the
official light themes' weakest entries.

## 3. Resolution check

`omarchy-theme-color --file colors.toml --all` resolves **58 keys**
on Omarchy 4.0.6-1 — the same count the dark sibling resolves on this
version (on 4.0.5-1 the dark theme resolved 71; the resolver's derived-key
set narrowed with the release). Verified present and correct:
`mode = light`, `theme_type = light`, `bg`/`fg` aliases,
`color0–15`, `purple` → `#A63E96`, both
`hyprland_*_border` gradient strings intact.

Zero unexpanded `{{ }}` placeholders in staged `~/.local/state/omarchy/current/theme/`
after `omarchy theme install` (checked across all regenerated configs).

## 4. Staging (git theme)

`omarchy theme install` clones the repo and stages it; the deny list
(`*.lua`, `alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`,
`vscode.json`, symlinks) reported **nothing ignored** for this tree.
README/RESEARCH/LICENSE are staged as docs, as with the dark sibling.
`omarchy theme refresh` is idempotent (byte-identical staging) and does
not change the active background.

`preview.png` is original artwork (1800×1012), generated from
`colors.toml` by `scripts/make-preview.sh`: a soft rose wash, the theme
wordmark, an accent rule and the six ANSI swatches. It is not a desktop
screenshot and no longer depends on the wallpaper set.

Behavior note (verified while testing theme switches): when switching
themes, if the *current* background file does not belong to the new
theme's `backgrounds/`, `omarchy-theme-set` picks one of the new theme's
**randomly** (`omarchy theme bg current` may print a stale name while
`~/.local/state/omarchy/current/background` already points elsewhere).
Pin a deterministic background with
`omarchy theme bg set <absolute path>` after switching.

## 5. Plymouth / OWE specifics

- `omarchy-plymouth-set-by-theme lula-light` works exactly as for the
  dark theme: it uses this theme's own `unlock.png` plus its
  `background`/`foreground` (light boot: wine mark on paper).
  `omarchy plymouth preview` composites `preview-unlock.png` and always
  ends "hanging" in `imv` — that is the viewer, not the pipeline; the PNG
  is already written (run under `timeout`).
- No `backgrounds/intros/`: animated intro media only benefits the
  optional OWE wallpaper engine and are intentionally not shipped.

## 6. Assets

- The three wallpapers form a curated abstract set (blush, petal, linen),
  2560×1440 PNG, 150–205 KB, generated procedurally with ImageMagick.
- `unlock.png` (1108×523, transparent) and `preview-unlock.png`
  (1920×1080) are **this theme's own** key art, generated by
  `scripts/make-unlock.sh`. It is the exact geometric twin of the dark
  sibling's artwork: a disc sliced flat on the right, a square carrying a
  circular bite on its left and a chevron bite on its right, and a rhombus
  sliced flat on the left — three forms that interlock with gaps rather
  than overlapping. What changes is the palette: the forms are painted in
  the light accent `#B62A3E` on paper, and the dark sibling's red glow
  becomes a rose bloom of the same accent at the same opacity profile
  (a wide blur of the silhouette, `0x24`, on a padded canvas so it fades
  out before the canvas edge). Measured against the dark sibling:
  silhouette IoU **99.2%**, mean alpha difference **1.3/255**, and the lock
  glyph and password field land on the same pixels
  (`x 769..1102`, `y 841..888`; glyph `x 769..801`, `y 846..883`).
  The construction is documented at the top of `scripts/make-unlock.sh`.
- Icons `Yaru-red`, keyboard backlight `b62a3e` — the theme's own accent,
  which is also what the built-in `keyboard.rgb.tpl` (`{{ accent }}`)
  generates. The dark sibling keeps `e63950` because that *is* its accent.
  Omarchy's keyboard pipeline has no light/dark distinction.
