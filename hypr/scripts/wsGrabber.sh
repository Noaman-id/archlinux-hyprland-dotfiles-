#!/bin/bash

CACHE_PATH="$HOME/.cache/workspaceShots/"

mkdir -p "$CACHE_PATH"

shots=()
for FName in $(find $CACHE_PATH -maxdepth 1 -type f); do
  shots+=("$FName")
done

input=""

for f in "${shots[@]}"; do
  label=$(basename "$f" .png)
  input+="$label\0icon\x1f$f\n"
done

selected=$(printf $input | rofi -dmenu -show-icons -p "Select workspace to bring" -theme "$HOME/.config/rofi/wallpaper-theme/rounded-template.rasi")

ws_id=$(echo "$selected" | grep -o '[0-9]*')

current_ws=$(hyprctl activeworkspace -j | grep -o '"id": [0-9]*' | awk -F': ' '{print $2}')

#jq is used to parse json instead of doing it manualy
hyprctl clients -j | jq -r --argjson id "$ws_id" '.[] | select(.workspace.id == $id) | .address' |
  while read -r addr; do
    hyprctl dispatch movetoworkspacesilent "$current_ws,address:$addr"
  done
