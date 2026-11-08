#!/usr/bin/env zsh
# A coffee while sleep is disabled (the coffee alias of zsh/zshrc: the Mac stays awake, even with
# the lid closed), a dimmed tisane otherwise. With "toggle", switches to the other first: pmset
# needs root, given without a password by a sudoers rule (README). Without the rule, macOS asks for
# an administrator in its own dialog, and cancelling it changes nothing.

emulate -L zsh

awake() { pmset -g | grep -q 'SleepDisabled[[:space:]]*1' }

if [[ $1 == toggle ]]; then
    awake && value=0 || value=1
    sudo -n pmset -a disablesleep $value 2>/dev/null ||
        osascript -e "do shell script \"pmset -a disablesleep $value\" with administrator privileges" &>/dev/null
fi

if awake; then sketchybar --set $NAME icon=$'󰅶' icon.highlight=off
else sketchybar --set $NAME icon=$'󰶞' icon.highlight=on
fi
