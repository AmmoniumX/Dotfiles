#!/bin/bash
# Prints CPU usage percentage every 2s, computed from /proc/stat deltas.
prev_idle=0
prev_total=0

read_stat() {
    read -r _ user nice system idle iowait irq softirq steal _ _ < /proc/stat
    idle_all=$((idle + iowait))
    total=$((user + nice + system + idle_all + irq + softirq + steal))
    echo "$idle_all $total"
}

read prev_idle prev_total < <(read_stat)

while true; do
    sleep 2
    read idle total < <(read_stat)
    diff_idle=$((idle - prev_idle))
    diff_total=$((total - prev_total))
    prev_idle=$idle
    prev_total=$total
    if [ "$diff_total" -gt 0 ]; then
        echo $(( (100 * (diff_total - diff_idle)) / diff_total ))
    else
        echo 0
    fi
done
