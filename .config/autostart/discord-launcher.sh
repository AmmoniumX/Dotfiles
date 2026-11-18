#!/bin/bash
# Launch the newest installed Discord app directly, falling back to /usr/bin/discord if none is installed.

DISCORD_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/discord"

while IFS= read -r dir; do
    if [ -x "$dir/Discord" ]; then
        exec "$dir/Discord" "$@"
    fi
done < <(find "$DISCORD_CONFIG" -maxdepth 1 -type d -name 'app-*' 2>/dev/null | sort -Vr)

exec /usr/bin/discord "$@"
