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

awww img "${bgresult[$selected]}" --transition-type=wave --transition-angle=30 --transition-duration=2 >>/home/noaman/scriptsErrors.txt
# ether swww or hyprpaper
#
#killall hyprpaper
#hyprpaper --config "$HOME/.config/hypr/hyprpapers/$selected.conf" &

WALLPAPER=${bgresult[$selected]}
ln -sf $WALLPAPER ~/.cache/current_wallpaper
echo "The wallpaper chosen is $WALLPAPER"

echo "the fastfetch logo picker and eww color picker is launched"
exec $(/home/noaman/.config/hypr/scripts/ewwFastfetchGhosttyPicker.sh $WALLPAPER >/home/noaman/scriptsErrors.txt)
echo "the picker is done"

killall -SIGUSR2 waybar
echo "waybar reloaded"

#if ! pidof waybar >/dev/null; then
#  echo "waybar was not found, hence launched"
#  exec $(waybar --config "/home/noaman/.config/waybar/config.json" --style "/home/noaman/.config/waybar/style.css")
#fi
