#!/bin/bash
# /usr/bin/discord always re-runs updater_bootstrap on launch, which needs
# network access and gets stuck (zenity "downloading" dialog) if DNS isn't
# up yet, e.g. at session autostart. Skip it: exec the newest already
# installed app-<version>/Discord binary directly, falling back to the
# stock bootstrap path only if none is found.

DISCORD_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/discord"

while IFS= read -r dir; do
    if [ -x "$dir/Discord" ]; then
        exec "$dir/Discord" "$@"
    fi
done < <(find "$DISCORD_CONFIG" -maxdepth 1 -type d -name 'app-*' 2>/dev/null | sort -Vr)

exec /usr/bin/discord "$@"
