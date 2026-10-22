# dotfiles status

test_status_reports_each_repo_up_to_date_when_all_is_clean_and_linked() {
    dotfiles install >/dev/null || fail "exit $?"
    local output
    output=$(dotfiles status) || fail "exit $?"
    assert_eq "$output" "~/.dotfiles: up to date
~/.config/nvim: up to date
~/.claude: up to date"
}

test_status_reports_uncommitted_changes_and_commits_to_push_and_pull() {
    dotfiles install >/dev/null || fail "exit $?"
    push_upstream nvim init.lua v2
    git -C ~/.config/nvim fetch -q
    print local >~/.config/nvim/lazy-lock.json
    git -C ~/.config/nvim commit -qam local
    print local >~/.config/nvim/init.lua
    local output
    output=$(dotfiles status) || fail "exit $?"
    assert_eq "$output" "~/.dotfiles: up to date
~/.config/nvim: uncommitted changes, 1 to push, 1 to pull
~/.claude: up to date"
}

test_status_reports_a_missing_repo_and_files_not_linked() {
    rm -rf ~/.claude
    print mine >~/.zshrc
    local output
    output=$(dotfiles status) || fail "exit $?"
    assert_eq "$output" "~/.dotfiles: up to date
~/.config/nvim: up to date
~/.claude: not cloned, run dotfiles install
~/.zshrc: not linked, run dotfiles install
~/.config/ghostty/config.ghostty: not linked, run dotfiles install
~/.theme: not linked, run dotfiles install"
}

test_status_reports_a_branch_without_upstream() {
    dotfiles install >/dev/null || fail "exit $?"
    git -C ~/.config/nvim checkout -qb experiment
    local output
    output=$(dotfiles status 2>&1) || fail "exit $?"
    assert_eq "$output" "~/.dotfiles: up to date
~/.config/nvim: branch experiment has no upstream
~/.claude: up to date"
}
