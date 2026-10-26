#!/usr/bin/env zsh
# Wi-Fi bars from the signal strength, an Ethernet icon when the internet goes through a wired port,
# crossed out (dimmed) with no connection. The signal comes from CoreWLAN, which needs no permission.

emulate -L zsh

wifi=$(networksetup -listallhardwareports | awk '/^Hardware Port: Wi-Fi$/ { getline; print $2 }')
ports=($(networksetup -listallhardwareports | awk '/^Device:/ { print $2 }'))
via=$(route -n get default 2>/dev/null | awk '/interface:/ { print $2 }')
rssi=$(osascript -l JavaScript -e 'ObjC.import("CoreWLAN"); $.CWWiFiClient.sharedWiFiClient.interface.rssiValue' 2>/dev/null)

off=off
if [[ -z $via ]]; then icon=$'󰤭' off=on
elif [[ $via != $wifi ]] && (( ${ports[(Ie)$via]} )); then icon=$'󰈀'
elif (( ${rssi:-0} >= 0 )); then icon=$'󰈀'
elif (( rssi >= -55 )); then icon=$'󰤨'
elif (( rssi >= -67 )); then icon=$'󰤥'
elif (( rssi >= -75 )); then icon=$'󰤢'
else icon=$'󰤟'
fi
sketchybar --set $NAME icon=$icon icon.highlight=$off
