#!/bin/bash

lockfile="/tmp/cava-waybar.lock"
exec 9>"$lockfile"
flock 9

if pgrep -x cava >/dev/null; then
  killall cava
  for _ in $(seq 1 50); do
    pgrep -x cava >/dev/null || break
    sleep 0.1
  done
fi

while true; do
  cava -p ~/.config/cava/config1 2>/dev/null
  sleep 0.2
done | grep --line-buffered -E '^[0-9;]+$' | sed -u 's/;//g;s/0/▁/g;s/1/▂/g;s/2/▃/g;s/3/▄/g;s/4/▅/g;s/5/▆/g;s/6/▇/g;s/7/█/g;'
