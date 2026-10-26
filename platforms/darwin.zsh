# macOS: `dotfiles update` every 15 minutes and at login as a launchd agent, notifications from
# osascript, and the window manager's configs.

LINKS+=(
    aerospace/aerospace.toml ~/.config/aerospace/aerospace.toml
    sketchybar               ~/.config/sketchybar
    borders/bordersrc        ~/.config/borders/bordersrc
    karabiner                ~/.config/karabiner
)

LABEL=com.github.ilianusss.dotfiles
PLIST=~/Library/LaunchAgents/$LABEL.plist

schedule() {
    local plist="<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
<dict>
    <key>Label</key><string>$LABEL</string>
    <key>ProgramArguments</key>
    <array><string>$DOTFILES/bin/dotfiles</string><string>update</string></array>
    <key>EnvironmentVariables</key>
    <dict><key>PATH</key><string>$PATH</string></dict>
    <key>StartInterval</key><integer>900</integer>
    <key>RunAtLoad</key><true/>
    <key>StandardOutPath</key><string>$STATE/update.log</string>
    <key>StandardErrorPath</key><string>$STATE/update.log</string>
</dict>
</plist>"
    # Reloading the agent stops the update it may be running: only when the agent changed
    [[ -f $PLIST && $(<$PLIST) == "$plist" ]] && launchctl print gui/$UID/$LABEL &>/dev/null && return
    mkdir -p ${PLIST:h} $STATE
    print -r -- $plist >$PLIST
    launchctl bootout gui/$UID/$LABEL 2>/dev/null
    launchctl bootstrap gui/$UID $PLIST || return
    print -r -- "scheduled dotfiles update every 15 minutes, log in ${(D)STATE}/update.log"
}

notify() {
    osascript -e 'on run argv' -e 'display notification (item 1 of argv) with title "dotfiles"' \
        -e 'end run' $1 >/dev/null
}
