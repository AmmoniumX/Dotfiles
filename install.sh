#!/bin/bash
set -euo pipefail

_root_dir="$(cd "$(dirname "$(realpath "$0")")" && pwd)"
DRY_RUN=false
BACKUP_DIR="${_root_dir}/.backups/$(date +%Y-%m-%d_%H-%M-%S)"

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

if ! command -v stow >/dev/null 2>&1; then
    echo "Error: GNU Stow is required but not installed (e.g. 'sudo pacman -S stow')." >&2
    exit 1
fi

# Colors
COLOR_RESET=$(tput sgr0)
COLOR_YELLOW=$(tput setaf 3)
COLOR_CYAN=$(tput setaf 6)

cd "$_root_dir"

# Ask stow what it would do first. Anything it would refuse to overwrite -
# a real file/dir in the way, or a foreign symlink stow doesn't recognize
# as its own (e.g. one left by the old install.sh) - gets moved into a
# timestamped backup so the real run can proceed without prompts.
conflicts=()
while IFS= read -r rel; do
    conflicts+=("$rel")
done < <(stow -n -v -t "$HOME" . 2>&1 | grep -oP '(?:over existing target \K[^ ]+(?= since neither a link nor a directory)|existing target is not owned by stow: \K.+)' || true)

if [ "${#conflicts[@]}" -gt 0 ]; then
    for rel in "${conflicts[@]}"; do
        target_path="$HOME/$rel"
        echo "${COLOR_YELLOW}BACKUP:${COLOR_RESET} $target_path -> $BACKUP_DIR/$rel"
        if ! $DRY_RUN; then
            backup_dest="$BACKUP_DIR/$rel"
            mkdir -p "$(dirname "$backup_dest")"
            mv "$target_path" "$backup_dest" || { echo "Error: Failed to back up $target_path" >&2; exit 1; }
        fi
    done
fi

if $DRY_RUN; then
    echo "This was a dry run. No changes were made."
    exit 0
fi

echo "${COLOR_CYAN}Running stow...${COLOR_RESET}"
stow -v -t "$HOME" .

# greetd's config lives in /etc, not $HOME, so it's excluded from the stow
# package (see .stow-local-ignore) and deployed here instead via sudo cp.
# Files are world-readable (644), so reading the current /etc/greetd
# contents for the backup diff doesn't need sudo - only writing does.
GREETD_SRC="$_root_dir/ignore/greetd"
GREETD_DST="/etc/greetd"
declare -A GREETD_OWNERS=(
    [config.toml]="root:root"
    [environments]="root:root"
    [gtkgreet.css]="greeter:greeter"
)

read -rp "Do you want to deploy the greetd config to ${GREETD_DST}? (requires sudo) [y/N]: " response
if [[ ( "$response" =~ ^[Yy]$ ) && ( -d "$GREETD_SRC" ) ]]; then
    echo "${COLOR_CYAN}Deploying greetd config to ${GREETD_DST}...${COLOR_RESET}"
    for f in "${!GREETD_OWNERS[@]}"; do
        src="$GREETD_SRC/$f"
        dst="$GREETD_DST/$f"
        [ -f "$src" ] || continue

        if [ -e "$dst" ] && ! /usr/bin/cmp -s "$src" "$dst"; then
            backup_dest="$BACKUP_DIR/etc/greetd/$f"
            echo "${COLOR_YELLOW}BACKUP:${COLOR_RESET} $dst -> $backup_dest"
            mkdir -p "$(dirname "$backup_dest")"
            /usr/bin/cp -p "$dst" "$backup_dest"
        fi

        sudo /usr/bin/cp "$src" "$dst"
        sudo chown "${GREETD_OWNERS[$f]}" "$dst"
        sudo chmod 644 "$dst"
    done
fi

echo "Installation complete."

read -rp "Do you want to configure git globals for delta pager? [y/N]: " response
if [[ "$response" =~ ^[Yy]$ ]]; then
    set -x
    git config --global core.pager delta
    git config --global interactive.diffFilter 'delta --color-only'
    git config --global delta.navigate true
    git config --global delta.dark true
    git config --global delta.line-numbers true
    git config --global delta.line-numbers-left-format ''
    git config --global delta.file-decoration-style 'gray ol ul'
    git config --global delta.hunk-header-decoration-style 'omit'
    git config --global merge.conflictStyle zdiff3
    { set +x; } 2>/dev/null
else
    echo "Skipped."
fi

echo "Done."
