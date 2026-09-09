#!/bin/bash
# Prints backlight percentage immediately whenever it changes.
print_percent() {
    brightnessctl -c backlight -m 2>/dev/null | cut -d',' -f4 | tr -d '%'
}

print_percent
udevadm monitor --udev --subsystem-match=backlight 2>/dev/null | grep --line-buffered '^UDEV' | while read -r _; do
    print_percent
done
