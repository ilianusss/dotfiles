#!/usr/bin/env zsh
# Every display has its own workspaces 1 to 9, named <set>-<n>, the set following the display's
# role (read_sets). Run by the workspace keys of aerospace.toml, and by the bar on a display change.
#
#   workspace.zsh focus <n>   go to workspace n of the focused display
#   workspace.zsh send <n>    send the focused window there (you stay where you are)
#   workspace.zsh sets        print "<monitor-id> <set>" per display (the bar's labels)
#   workspace.zsh reconcile   move the windows of a display that is gone to the displays left, and
#                             back if it returns within GRACE

emulate -L zsh
zmodload zsh/zselect zsh/system zsh/datetime

# Seconds a display can stay away and still get its windows back when it returns
GRACE=${GRACE:-900}
STATE=${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles
# One line per window moved by reconcile: <epoch seconds> <window-id> <from> <to>
PARKED=$STATE/parked

typeset -A set_of

# 1: the main display. 2: the other one, or with three displays the other external. 3: the
# built-in display, with three displays. Matches workspace-to-monitor-force-assignment.
read_sets() {
    local -a monitors=("${(@f)$(aerospace list-monitors \
        --format '%{monitor-id}|%{monitor-is-main}|%{monitor-name}')}")
    local line id main name
    for line in $monitors; do
        IFS='|' read -r id main name <<< $line
        if [[ $main == true ]]; then set_of[$id]=1
        elif (( $#monitors > 2 )) && [[ ${(L)name} == built-in* ]]; then set_of[$id]=3
        else set_of[$id]=2
        fi
    done
}

focused_set() {
    read_sets
    print -r -- ${set_of[$(aerospace list-monitors --focused --format '%{monitor-id}')]}
}

# A window moved by reconcile goes back to its workspace once the display of its set is back,
# unless it was moved or closed since. A line older than GRACE is dropped.
restore() {
    [[ -s $PARKED ]] || return 0
    local -a keep present=(${(v)set_of})
    local -A where
    local at id from to ws
    for id ws in $(aerospace list-windows --all --format '%{window-id} %{workspace}'); do
        where[$id]=$ws
    done
    while read -r at id from to; do
        (( EPOCHSECONDS - at > GRACE )) && continue
        if (( ! ${present[(Ie)${from%%-*}]} )); then keep+=("$at $id $from $to"); continue; fi
        [[ ${where[$id]} == $to ]] && aerospace move-node-to-workspace --window-id $id $from
    done <$PARKED
    if (( $#keep )); then print -rl -- $keep >$PARKED; else rm -f $PARKED; fi
}

# Run a second after a display change, so AeroSpace has parked or brought back the sets first; one
# run at a time. Each workspace with windows on a display whose set is not its own (AeroSpace parks
# the set of a missing display on the main one) moves to the next empty workspace: the main
# display's set first, then the other displays'. None left: they all go to workspace 9 of the main
# display.
reconcile() {
    zselect -t 100
    mkdir -p $STATE && : >>$STATE/reconcile.lock
    zsystem flock -t 30 $STATE/reconcile.lock || return
    read_sets
    restore
    local ws id s n target
    local -a orphans free empty=($(aerospace list-workspaces --monitor all --empty))
    for ws id in $(aerospace list-workspaces --monitor all --empty no \
            --format '%{workspace} %{monitor-id}'); do
        [[ ${ws%%-*} == ${set_of[$id]} ]] || orphans+=$ws
    done
    local -a sets=(1)
    for id in ${(on)${(k)set_of}}; do
        [[ ${set_of[$id]} == 1 ]] || sets+=${set_of[$id]}
    done
    for s in ${(u)sets}; do
        for n in {1..9}; do
            (( ${empty[(Ie)$s-$n]} )) && free+=$s-$n
        done
    done

    for ws in ${(o)orphans}; do
        target=${free[1]:-1-9}
        free=(${free[2,-1]})
        for id in $(aerospace list-windows --workspace $ws --format '%{window-id}'); do
            aerospace move-node-to-workspace --window-id $id $target &&
                print -r -- "$EPOCHSECONDS $id $ws $target" >>$PARKED
        done
    done
    sketchybar --trigger aerospace_workspace_change
}

case $1 in
    focus)     aerospace workspace $(focused_set)-$2 ;;
    # The focused workspace doesn't change, so exec-on-workspace-change doesn't run: tell the bar
    send)      aerospace move-node-to-workspace $(focused_set)-$2 &&
                   sketchybar --trigger aerospace_workspace_change ;;
    sets)      read_sets; for id s in ${(kv)set_of}; do print -r -- $id $s; done ;;
    reconcile) reconcile ;;
esac
