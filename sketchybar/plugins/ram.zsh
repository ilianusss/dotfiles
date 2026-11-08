#!/usr/bin/env zsh
# Memory in use in percent: the opposite of the free percentage memory_pressure reports.

emulate -L zsh

free=$(memory_pressure | awk '/free percentage/ { print $5 + 0 }')
sketchybar --set $NAME label="$((100 - free))%"
