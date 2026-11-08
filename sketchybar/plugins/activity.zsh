#!/usr/bin/env zsh
# Opens Activity Monitor on the tab named $1 (CPU or Memory) by clicking its button, not with a
# shortcut: cmd-1 and cmd-2 open the CPU Usage and CPU History windows. Needs the Accessibility
# permission (README).

emulate -L zsh

open -a 'Activity Monitor'
osascript - $1 <<'APPLESCRIPT'
on run argv
    tell application "System Events" to tell process "Activity Monitor"
        repeat 20 times
            if (count of windows) > 0 then exit repeat
            delay 0.2
        end repeat
        tell window "Activity Monitor"
            click (first UI element of entire contents whose role is "AXRadioButton" and title is (item 1 of argv))
        end tell
    end tell
end run
APPLESCRIPT
