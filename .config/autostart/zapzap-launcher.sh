#!/bin/bash
# Launch ZapZap from the native package if installed, otherwise from Flatpak.

command -v zapzap >/dev/null 2>&1 && exec zapzap "$@"
exec flatpak run com.rtosta.zapzap "$@"
