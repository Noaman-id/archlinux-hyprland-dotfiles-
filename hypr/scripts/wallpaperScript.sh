#!/bin/bash

USER_HOME=$(getent passwd "$USER" | cut -d: -f6)
USER_HOME="${USER_HOME:-$HOME}"

WALLPAPER_ROOT="$USER_HOME/.config/walls"
CACHE_DIR="$USER_HOME/.config/rofi-wallpaper-cache"
CACHE_ROOT="$CACHE_DIR/thumbs"

mkdir -p "$WALLPAPER_ROOT"
mkdir -p "$CACHE_ROOT"

function cacheImg {
  local input_path="$1"
  local output_path="$2"

  if [[ -f "$output_path" && "$output_path" -nt "$input_path" ]]; then
    echo "$output_path"
    return 0
  fi

  ffmpeg -i "$input_path" -y -loglevel quiet \
    -vf "scale='if(gt(iw,ih),1200*iw/ih,1200)':'if(gt(iw,ih),1200,1200*ih/iw)',crop=1200:1200" \
    "$output_path"
}

function getFileName {
  echo "$1" | xargs basename | awk -F'.' '{print $1}' | tr '[:upper:]' '[:lower:]'
}

mapfile -t originPath < <(find "${WALLPAPER_ROOT}" -maxdepth 1 -type f -regex '.*\.\(jpg\|jpeg\|png\|gif\|apng\)$' -not -path "${CACHE_ROOT}/*")

declare -A bgresult
declare -A cachedresult
bgnames=()

# Populate bgresult and bgnames from WALLPAPER_ROOT
for pathIDX in "${!originPath[@]}"; do
  filename=$(getFileName "${originPath[$pathIDX]}")
  bgresult["${filename}"]="${originPath[$pathIDX]}"
  bgnames[$pathIDX]+="${filename}"
done

# Force cache creation for all wallpapers
for fName in "${bgnames[@]}"; do
  # Call the function using the correct lowercase name: cacheImg
  cachedresult[$fName]=$(cacheImg "${bgresult[$fName]}" "${CACHE_ROOT}/${fName}.png")
done

# --- 3. GENERATE ROFI LIST & LAUNCH ---

strrr=""
# Format: <display_name>\0icon\x1f<icon_path>\n
for fName in "${bgnames[@]}"; do
  THUMB_PATH="${cachedresult[$fName]}"

  # Only add the entry to Rofi if a valid thumbnail path exists
  if [[ -n "$THUMB_PATH" ]]; then
    strrr+="$(echo -n "${fName}\0icon\x1f${THUMB_PATH}\n")"
  else
    # Skipping entry message is sent to stderr
    echo "Skipping entry for ${fName} due to failed thumbnail." >&2
  fi
done

# Use simplified Rofi call since keybind is used (no need for complex config handling)
selected=$(echo -en "${strrr}" | rofi -dmenu -show-icons -p "Select Wallpaper" -theme "$USER_HOME/.config/rofi/wallpaper-theme/rounded-template.rasi")

# Check if a wallpaper was selected
if [[ -z "$selected" ]]; then
  exit 0
fi

# --- 4. APPLY WALLPAPER ---

swww img "${bgresult[$selected]}" --transition-type=wave --transition-angle=30 --transition-duration=2
# ether swww or hyprpaper
#
#killall hyprpaper
#hyprpaper --config "$HOME/.config/hypr/hyprpapers/$selected.conf" &

WALLPAPER=${bgresult[$selected]}
ln -sf $WALLPAPER ~/.cache/current_wallpaper
echo "Successfully set ${selected} as wallpaper."

echo "The wallpaper chosen is $WALLPAPER"

PRIMARY_HEX_WALLPAPER=$(matugen image "$WALLPAPER" --json strip --source-color-index 0 | jq -r '.palettes.primary["10"].color')
eww reload
pkill -SIGUSR2 ghostty

distance_array=()
LOGO_TO_APPLY=""
min_distance=1000
for f in /home/noaman/.config/fastfetch/logo/*; do
  LOGO_PRI_HEX=$(matugen image "$f" --dry-run --json strip --source-color-index 0 | jq -r '.palettes.primary["10"].color')

  logo_r=$((16#${LOGO_PRI_HEX:0:2}))
  logo_g=$((16#${LOGO_PRI_HEX:2:2}))
  logo_b=$((16#${LOGO_PRI_HEX:4:2}))

  R=$((16#${PRIMARY_HEX_WALLPAPER:0:2}))
  G=$((16#${PRIMARY_HEX_WALLPAPER:2:2}))
  B=$((16#${PRIMARY_HEX_WALLPAPER:4:2}))

  distance=$(echo "sqrt(($R-$logo_r)*($R-$logo_r) + ($G-$logo_g)*($G-$logo_g) + ($B-$logo_b)*($B-$logo_b))" | bc -l)
  if (($(echo "$distance < $min_distance" | bc -l))); then
    LOGO_TO_APPLY=$f
    min_distance=$distance
  fi
done

ln -sf "$LOGO_TO_APPLY" ~/.config/fastfetch/logo/logo.png
