#!/bin/bash
# NetworkManager dispatcher: disable Wi-Fi radio while a wired connection is up,
# re-enable it once ethernet disconnects.

INTERFACE=$1
STATUS=$2

is_ethernet() {
    [[ "$(nmcli -g GENERAL.TYPE device show "$INTERFACE" 2>/dev/null)" == "ethernet" ]]
}

case "$STATUS" in
    up)
        is_ethernet && nmcli radio wifi off
        ;;
    down)
        if is_ethernet; then
            # only turn wifi back on if no other ethernet device is still up
            still_up=0
            for dev in $(nmcli -t -f DEVICE,TYPE,STATE device | awk -F: '$2=="ethernet" && $3=="connected"{print $1}'); do
                [[ "$dev" != "$INTERFACE" ]] && still_up=1
            done
            [[ "$still_up" -eq 0 ]] && nmcli radio wifi on
        fi
        ;;
esac
