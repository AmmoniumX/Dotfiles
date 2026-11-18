#!/bin/bash
# NetworkManager dispatcher: turn the Wi-Fi radio off while ethernet is connected, and back on once it isn't.

MARKER=/var/lib/NetworkManager/wifi-off-for-ethernet

ethernet_connected() {
    nmcli -t -f TYPE,STATE device 2>/dev/null | grep -q '^ethernet:connected'
}

case "$2" in
    up)
        if ethernet_connected && [ "$(nmcli radio wifi)" = enabled ]; then
            nmcli radio wifi off && touch "$MARKER"
        fi
        ;;
    down|hostname|connectivity-change)
        if [ -e "$MARKER" ] && ! ethernet_connected; then
            nmcli radio wifi on && rm -f "$MARKER"
        fi
        ;;
esac
