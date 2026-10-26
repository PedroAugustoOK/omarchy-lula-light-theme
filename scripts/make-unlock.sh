#!/bin/bash
# Generate the Lula Light lock artwork from the theme palette.
#
#   ./scripts/make-unlock.sh [theme-dir] [unlock.png] [preview-unlock.png]
#
# The mark is the Lula family monogram and is the exact geometric twin of the
# dark sibling's unlock.png: a disc, a square and a rhombus that interlock
# with gaps rather than overlapping. The construction, measured off the dark
# artwork:
#
#   disc    centre (260,260) r 206, clipped at x = 391  -> the left form
#   square  rect 392..742 x 70..451, minus the disc and minus the rhombus
#   rhombus top (846,54) right (1052,260) bottom (846,467) left (639,260),
#            clipped at x = 744                          -> the right form
#
# The square therefore carries a circular bite on its left and a chevron bite
# on its right, and the disc and the rhombus are sliced flat so the three
# forms read as one ribbon with breathing room between them.
#
# The dark sibling paints a wide red glow behind the mark. On paper the same
# glow would read as a stain, so the halo here is the accent itself at the
# same opacity profile - a soft rose bloom that keeps the artwork's character
# without fighting the background.
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/palette.sh"

theme_dir=${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}
out_unlock=${2:-$theme_dir/unlock.png}
out_preview=${3:-$theme_dir/preview-unlock.png}

W=1108
H=523


accent=$(color accent)
background=$(color background)
foreground=$(color foreground)

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

# --- the three forms ----------------------------------------------------
mask() { # $1 = draw primitive, $2 = output path (grayscale: black = off)
  magick -size ${W}x${H} xc:black -fill white -draw "$1" -colorspace gray "$2"
}

mask "circle 260,260 466,260" "$tmp/disc.png"
mask "polygon 846,54 1052,260 846,467 639,260" "$tmp/rhombus.png"
mask "rectangle 392,70 742,451" "$tmp/square.png"
mask "rectangle 0,0 391,522" "$tmp/clip-left.png"
mask "rectangle 744,0 1107,522" "$tmp/clip-right.png"

# Negated copies: the square is the rectangle with the other two forms taken
# out of it.
magick "$tmp/disc.png" -alpha off -negate "$tmp/no-disc.png"
magick "$tmp/rhombus.png" -alpha off -negate "$tmp/no-rhombus.png"

# Left form: the disc, sliced flat on the right.
magick "$tmp/disc.png" "$tmp/clip-left.png" -compose Multiply -composite "$tmp/form-disc.png"
# Middle form: the square, less the disc and less the rhombus.
magick "$tmp/square.png" "$tmp/no-disc.png" -compose Multiply -composite "$tmp/step.png"
magick "$tmp/step.png" "$tmp/no-rhombus.png" -compose Multiply -composite "$tmp/form-square.png"
# Right form: the rhombus, sliced flat on the left.
magick "$tmp/rhombus.png" "$tmp/clip-right.png" -compose Multiply -composite "$tmp/form-rhombus.png"

magick "$tmp/form-disc.png" "$tmp/form-square.png" -compose Lighten -composite "$tmp/step.png"
magick "$tmp/step.png" "$tmp/form-rhombus.png" -compose Lighten -composite "$tmp/silhouette.png"

# --- the mark ------------------------------------------------------------
# Halo: a wide blur of the silhouette, on a padded canvas so the glow is
# not clipped by the edges. This reproduces the dark sibling's glow profile -
# a soft ramp that fades to nothing well before the canvas border - without
# the hard rectangular seam a canvas-edge blur would leave.
magick "$tmp/silhouette.png" \
  -background black -gravity center -extent $((W + 160))x$((H + 160)) \
  -blur 0x24 \
  -gravity center -crop ${W}x${H}+0+0 +repage "$tmp/halo.png"

# The forms themselves, in the theme accent, with the same soft one-pixel
# edge the dark sibling has.
magick "$tmp/silhouette.png" -blur 0x0.8 "$tmp/forms.png"

magick -size ${W}x${H} "xc:$accent" "$tmp/halo.png" -alpha off \
  -compose CopyOpacity -composite "$tmp/halo-color.png"

magick -size ${W}x${H} "xc:$accent" "$tmp/forms.png" -alpha off \
  -compose CopyOpacity -composite "$tmp/forms-color.png"

magick "$tmp/halo-color.png" "$tmp/forms-color.png" -compose Over -composite \
  -depth 8 -strip "$out_unlock"

# --- lock screen preview -------------------------------------------------
# The same layout as the dark sibling: the mark centred horizontally with the
# lock field 110px below it.
PW=1920
PH=1080

magick -size ${PW}x${PH} "xc:$background" "$out_unlock" \
  -gravity north -geometry +0+278 -compose Over -composite \
  "$tmp/preview-mark.png"

# Password field: 2px outline plus four dots, in the foreground ink.
FIELD_X=818
FIELD_Y=842
FIELD_W=283
FIELD_H=45

magick -size ${PW}x${PH} xc:none \
  -fill none -stroke "$foreground" -strokewidth 2 \
  -draw "rectangle $FIELD_X,$FIELD_Y $((FIELD_X + FIELD_W)),$((FIELD_Y + FIELD_H))" \
  -fill "$foreground" -stroke none \
  -draw "circle 840,864 843.5,864" \
  -draw "circle 852,864 855.5,864" \
  -draw "circle 864,864 867.5,864" \
  -draw "circle 876,864 879.5,864" \
  "$tmp/field.png"

# Lock glyph: shackle, body and keyhole. The shackle is a tall elliptical
# arch (rx 7.25, ry 11) so its legs reach the body, exactly like the dark
# sibling's.
magick -size ${PW}x${PH} xc:none \
  -fill none -stroke "$foreground" -strokewidth 5 \
  -draw "arc 777,848.5 792,870.5 180,360" \
  -fill "$foreground" -stroke none \
  -draw "roundrectangle 769,860 801,883 4,3" \
  -fill "$background" -stroke none \
  -draw "roundrectangle 784,868 786,875 1,1" \
  "$tmp/lock.png"

magick "$tmp/preview-mark.png" "$tmp/lock.png" -compose Over -composite "$tmp/step-lock.png"
magick "$tmp/step-lock.png" "$tmp/field.png" -compose Over -composite \
  -depth 8 -strip "$out_preview"

echo "wrote $out_unlock"
echo "wrote $out_preview"
