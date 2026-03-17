#!/bin/bash

LOG=/tmp/usb-keyboard.log

echo "started $(date)" >>"$LOG"
/usr/bin/hyprctl keyword input:kb_layout us >/dev/null 2>&1
rc=$?
echo "hyprctl rc=$rc" >>"$LOG"

exit 0
