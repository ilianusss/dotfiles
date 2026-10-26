#!/usr/bin/env zsh
# Bluetooth off (dimmed), on, or connected to a device. system_profiler needs no permission.

emulate -L zsh

bt=$(system_profiler SPBluetoothDataType 2>/dev/null)

off=off
if [[ $bt == *"State: Off"* ]]; then icon=$'󰂲' off=on
elif grep -q '^ *Connected:$' <<< $bt; then icon=$'󰂱'
else icon=$'󰂯'
fi
sketchybar --set $NAME icon=$icon icon.highlight=$off
