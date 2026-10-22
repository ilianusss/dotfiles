# dotfiles install

test_install_clones_a_missing_repo_keeping_its_ssh_remote() {
    rm -rf ~/.config/nvim
    dotfiles install || fail "exit $?"
    assert_eq $(head_of ~/.config/nvim) $(upstream_of nvim)
    assert_eq $(git -C ~/.config/nvim config remote.origin.url) git@github.com:ilianusss/nvim.git
}

test_install_clones_a_missing_repo_with_its_submodules() {
    rm -rf ~/.claude
    dotfiles install || fail "exit $?"
    assert_eq $(head_of ~/.claude/mods/workflow) $(upstream_of workflow)
    assert_eq $(git -C ~/.claude/mods/workflow config remote.origin.url) git@github.com:ilianusss/workflow.git
}

test_install_leaves_a_folder_that_is_not_a_clone_and_says_what_to_do() {
    rm -rf ~/.claude
    mkdir ~/.claude && print mine >~/.claude/history
    local output
    output=$(dotfiles install 2>&1) && fail "exit 0, expected a failure"
    [[ $output == *"~/.claude exists but is not a clone of git@github.com:ilianusss/.claude.git: move it away, then rerun dotfiles install"* ]] || fail "not reported: $output"
    assert_eq "$(<~/.claude/history)" mine
}

test_install_clones_oh_my_zsh_and_its_plugins_when_missing() {
    rm -rf ~/.oh-my-zsh
    dotfiles install || fail "exit $?"
    assert_eq "$(<~/.oh-my-zsh/oh-my-zsh.sh)" "oh-my-zsh.sh v1"
    local plugin
    for plugin in zsh-autosuggestions zsh-completions zsh-syntax-highlighting; do
        assert_eq "$(<~/.oh-my-zsh/custom/plugins/$plugin/$plugin.zsh)" "$plugin.zsh v1"
    done
}

test_install_links_every_file_creating_missing_folders() {
    dotfiles install || fail "exit $?"
    assert_eq "$(readlink ~/.zshrc)" $DOTFILES/zsh/zshrc
    assert_eq "$(readlink ~/.config/ghostty/config.ghostty)" $DOTFILES/ghostty/config.ghostty
    assert_eq "$(readlink ~/.theme)" $DOTFILES/theme
}

test_install_moves_a_file_or_folder_in_the_way_to_a_backup() {
    print mine >~/.zshrc
    mkdir ~/.theme && print mine >~/.theme/palette
    dotfiles install || fail "exit $?"
    assert_eq "$(readlink ~/.zshrc)" $DOTFILES/zsh/zshrc
    assert_eq "$(readlink ~/.theme)" $DOTFILES/theme
    assert_eq "$(cat ~/.zshrc.bak.*)" mine
    assert_eq "$(cat ~/.theme.bak.*/palette)" mine
}

test_install_twice_changes_nothing_the_second_time() {
    dotfiles install >/dev/null || fail "exit $?"
    local output
    output=$(dotfiles install) || fail "exit $?"
    assert_eq "$output" ""
    assert_eq "$(print -l ~/*.bak.*(DN) ~/.config/ghostty/*.bak.*(DN))" ""
}

test_install_applies_the_theme_then_schedules_the_update() {
    dotfiles install || fail "exit $?"
    assert_eq "$(calls)" "theme apply
schedule"
}
