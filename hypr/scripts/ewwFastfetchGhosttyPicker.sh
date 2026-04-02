#!/bin/bash

WALLPAPER=$1
echo "working on wallpaper : $WALLPAPER"

mkdir -p /home/noaman/.cache/TerminalLogo

PRIMARY_HEX_WALLPAPER=$(matugen image "$WALLPAPER" --json strip --source-color-index 0 | jq -r '.palettes.primary["10"].color')
echo "wallpaper primary hex is : $PRIMARY_HEX_WALLPAPER"

eww reload
pkill -USR2 ghostty
echo "eww and ghostty reloaded"

R=$((16#${PRIMARY_HEX_WALLPAPER:0:2}))
G=$((16#${PRIMARY_HEX_WALLPAPER:2:2}))
B=$((16#${PRIMARY_HEX_WALLPAPER:4:2}))
echo "the wallpaper hex : $R $G $B"

distance_array=()
LOGO_TO_APPLY=""
min_distance=999
for f in /home/noaman/.config/fastfetch/logo/*.png; do
  if [ -f "/home/noaman/.cache/TerminalLogo/$(basename "$f")" ]; then
    LOGO_PRI_HEX=$(cat /home/noaman/.cache/TerminalLogo/$(basename "$f"))
    echo "already existing in cache"
  else
    LOGO_PRI_HEX=$(matugen image "$f" --dry-run --json strip --source-color-index 0 | jq -r '.palettes.primary["10"].color')
    touch /home/noaman/.cache/TerminalLogo/$(basename "$f")
    echo "$LOGO_PRI_HEX" >/home/noaman/.cache/TerminalLogo/$(basename "$f")
    echo "added to cache"
  fi
  echo "$LOGO_PRI_HEX is the hex of the wallpaper $WALLPAPER"
  logo_r=$((16#${LOGO_PRI_HEX:0:2}))
  logo_g=$((16#${LOGO_PRI_HEX:2:2}))
  logo_b=$((16#${LOGO_PRI_HEX:4:2}))
  echo "--the logo hex is : $logo_r $logo_g $logo_b"

  distance=$(((R - logo_r) * (R - logo_r) + (G - logo_g) * (G - logo_g) + (B - logo_b) * (B - logo_b)))
  if ((distance < min_distance)); then
    LOGO_TO_APPLY=$f
    min_distance=$distance
  fi
done
echo "logo chosen is : $LOGO_TO_APPLY"

ln -sf "$LOGO_TO_APPLY" ~/.config/fastfetch/logo/logo.link
echo "logo linked"
