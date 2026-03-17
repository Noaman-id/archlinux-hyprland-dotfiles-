#!/bin/bash

if lsusb | grep "05ac:024f"; then
  hyprctl keyword input:kb_layout us
else
  hyprctl keyword input:kb_layout es
fi
