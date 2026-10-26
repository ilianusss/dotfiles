#!/usr/bin/env zsh
# Run by AeroSpace for each new window (aerospace.toml, the last on-window-detected): when it is the
# first window of an app that just started, moves it to the first empty workspace of the display
# and follows it. Left in place when it is alone in its workspace, or no workspace is empty, or it
# floats: AeroSpace floats dialogs, such as a file picker or a Touch ID or password prompt.

emulate -L zsh

id=$AEROSPACE_WINDOW_ID
read -r app workspace layout <<< $(aerospace list-windows --all \
    --format '%{window-id} %{app-bundle-id} %{workspace} %{window-layout}' |
    awk -v id=$id '$1 == id { print $2, $3, $4 }')
[[ -n $app && $layout != floating ]] || exit

(( $(aerospace list-windows --monitor all --app-bundle-id $app --count) == 1 )) || exit
(( $(aerospace list-windows --workspace $workspace --count) > 1 )) || exit

empty=$(aerospace list-workspaces --monitor focused --empty | head -1)
[[ -n $empty ]] && aerospace move-node-to-workspace --window-id $id --focus-follows-window $empty
