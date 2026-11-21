# aerospace/workspace.zsh

workspace() { $REPO/aerospace/workspace.zsh "$@" }

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
