#!/bin/bash
# Prints memory usage percentage every 2s.
while true; do
    total=0
    avail=0
    while read -r key value _; do
        case "$key" in
            MemTotal:) total=$value ;;
            MemAvailable:) avail=$value ;;
        esac
    done < /proc/meminfo
    if [ "$total" -gt 0 ]; then
        echo $(( (100 * (total - avail)) / total ))
    else
        echo 0
    fi
    sleep 2
done
