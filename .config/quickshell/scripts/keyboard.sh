#!/bin/bash
# Prints the active niri keyboard layout short-name immediately whenever it changes.
get_layout() {
    "$HOME/.config/niri/scripts/get_keyboard"
}

get_layout
niri msg -j event-stream 2>/dev/null | grep --line-buffered -E '"KeyboardLayout(Switched|sChanged)"' | while read -r _; do
    get_layout
done
