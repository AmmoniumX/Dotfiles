#!/usr/bin/env bash

set -euo pipefail

_root_dir="$(dirname "$(realpath "$0")")"
DRY_RUN=false
BACKUP_DIR=${_root_dir}"/.backups/$(date +%Y-%m-%d_%H-%M-%S)"
EXCLUDE_FILES=(".gitignore" "install.sh" "README.md" "GEMINI.md")
EXCLUDE_DIRS=(".git" ".backups")

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

# Colors
COLOR_RESET=$(tput sgr0)
COLOR_GREEN=$(tput setaf 2)
COLOR_YELLOW=$(tput setaf 3)
COLOR_CYAN=$(tput setaf 6)

_install() {
    local src_path
    src_path="$(realpath "$1")"
    if [ "$src_path" == "$_root_dir" ]; then
        return
    fi
    local relative_path="${src_path#$_root_dir}"
    local target_path="$HOME$relative_path"

    if [ -L "$target_path" ] && [ "$(readlink "$target_path")" == "$src_path" ]; then
        echo "${COLOR_GREEN}EXISTING LINK:${COLOR_RESET} $target_path"
    else
        if [ -e "$target_path" ]; then
            echo "${COLOR_YELLOW}BACKUP:${COLOR_RESET} $target_path -> $BACKUP_DIR"
            if ! $DRY_RUN; then
                mkdir -p "$BACKUP_DIR"
                mv "$target_path" "$BACKUP_DIR" || { echo "Error: Failed to back up $target_path" >&2; exit 1; }
            fi
        fi
        local target_dir="$(dirname "$target_path")"
        if [ ! -d "$target_dir" ]; then
          echo "${COLOR_CYAN}CREATE DIRECTORY:${COLOR_RESET} $target_dir"
          if ! $DRY_RUN; then
            mkdir -p "$target_dir" || { echo "Error: Failed to create directory for $target_path" >&2; exit 1; }
          fi
        fi
        echo "${COLOR_CYAN}LINK:${COLOR_RESET} $src_path -> $target_path"
        if ! $DRY_RUN; then
            ln -sf "$src_path" "$target_path" || { echo "Error: Failed to create symlink $target_path" >&2; exit 1; }
        fi
    fi
}

find_excludes_dirs=()
for item in "${EXCLUDE_DIRS[@]}"; do
    find_excludes_dirs+=(-path "./$item/*" -o)
done

find_excludes_files=()
for item in "${EXCLUDE_FILES[@]}"; do
    find_excludes_files+=(-name "$item" -o)
done

find . \( "${find_excludes_dirs[@]:0:${#find_excludes_dirs[@]}-1}" \) -prune -o \( "${find_excludes_files[@]:0:${#find_excludes_files[@]}-1}" \) -prune -o -type f -print | while read -r f; do
    _install "$f"
done


echo "Installation complete."
if $DRY_RUN; then
    echo "This was a dry run. No changes were made."
fi
