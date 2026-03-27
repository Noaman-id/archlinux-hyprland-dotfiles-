#!/bin/bash

SOURCE_NAME="alsa_input.pci-0000_35_00.6.analog-stereo"

pactl subscribe | grep --line-buffered "on card" | while read -r line; do
  sleep 0.3

  ACTIVE_PORT=$(pactl list sources | grep analog-input-headset-mic | grep -o "availability unknown")

  if [ "$ACTIVE_PORT" = "availability unknown" ]; then
    echo "Casque branché → headset mic default"
    pactl set-source-port $SOURCE_NAME analog-input-headset-mic
  else
    echo "Casque débranché → mic interne"
  fi
done
