#!/usr/bin/env zsh
# Run by AeroSpace for each new window (aerospace.toml, the last on-window-detected): when it is the
# first window of an app that just started, moves it to the display the app was launched from, to
# its first empty workspace. AeroSpace opens a window in the focused workspace, which is another
# display's when you went there while the app started: the launch display is the one focused at the
# app's start time, in the history `workspace.zsh record` keeps.
#
# Launched from this display: the window is followed, and left in place when it is alone in its
# workspace or no workspace is empty. From another display: it goes to the workspace you launched it
# from when that one is empty or none is, and you stay where you are. A floating window is left in
# place: AeroSpace floats dialogs, such as a file picker or a Touch ID or password prompt.

emulate -L zsh
zmodload zsh/datetime

FOCUS=${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/focus

id=$AEROSPACE_WINDOW_ID
typeset -A windows_in windows_of monitor_of
local wid wapp wws wlayout wpid app workspace layout pid
for wid wapp wws wlayout wpid in $(aerospace list-windows --all \
        --format '%{window-id} %{app-bundle-id} %{workspace} %{window-layout} %{app-pid}'); do
    (( windows_in[$wws]++, windows_of[$wapp]++ ))
    [[ $wid == $id ]] && app=$wapp workspace=$wws layout=$wlayout pid=$wpid
done
[[ -n $app && $layout != floating ]] && (( windows_of[$app] == 1 )) || exit 0

# The workspace focused when the app started (ps gives the second), empty without a record
launch_workspace() {
    [[ -r $FOCUS ]] || return 0
    local started at ws found
    started=${(j: :)${=$(LC_ALL=C ps -o lstart= -p $pid)}}
    strftime -r -s started '%a %b %d %H:%M:%S %Y' $started 2>/dev/null || return 0
    while read -r at ws; do
        (( at > started )) && break
        found=$ws
    done <$FOCUS
    print -r -- $found
}

monitor_of=($(aerospace list-workspaces --all --format '%{workspace} %{monitor-id}'))
here=${monitor_of[$workspace]}
from=$(launch_workspace)
[[ -n $from && -n ${monitor_of[$from]} && ${monitor_of[$from]} != $here ]] || from=$workspace

(( windows_in[$workspace]-- ))
target=$from
if (( windows_in[$from] )); then
    for ws in ${(o)${(k)monitor_of}}; do
        if [[ ${monitor_of[$ws]} == ${monitor_of[$from]} && ${ws%%-*} == ${from%%-*} ]] &&
                (( ! windows_in[$ws] )); then
            target=$ws
            break
        fi
    done
fi

[[ $target == $workspace ]] && exit 0
if [[ ${monitor_of[$target]} == $here ]]; then
    aerospace move-node-to-workspace --window-id $id --focus-follows-window $target
else
    aerospace move-node-to-workspace --window-id $id $target
fi
