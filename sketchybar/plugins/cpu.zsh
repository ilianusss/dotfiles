#!/usr/bin/env zsh
# CPU load in percent (user + system), from the second sample of top: the first one covers the time
# since boot.

emulate -L zsh

usage=$(top -l 2 -n 0 -s 1 | awk '/^CPU usage/ { user = $3 + 0; sys = $5 + 0 } END { printf "%.0f", user + sys }')
sketchybar --set $NAME label="$usage%"
