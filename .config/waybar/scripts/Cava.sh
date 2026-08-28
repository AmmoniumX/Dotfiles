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

statusfile="/tmp/cava-waybar-status"
statustmp="${statusfile}.tmp"
echo "Stopped||" > "$statusfile"
(
  while true; do
    playerctl metadata --format '{{status}}|{{title}}|{{artist}}' 2>/dev/null > "$statustmp" || echo "Stopped||" > "$statustmp"
    mv -f "$statustmp" "$statusfile"
    sleep 0.5
  done
) &
status_pid=$!
trap 'kill "$status_pid" 2>/dev/null; rm -f "$statusfile" "$statustmp"' EXIT

max_title=40
marquee_width=15
advance_every=15

icon_play=$''
icon_pause=$''

marquee_pos=0
frame=0
prev_title=""

marquee_text() {
  local text="$1"
  local len=${#text}
  if [ "$len" -le "$marquee_width" ]; then
    printf '%-*s' "$marquee_width" "$text"
    return
  fi
  local looped="${text}   "
  local looplen=${#looped}
  local start=$(( marquee_pos % looplen ))
  local doubled="${looped}${looped}"
  printf '%s' "${doubled:$start:$marquee_width}"
}

# Pads/trims text to a fixed width so paused output is exactly as wide as
# playing output (bars-length + marquee_width + 2 separator spaces).
fixed_text() {
  local text="$1" width="$2"
  local len=${#text}
  if [ "$len" -le "$width" ]; then
    printf '%-*s' "$width" "$text"
  else
    printf '%s…' "${text:0:$((width - 1))}"
  fi
}

{
  while true; do
    cava -p ~/.config/cava/config1 2>/dev/null
    sleep 0.2
  done
} | grep --line-buffered -E '^[0-9;]+$' | sed -u 's/;//g;s/0/▁/g;s/1/▂/g;s/2/▃/g;s/3/▄/g;s/4/▅/g;s/5/▆/g;s/6/▇/g;s/7/█/g;' | \
while IFS= read -r bars; do
  IFS='|' read -r status title artist < "$statusfile" 2>/dev/null
  if [ "${#title}" -gt "$max_title" ]; then
    title="${title:0:$max_title}"
  fi

  if [ "$title" != "$prev_title" ]; then
    marquee_pos=0
    frame=0
    prev_title="$title"
  fi

  case "$status" in
    Playing)
      frame=$((frame + 1))
      if [ $((frame % advance_every)) -eq 0 ]; then
        marquee_pos=$((marquee_pos + 1))
      fi
      half=$(( ${#bars} / 2 ))
      left="${bars:0:$half}"
      right="${bars:$half}"
      if [ -n "$title" ]; then
        echo "$icon_play ${left} $(marquee_text "$title") ${right}"
      else
        echo "$icon_play $bars"
      fi
      ;;
    Paused)
      width=$(( ${#bars} + marquee_width + 2 ))
      if [ -n "$title" ]; then
        echo "$icon_pause $(fixed_text "$title" "$width")"
      else
        echo "$icon_pause"
      fi
      ;;
    *)
      echo
      ;;
  esac
done
