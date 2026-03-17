#!/bin/bash

keyboard_layout=$(hyprctl getoption input:kb_layout | head -1 | awk '{print $2}')
if [ "$keyboard_layout" = "es" ]; then
  hyprctl keyword input:kb_layout us
  echo "keyboard switched was switched to us from the following module keyboard_layout_switch.sh"
else
  hyprctl keyword input:kb_layout es
  echo "keyboard switched was switched to es from the following module keyboard_layout_switch.sh"
fi
