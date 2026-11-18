#!/usr/bin/env bash

[ -n "$1" ] || { echo "Usage: $(basename "$0") <brightness, e.g. 0.8>" >&2; exit 1; }
gammastep -O 4500 -b "$1"
