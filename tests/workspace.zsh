# aerospace/workspace.zsh

workspace() { $REPO/aerospace/workspace.zsh "$@" }

PARKED_FILE=.local/state/dotfiles/parked

# Two displays, the other one just plugged back in. Window 10 was moved by reconcile from 2-1 to 1-3
# <seconds> ago, when that display was unplugged.
parked_seconds_ago() {
    wm '1|true|main' '2|false|other'
    wm_window 10 app.ten 1-3
    mkdir -p ~/.local/state/dotfiles
    print -r -- "$(( EPOCHSECONDS - $1 )) 10 2-1 1-3" >~/$PARKED_FILE
}

test_reconcile_moves_a_parked_window_back_when_its_display_returns() {
    parked_seconds_ago 60
    workspace reconcile || fail "exit $?"
    assert_eq "$(wm_where 10)" 2-1
}

test_reconcile_leaves_no_parked_file_once_every_window_is_back() {
    parked_seconds_ago 60
    workspace reconcile || fail "exit $?"
    [[ ! -e ~/$PARKED_FILE ]] || fail "left: $(<~/$PARKED_FILE)"
}

test_reconcile_moves_a_parked_window_back_after_five_hours() {
    parked_seconds_ago $(( 5 * 3600 ))
    workspace reconcile || fail "exit $?"
    assert_eq "$(wm_where 10)" 2-1
}

test_reconcile_leaves_a_window_parked_more_than_six_hours_ago_and_drops_its_line() {
    parked_seconds_ago $(( 6 * 3600 + 60 ))
    workspace reconcile || fail "exit $?"
    assert_eq "$(wm_where 10)" 1-3
    [[ ! -e ~/$PARKED_FILE ]] || fail "left: $(<~/$PARKED_FILE)"
}

test_reconcile_leaves_a_parked_window_moved_since_and_drops_its_line() {
    parked_seconds_ago 60
    print -r -- "10 app.ten 1-5 tiling 1" >~/wm/windows
    workspace reconcile || fail "exit $?"
    assert_eq "$(wm_where 10)" 1-5
    [[ ! -e ~/$PARKED_FILE ]] || fail "left: $(<~/$PARKED_FILE)"
}

test_reconcile_keeps_the_line_of_a_window_whose_display_is_still_away() {
    parked_seconds_ago 60
    print -r -- "$(( EPOCHSECONDS - 60 )) 10 3-1 1-3" >~/$PARKED_FILE
    workspace reconcile || fail "exit $?"
    assert_eq "$(wm_where 10)" 1-3
    assert_eq "$(cut -d' ' -f2- ~/$PARKED_FILE)" "10 3-1 1-3"
}

test_record_appends_the_focused_workspace_with_the_time() {
    workspace record 2-4 || fail "exit $?"
    local at ws
    read -r at ws <~/.local/state/dotfiles/focus
    assert_eq "$ws" 2-4
    (( EPOCHSECONDS - at < 5 )) || fail "time: $at"
}

test_record_keeps_the_last_fifty_lines_once_past_a_hundred() {
    local n
    for n in {1..101}; do
        workspace record 1-$(( n % 9 + 1 ))-$n || fail "exit $?"
    done
    local -a lines=("${(@f)$(<~/.local/state/dotfiles/focus)}")
    assert_eq $#lines 50
    assert_eq "${lines[-1]#* }" 1-3-101
}
