#!/usr/bin/env bash

awww-daemon &
WALLPAPER="$(find /home/noaman/.config/walls/ -maxdepth 1 -type f | shuf -n 1)"
echo "$WALLPAPER" >/home/noaman/.cache/current_wallpaper_path.txt
ln -sf "$WALLPAPER" /home/noaman/.cache/current_wallpaper

awww img "$WALLPAPER" --transition-type wipe --transition-step 90 --transition-fps 30 >>/home/noaman/scriptsErrors.txt
exec ./ewwFastfetchGhosttyPicker.sh "$WALLPAPER"
