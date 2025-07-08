#!/usr/bin/env bash

set -euo pipefail

_root_dir="$(dirname "$(realpath "$0")")"
DRY_RUN=false
BACKUP_DIR=${_root_dir}"/.backups/$(date +%Y-%m-%d_%H-%M-%S)"
EXCLUDE_LIST=(".git" ".gitignore" "install.sh" "README.md")

usage() {
    echo "Usage: $0 [-d]"
    echo "  -d: Dry run - print what would be done without actually making changes."
    exit 1
}

while getopts ":d" opt; do
  case ${opt} in
    d )
      DRY_RUN=true
      ;;
    ? )
      usage
      ;;
  esac
done

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
    local src_path
    src_path="$(realpath "$1")"
    local relative_path="${src_path#$_root_dir}"
    local target_path="$HOME$relative_path"

    if [ -d "$src_path" ]; then
        if [ ! -d "$target_path" ]; then
            echo "CREATE_DIR: $target_path"
            if ! $DRY_RUN; then
                mkdir -p "$target_path" || { echo "Error: Failed to create directory $target_path" >&2; exit 1; }
            fi
        fi
        for f in "$src_path"/* "$src_path"/.*; do
            [ -e "$f" ] || continue
            [ -L "$f" ] && continue
            local _basename
            _basename=$(basename "$f")
            [[ "$_basename" == "." || "$_basename" == ".." ]] && continue
            _install "$f"
        done
    elif [ -f "$src_path" ]; then
        if [ -L "$target_path" ] && [ "$(readlink "$target_path")" == "$src_path" ]; then
            echo "EXISTING LINK: $target_path"
        else
            if [ -e "$target_path" ]; then
                echo "BACKUP: $target_path -> $BACKUP_DIR"
                if ! $DRY_RUN; then
                    mkdir -p "$BACKUP_DIR"
                    mv "$target_path" "$BACKUP_DIR" || { echo "Error: Failed to back up $target_path" >&2; exit 1; }
                fi
            fi
            echo "LINK: $src_path -> $target_path"
            if ! $DRY_RUN; then
                ln -sf "$src_path" "$target_path" || { echo "Error: Failed to create symlink $target_path" >&2; exit 1; }
            fi
        fi
    fi
}

for f in ./* ./.*; do
    [ -e "$f" ] || continue
    [ -L "$f" ] && continue
    _basename=$(basename "$f")
    is_excluded "$_basename" && continue
    _install "$f"
done

echo "Installation complete."
if $DRY_RUN; then
    echo "This was a dry run. No changes were made."
fi
