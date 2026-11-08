#!/usr/bin/env zsh
# Draws the workspace items: on each display, the workspaces of its monitor that have windows or are
# shown, the focused one highlighted. One run redraws them all, on every workspace change, app
# switch or display change. A workspace <set>-<n> (aerospace.toml) is labelled n on the display of
# its set, and in full on another one: the set of an unplugged display, parked on the main one until
# aerospace/workspace.zsh reconcile moves its windows.

emulate -L zsh

focused=${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused)}
typeset -a used=($(aerospace list-workspaces --monitor all --empty no)) args
typeset -A set_of=($(~/.config/aerospace/workspace.zsh sets))
for sid monitor display visible in $(aerospace list-workspaces --all --format \
        '%{workspace} %{monitor-id} %{monitor-appkit-nsscreen-screens-id} %{workspace-is-visible}'); do
    drawing=off highlight=off label=$sid
    [[ $visible == true ]] || (( ${used[(Ie)$sid]} )) && drawing=on
    [[ $sid == $focused ]] && highlight=on
    [[ ${sid%%-*} == ${set_of[$monitor]} ]] && label=${sid#*-}
    args+=(--set space.$sid display=$display drawing=$drawing label=$label
           background.drawing=$highlight label.highlight=$highlight)
done
sketchybar $args
