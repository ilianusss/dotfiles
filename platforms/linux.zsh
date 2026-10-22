# Linux: `dotfiles update` every 15 minutes as a systemd user timer, notifications from notify-send.
# A distro that needs more gets platforms/linux-<ID from /etc/os-release>.zsh, which can source this.

UNITS=${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user

schedule() {
    mkdir -p $UNITS $STATE
    print -r -- "[Unit]
Description=Update the dotfiles and their repos

[Service]
Type=oneshot
Environment=PATH=$PATH
ExecStart=$DOTFILES/bin/dotfiles update
StandardOutput=append:$STATE/update.log
StandardError=append:$STATE/update.log" >$UNITS/dotfiles-update.service
    print -r -- "[Unit]
Description=Run dotfiles update every 15 minutes

[Timer]
OnStartupSec=1min
OnUnitActiveSec=15min

[Install]
WantedBy=timers.target" >$UNITS/dotfiles-update.timer
    systemctl --user daemon-reload && systemctl --user enable --now --quiet dotfiles-update.timer
}

notify() {
    command -v notify-send >/dev/null || return 0
    notify-send dotfiles $1
}
