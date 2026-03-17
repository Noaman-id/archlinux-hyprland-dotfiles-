#!/bin/bash

CACHE_PATH="$HOME/.cache/workspaceShots/"
mkdir -p "$CACHE_PATH"

SOCKET="/run/user/$(id -u)/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

ws_id=$(hyprctl activeworkspace -j | grep -o '"id": [0-9]*' | awk -F ': ' '{print $NF}')
monitor=$(hyprctl activeworkspace -j | grep -o '"monitor": ".*"' | awk -F ': ' '{print $NF}' | tr -d '"')
grim -o "$monitor" "$CACHE_PATH/ws_${ws_id}.png"

socat -U UNIX-CONNECT:$SOCKET |
  while read -r line; do
    if [[ "${line:0:9}" == "workspace" ]]; then
      sleep 0.05
      ws_id=$(hyprctl activeworkspace -j | grep -o '"id": [0-9]*' | awk -F ': ' '{print $NF}')
      monitor=$(hyprctl activeworkspace -j | grep -o '"monitor": ".*"' | awk -F ': ' '{print $NF}' | tr -d '"')
      grim -o "$CACHE_PATH/ws_${ws_id}.png"
    fi
  done
