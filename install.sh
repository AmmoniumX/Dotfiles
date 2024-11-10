#!/usr/bin/env bash

_root_dir="$(dirname "$(realpath "$0")")"

_install() {

    _absolute_path="$(realpath "$1")"
    _relative_path="${_absolute_path#$_root_dir}"
    _target_path="$HOME$_relative_path"

    if [ -d "$1" ]; then
        #echo "$1 is directory"
        # Copy directory structure to home directory
        if [ ! -d "$_target_path" ]; then
            echo "Making dir $_target_path"
            mkdir -p "$_target_path"
        fi
        for f in "$1"/* "$1"/.*; do
            [ -e "$f" ] || continue
            [ -L "$f" ] && continue
            _install "$f"
        done

    else

    [ -f "$1" ] || return

    echo "Creating symlink $_absolute_path -> $_target_path"
    ln -sf "$_absolute_path" "$_target_path"
    fi
}

for f in ./* ./.*; do
    [ -e "$f" ] || continue
    [ -L "$f" ] && continue
    _basename=$(basename "$f")
    [[ "$_basename" == ".git" || "$_basename" == "install.sh" ]] && continue
    _install "$f"
done
