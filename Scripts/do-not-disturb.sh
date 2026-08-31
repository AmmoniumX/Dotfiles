#!/usr/bin/env bash
#
# dnd — temporarily silence mako notifications
#
#   dnd on       silence notifications (still recorded in mako's history)
#   dnd off      resume notifications
#   dnd toggle   flip to the other state (default if no argument given)
#   dnd status   print "on" or "off"
#
# "on" means do-not-disturb is on, i.e. you see nothing.
#
# Requires this block in your mako config:
#
#   [mode=do-not-disturb]
#   invisible=1

set -uo pipefail

MODE=do-not-disturb
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/mako/config"

die()  { printf 'dnd: %s\n' "$*" >&2; exit 1; }
warn() { printf 'dnd: %s\n' "$*" >&2; }

usage() {
	sed -n '3,12p' "$0" | sed 's/^# \?//'
	exit "${1:-0}"
}

command -v makoctl >/dev/null 2>&1 || die "makoctl not found; is mako installed?"

require_mako() {
	makoctl mode >/dev/null 2>&1 && return
	die "can't reach mako. If you masked the unit, undo it with:
       systemctl --user unmask --now mako.service"
}

check_config() {
	if [ ! -r "$CONFIG" ]; then
		warn "no readable config at $CONFIG — the mode will have no effect"
		return
	fi
	grep -q "^\[mode=$MODE\]" "$CONFIG" && return
	warn "no [mode=$MODE] block in $CONFIG.
       The mode will be set but nothing will be hidden. Add:

           [mode=$MODE]
           invisible=1

       then run: makoctl reload"
}

current() {
	if makoctl mode 2>/dev/null | grep -qx "$MODE"; then
		echo on
	else
		echo off
	fi
}

silence() {
	require_mako
	check_config
	makoctl mode -a "$MODE" >/dev/null || die "failed to set mode"
	echo "do-not-disturb on"
}

resume() {
	require_mako
	makoctl mode -r "$MODE" >/dev/null || die "failed to clear mode"
	echo "do-not-disturb off"
}

case "${1:-toggle}" in
	on)     silence ;;
	off)    resume ;;
	toggle) [ "$(current)" = on ] && resume || silence ;;
	status) current ;;
	-h|--help|help) usage ;;
	*) warn "unknown command: $1"; usage 1 ;;
esac
