#!/usr/bin/env zsh
# Draws the workspace items: on each display, the workspaces of its monitor that have windows or are
# shown, the focused one highlighted. One run redraws them all, on every workspace change, app
# switch or display change.

emulate -L zsh

focused=${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused)}
typeset -a used=($(aerospace list-workspaces --monitor all --empty no)) args
for sid display visible in $(aerospace list-workspaces --all \
        --format '%{workspace} %{monitor-appkit-nsscreen-screens-id} %{workspace-is-visible}'); do
    drawing=off highlight=off
    [[ $visible == true ]] || (( ${used[(Ie)$sid]} )) && drawing=on
    [[ $sid == $focused ]] && highlight=on
    args+=(--set space.$sid display=$display drawing=$drawing
           background.drawing=$highlight label.highlight=$highlight)
done
sketchybar $args
