#!/bin/bash
# Prints "off", "on" or "connected" every 3s.
while true; do
    powered=$(bluetoothctl show 2>/dev/null | awk -F': ' '/Powered:/{print $2; exit}')
    if [ "$powered" = "yes" ]; then
        connected=$(bluetoothctl devices Connected 2>/dev/null | wc -l)
        if [ "$connected" -gt 0 ]; then
            echo "connected"
        else
            echo "on"
        fi
    else
        echo "off"
    fi
    sleep 3
done
