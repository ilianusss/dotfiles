# dotfiles update

test_update_leaves_up_to_date_repos_alone_silently() {
    local before=$(head_of ~/.config/nvim) output
    output=$(dotfiles update) || fail "exit $?"
    assert_eq "$output" ""
    assert_eq $(head_of ~/.config/nvim) $before
    assert_eq "$(calls)" ""
}

test_update_fast_forwards_a_repo_behind_its_upstream() {
    push_upstream nvim init.lua v2
    dotfiles update || fail "exit $?"
    assert_eq $(head_of ~/.config/nvim) $(upstream_of nvim)
    assert_eq "$(<~/.config/nvim/init.lua)" v2
}

test_update_fast_forwards_past_a_local_edit_of_another_file() {
    push_upstream nvim init.lua v2
    print local >~/.config/nvim/lazy-lock.json
    dotfiles update || fail "exit $?"
    assert_eq $(head_of ~/.config/nvim) $(upstream_of nvim)
    assert_eq "$(<~/.config/nvim/lazy-lock.json)" local
}

test_update_keeps_a_local_edit_the_update_would_overwrite_and_notifies() {
    local before=$(head_of ~/.config/nvim)
    push_upstream nvim init.lua v2
    print local >~/.config/nvim/init.lua
    dotfiles update && fail "exit 0, expected a failure"
    assert_eq $(head_of ~/.config/nvim) $before
    assert_eq "$(<~/.config/nvim/init.lua)" local
    assert_eq "$(calls)" "notify ~/.config/nvim: not updated, local changes conflict with upstream"
}

test_update_notifies_a_blocked_repo_once_per_upstream_commit() {
    push_upstream nvim init.lua v2
    print local >~/.config/nvim/init.lua
    dotfiles update
    dotfiles update
    assert_eq "$(calls)" "notify ~/.config/nvim: not updated, local changes conflict with upstream"
}

test_update_notifies_a_blocked_repo_again_when_upstream_moves() {
    push_upstream nvim init.lua v2
    print local >~/.config/nvim/init.lua
    dotfiles update
    push_upstream nvim init.lua v3
    dotfiles update
    assert_eq "$(calls)" "notify ~/.config/nvim: not updated, local changes conflict with upstream
notify ~/.config/nvim: not updated, local changes conflict with upstream"
}

test_update_keeps_local_commits_that_diverge_from_upstream_and_notifies() {
    push_upstream nvim init.lua v2
    print local >~/.config/nvim/lazy-lock.json
    git -C ~/.config/nvim commit -qam local
    local before=$(head_of ~/.config/nvim)
    dotfiles update && fail "exit 0, expected a failure"
    assert_eq $(head_of ~/.config/nvim) $before
    assert_eq "$(calls)" "notify ~/.config/nvim: not updated, local commits diverge from upstream"
}

test_update_leaves_unpushed_local_commits_alone_silently() {
    print local >~/.config/nvim/init.lua
    git -C ~/.config/nvim commit -qam local
    local before=$(head_of ~/.config/nvim) output
    output=$(dotfiles update) || fail "exit $?"
    assert_eq "$output" ""
    assert_eq $(head_of ~/.config/nvim) $before
    assert_eq "$(calls)" ""
}

test_update_logs_an_unreachable_remote_without_notifying() {
    git -C ~/.config/nvim remote set-url origin $T/remotes/unreachable.git
    local before=$(head_of ~/.config/nvim) output
    output=$(dotfiles update) && fail "exit 0, expected a failure"
    [[ $output == *"~/.config/nvim: fetch failed"* ]] || fail "not logged: $output"
    assert_eq $(head_of ~/.config/nvim) $before
    assert_eq "$(calls)" ""
}

test_update_still_updates_the_others_when_a_repo_is_not_cloned() {
    rm -rf ~/.claude
    push_upstream nvim init.lua v2
    local output
    output=$(dotfiles update) && fail "exit 0, expected a failure"
    [[ $output == *"~/.claude: not cloned, run dotfiles install"* ]] || fail "not logged: $output"
    assert_eq $(head_of ~/.config/nvim) $(upstream_of nvim)
}

test_update_checks_out_the_submodule_commit_pulled_with_its_repo() {
    push_upstream workflow README.md v2
    git -C $T/other/.claude/mods/workflow pull -q
    git -C $T/other/.claude commit -qam "bump workflow"
    git -C $T/other/.claude push -q
    dotfiles update || fail "exit $?"
    assert_eq $(head_of ~/.claude/mods/workflow) $(upstream_of workflow)
}

test_update_keeps_a_local_edit_in_a_submodule_and_notifies() {
    push_upstream workflow README.md v2
    git -C $T/other/.claude/mods/workflow pull -q
    git -C $T/other/.claude commit -qam "bump workflow"
    git -C $T/other/.claude push -q
    print local >~/.claude/mods/workflow/README.md
    dotfiles update && fail "exit 0, expected a failure"
    assert_eq "$(<~/.claude/mods/workflow/README.md)" local
    assert_eq "$(calls)" "notify ~/.claude: submodules not updated, local changes conflict with upstream"
}

test_update_restores_the_nvim_plugins_when_their_lockfile_changes() {
    push_upstream nvim lazy-lock.json v2
    dotfiles update || fail "exit $?"
    assert_eq "$(calls)" "nvim --headless +Lazy! restore +qa"
}

test_update_leaves_the_nvim_plugins_alone_when_their_lockfile_is_unchanged() {
    push_upstream nvim init.lua v2
    dotfiles update || fail "exit $?"
    assert_eq "$(calls)" ""
}

test_update_runs_the_pulled_install_when_the_dotfiles_change() {
    push_upstream dotfiles zsh/zshrc v2
    dotfiles update || fail "exit $?"
    assert_eq "$(calls)" "dotfiles install at $(upstream_of dotfiles)"
}

test_update_leaves_everything_alone_while_another_update_runs() {
    zmodload zsh/system
    mkdir -p ~/.local/state/dotfiles && : >>~/.local/state/dotfiles/lock
    local lock before=$(head_of ~/.config/nvim) output
    zsystem flock -f lock ~/.local/state/dotfiles/lock
    push_upstream nvim init.lua v2
    output=$(dotfiles update 2>&1) || fail "exit $?"
    assert_eq "$output" "dotfiles: an update is already running"
    assert_eq $(head_of ~/.config/nvim) $before
}

test_update_leaves_a_branch_without_upstream_alone_without_notifying() {
    git -C ~/.config/nvim checkout -qb experiment
    local before=$(head_of ~/.config/nvim) output
    output=$(dotfiles update) || fail "exit $?"
    assert_eq "${output#* * }" "~/.config/nvim: not updated, branch experiment has no upstream"
    assert_eq $(head_of ~/.config/nvim) $before
    assert_eq "$(calls)" ""
}
