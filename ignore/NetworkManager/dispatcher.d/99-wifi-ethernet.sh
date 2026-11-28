#!/bin/bash
# NetworkManager dispatcher: turn the Wi-Fi radio off while ethernet is connected, and back on once it isn't.

MARKER=/var/lib/NetworkManager/wifi-off-for-ethernet

ethernet_connected() {
    nmcli -t -f TYPE,STATE device 2>/dev/null | grep -q '^ethernet:connected'
}

nm_asleep() {
    [ "$(nmcli -t -f STATE general 2>/dev/null)" = asleep ]
}

if [ "$2" = resume ]; then
    for _ in $(seq 30); do
        nm_asleep || break
        sleep 1
    done
fi
nm_asleep && exit 0

case "$2" in
    up)
        if ethernet_connected && [ "$(nmcli radio wifi)" = enabled ]; then
            nmcli radio wifi off && touch "$MARKER"
        fi
        ;;
    down|hostname|connectivity-change|resume)
        if [ -e "$MARKER" ] && ! ethernet_connected; then
            nmcli radio wifi on && [ "$(nmcli radio wifi)" = enabled ] && rm -f "$MARKER"
        fi
        ;;
esac
