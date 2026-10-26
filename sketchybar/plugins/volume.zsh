#!/usr/bin/env zsh
# Output volume: $INFO holds it on volume_change, else it is asked from macOS. Hidden when the output
# has no volume (some HDMI and AirPlay devices).

emulate -L zsh

volume=${INFO:-$(osascript -e 'output volume of (get volume settings)')}
if [[ $volume != <-> ]]; then
    sketchybar --set $NAME drawing=off
    exit
fi

if (( volume == 0 )); then icon=$''
elif (( volume < 50 )); then icon=$''
else icon=$''
fi
sketchybar --set $NAME drawing=on icon=$icon label="$volume%"
