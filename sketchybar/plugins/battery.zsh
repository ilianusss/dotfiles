#!/usr/bin/env zsh
# Battery level from pmset, highlighted at 20 % and below unless charging. Hidden on a Mac without one.

emulate -L zsh

batt=$(pmset -g batt)
if [[ ! $batt =~ '([0-9]+)%' ]]; then
    sketchybar --set $NAME drawing=off
    exit
fi
percent=$match[1]

if [[ $batt == *"AC Power"* ]]; then icon=$''
elif (( percent > 80 )); then icon=$''
elif (( percent > 60 )); then icon=$''
elif (( percent > 40 )); then icon=$''
elif (( percent > 15 )); then icon=$''
else icon=$''
fi

low=off
[[ $batt != *"AC Power"* ]] && (( percent <= 20 )) && low=on
sketchybar --set $NAME icon=$icon icon.highlight=$low label="$percent%"
