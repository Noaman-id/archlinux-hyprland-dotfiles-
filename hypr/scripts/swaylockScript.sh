#!/bin/bash

WALLPAPER=$(cat ~/.cache/current_wallpaper)

swaylock \
  --image "$WALLPAPER" \
  --scaling fill \
  --effect-blur 7x5 \
  --indicator \
  --clock
