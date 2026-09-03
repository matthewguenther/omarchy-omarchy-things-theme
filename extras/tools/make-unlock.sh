#!/bin/bash
# Renders preview-unlock.png (lock screen preview) with ImageMagick, and unlock.png
# (a fallback wordmark) only if unlock.png is missing or --force is given.
# Matt's own unlock.png is the real logo; do not overwrite it by accident.
# Run from the repo root: extras/tools/make-unlock.sh [--force] [wallpaper]
# The optional wallpaper is used behind the logo in preview-unlock.png (default: first in backgrounds/).
set -e
RED='#c8181a'
FORCE=0; WP=""
for a in "$@"; do [[ $a == --force ]] && FORCE=1 || WP=$a; done
if [[ ! -f unlock.png || $FORCE == 1 ]]; then
F=$(fc-match -f '%{file}' "Liberation Serif:bold")
T=$(mktemp --suffix=.png)
magick -size 1108x523 xc:none -gravity center -font "$F" -kerning 14 \
  -fill none -stroke "$RED" -strokewidth 4 -pointsize 175 -annotate +0-62 "STRANGER" \
  -pointsize 150 -annotate +0+108 "THINGS" \
  -stroke "$RED" -strokewidth 3 -draw "line 120,52 988,52" -draw "line 120,470 988,470" "$T"
magick "$T" \( +clone -blur 0x18 -channel A -evaluate multiply 1.8 +channel \) +swap -compose over -composite \
  \( "$T" -blur 0x3 \) -compose over -composite unlock.png
fi
# Lock-screen preview: first wallpaper if one exists, otherwise a black-to-blood-red gradient.
# Done in small steps: one big 4K composite in a single magick call hung once.
BG=${WP:-$(ls backgrounds/*.{jpg,jpeg,png} 2>/dev/null | head -1 || true)}
if [[ -n $BG ]]; then
  magick "$BG" -resize 1920x1080 -fill black -colorize 35% -quality 92 "$T.bg.jpg"
else
  magick -size 1920x1080 gradient:'#0a0909'-'#3a0708' -background black -vignette 0x250 -quality 92 "$T.bg.jpg"
fi
magick unlock.png -resize 1000x "$T.logo.png"
magick "$T.bg.jpg" "$T.logo.png" -gravity center -composite -depth 8 preview-unlock.png
rm -f "$T" "$T.bg.jpg" "$T.logo.png"; identify unlock.png preview-unlock.png
