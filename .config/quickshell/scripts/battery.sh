#!/bin/bash
# Prints "capacity|status" every 5s for the first battery found.

while true; do
    bat=$(find /sys/class/power_supply -maxdepth 1 -name 'BAT*' | head -1)
    if [ -n "$bat" ] && [ -r "$bat/capacity" ]; then
        capacity=$(<"$bat/capacity")
        status=$(<"$bat/status")
        echo "${capacity}|${status}"
    else
        echo "|"
    fi
    sleep 5
done
