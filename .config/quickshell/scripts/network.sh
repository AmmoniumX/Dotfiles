#!/bin/bash
# Prints "wifi|<name>", "ethernet|<name>" or "disconnected" every 3s.
while true; do
    line=$(nmcli -t -f TYPE,DEVICE,STATE,NAME connection show --active 2>/dev/null \
        | grep -E '^(802-11-wireless|802-3-ethernet):' | head -1)
    if [ -n "$line" ]; then
        type="${line%%:*}"
        name="${line##*:}"
        if [ "$type" = "802-11-wireless" ]; then
            echo "wifi|${name}"
        else
            echo "ethernet|${name}"
        fi
    else
        echo "disconnected|"
    fi
    sleep 3
done
