#!/usr/bin/env bash

_root_dir="$(dirname "$(realpath "$0")")"
DRY_RUN=false
EXCLUDE_LIST=(".git" "install.sh")

is_excluded() {
    local item="$1"
    for exclude in "${EXCLUDE_LIST[@]}"; do
        if [[ "$item" == "$exclude" ]]; then
            return 0
        fi
    done
    return 1
}

_install() {
    _absolute_path="$(realpath "$1")"
    _relative_path="${_absolute_path#$_root_dir}"
    _target_path="$HOME$_relative_path"

    if [ -d "$1" ]; then
        if [ ! -d "$_target_path" ]; then
            echo "Creating directory $_target_path"
            $DRY_RUN || mkdir -p "$_target_path" || { echo "Error: Failed to create directory $_target_path" >&2; exit 1; }
        fi
        for f in "$1"/* "$1"/.*; do
            [ -e "$f" ] || continue
            [ -L "$f" ] && continue
            _basename=$(basename "$f")
            [[ "$_basename" == "." || "$_basename" == ".." ]] && continue
            _install "$f"
        done
    elif [ -f "$1" ]; then
        echo "Linking $_absolute_path -> $_target_path"
        $DRY_RUN || ln -sf "$_absolute_path" "$_target_path" || { echo "Error: Failed to create symlink $_target_path" >&2; exit 1; }
    fi
}

for f in ./* ./.*; do
    [ -e "$f" ] || continue
    [ -L "$f" ] && continue
    _basename=$(basename "$f")
    is_excluded "$_basename" && continue
    _install "$f"
done
