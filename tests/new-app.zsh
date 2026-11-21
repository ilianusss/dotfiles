# aerospace/new-app.zsh

# Window 9 is the first window of app.zen, process 500, started at LAUNCH
LAUNCH=1795240000

new_app() { AEROSPACE_WINDOW_ID=$1 $REPO/aerospace/new-app.zsh }

# Workspace <ws> got the focus <seconds> after LAUNCH (negative: before), as recorded by
# `workspace.zsh record`
focused_at() {
    mkdir -p ~/.local/state/dotfiles
    print -r -- "$(( LAUNCH + $1 )) $2" >>~/.local/state/dotfiles/focus
}

# Displays 1 (main, workspaces 1-*) and 2 (2-*); zen opens in <workspace>, focused now
zen_opens_in() {
    wm '1|true|main' '2|false|other'
    wm_window 9 app.zen $1 tiling 500
    wm_started 500 $LAUNCH
    wm_focus $1
}

test_new_app_in_a_used_workspace_moves_to_the_first_empty_one_and_is_followed() {
    zen_opens_in 1-1
    wm_window 1 app.one 1-1
    focused_at -100 1-1
    new_app 9 || fail "exit $?"
    assert_eq "$(calls)" "aerospace move-node-to-workspace 9 1-2 follow"
}

test_new_app_alone_in_its_workspace_stays() {
    zen_opens_in 1-1
    focused_at -100 1-1
    new_app 9 || fail "exit $?"
    assert_eq "$(calls)" ""
}

test_new_app_floating_stays() {
    wm '1|true|main' '2|false|other'
    wm_window 1 app.one 1-1
    wm_window 9 app.zen 1-1 floating 500
    wm_started 500 $LAUNCH
    new_app 9 || fail "exit $?"
    assert_eq "$(calls)" ""
}

test_new_app_window_of_an_app_with_another_window_stays() {
    zen_opens_in 1-1
    wm_window 1 app.one 1-1
    wm_window 8 app.zen 1-4 tiling 500
    new_app 9 || fail "exit $?"
    assert_eq "$(calls)" ""
}

test_new_app_launched_from_another_display_moves_to_its_first_empty_workspace_unfollowed() {
    zen_opens_in 2-1
    wm_window 1 app.one 1-1
    wm_window 2 app.two 2-1
    focused_at -100 1-1
    focused_at 2 2-1
    new_app 9 || fail "exit $?"
    assert_eq "$(calls)" "aerospace move-node-to-workspace 9 1-2"
}

test_new_app_launched_from_another_display_moves_there_even_when_alone() {
    zen_opens_in 2-5
    wm_window 1 app.one 1-1
    focused_at -100 1-1
    focused_at 2 2-5
    new_app 9 || fail "exit $?"
    assert_eq "$(calls)" "aerospace move-node-to-workspace 9 1-2"
}

test_new_app_launched_from_an_empty_workspace_of_another_display_moves_to_it() {
    zen_opens_in 2-1
    wm_window 1 app.one 1-1
    wm_window 2 app.two 2-1
    focused_at -100 1-4
    focused_at 2 2-1
    new_app 9 || fail "exit $?"
    assert_eq "$(calls)" "aerospace move-node-to-workspace 9 1-4"
}

test_new_app_launched_from_another_display_without_empty_workspace_moves_to_the_launch_one() {
    zen_opens_in 2-1
    local n
    for n in {1..9}; do
        wm_window 1$n app.one$n 1-$n
    done
    wm_window 2 app.two 2-1
    focused_at -100 1-3
    focused_at 2 2-1
    new_app 9 || fail "exit $?"
    assert_eq "$(calls)" "aerospace move-node-to-workspace 9 1-3"
}

test_new_app_without_focus_history_moves_on_the_display_it_opened_on() {
    zen_opens_in 2-1
    wm_window 2 app.two 2-1
    new_app 9 || fail "exit $?"
    assert_eq "$(calls)" "aerospace move-node-to-workspace 9 2-2 follow"
}

test_new_app_counts_a_focus_change_in_the_launch_second_as_before_the_launch() {
    zen_opens_in 2-1
    wm_window 1 app.one 1-1
    wm_window 2 app.two 2-1
    focused_at -100 1-1
    focused_at 0 2-1
    new_app 9 || fail "exit $?"
    assert_eq "$(calls)" "aerospace move-node-to-workspace 9 2-2 follow"
}

test_new_app_never_moves_to_the_workspace_of_a_parked_display() {
    wm '1|true|main'
    wm_park 3 1
    local n
    for n in {1..9}; do
        wm_window 1$n app.one$n 1-$n
    done
    wm_window 9 app.zen 1-1 tiling 500
    wm_started 500 $LAUNCH
    focused_at -100 1-1
    new_app 9 || fail "exit $?"
    assert_eq "$(calls)" ""
}
