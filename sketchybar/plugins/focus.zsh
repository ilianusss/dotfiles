#!/usr/bin/env zsh
# A crescent moon, lit while a Focus (Do Not Disturb or another) is on and dimmed otherwise. The
# "Get Current Focus" shortcut (README) prints the name of the Focus that is on, nothing otherwise:
# macOS keeps that state in a file the bar could only read with Full Disk Access. A run can hang
# right after a toggle: perl stops it after 5 s, so the runs every 10 s never pile up.

emulate -L zsh

dimmed=on
[[ -n $(perl -e 'alarm 5; exec @ARGV' shortcuts run 'Get Current Focus' 2>/dev/null) ]] && dimmed=off
sketchybar --set $NAME icon.highlight=$dimmed
