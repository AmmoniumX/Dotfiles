#!/bin/bash
# Prints "volume|muted" immediately whenever it changes.
print_state() {
    vol=$(pamixer --get-volume 2>/dev/null)
    mute=$(pamixer --get-mute 2>/dev/null)
    echo "${vol:-0}|${mute:-false}"
}

print_state
pactl subscribe 2>/dev/null | grep --line-buffered -E "on (sink|server) " | while read -r _; do
    print_state
done
