#!/bin/bash

WALLPAPERNUMBER=$1
EXTENSION=$2

echo "wallpaper {
    monitor = eDP-1
    path = ~/.config/walls/wallpaper$WALLPAPERNUMBER.$EXTENSION
 }

wallpaper {
    monitor = HDMI-A-1
    path = ~/.config/walls/wallpaper$WALLPAPERNUMBER.$EXTENSION
  }" >~/.config/hypr/hyprpapers/wallpaper$WALLPAPERNUMBER.conf

echo "Configuration file created"
