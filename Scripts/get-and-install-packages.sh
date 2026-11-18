#!/bin/bash
set -e

# AUR and Pacman gists (managed through pug)
GIST_NAT=ddc73c4b8d300ce949bcd734a65323d7
GIST_AUR=11c1f6bdf64eb6f10fe7b0aceffe4ec8

PACMAN_GIST_URL="https://gist.github.com/AmmoniumX/"$GIST_NAT"/raw/pacman-list.pkg"
AUR_GIST_URL="https://gist.github.com/AmmoniumX/"$GIST_AUR"/raw/aur-list.pkg"

# Use paru as AUR helper and pacman wrapper
install_paru() {
  echo "Installing paru..."
  git clone https://aur.archlinux.org/paru-bin.git "$WORKDIR/paru-bin"
  (cd "$WORKDIR/paru-bin" && makepkg -si)
  echo "Paru installation done."
}

check_command() {
  command -v "$1" >/dev/null 2>&1
}

has_cachyos_repos() {
  pacman-conf --repo-list | grep -q '^cachyos'
}

# Cannot run as root
[[ $EUID -ne 0 ]] || { echo "ERROR: Cannot run as root" >&2; exit 1; }

WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT

if [ -f /etc/pug ]; then
  sudo cp /etc/pug /etc/pug.old
fi

echo "GIST_NAT="$GIST_NAT"
GIST_AUR="$GIST_AUR | sudo tee /etc/pug

# Ensure dependencies
check_command pacman || { echo "ERROR: Pacman not found" >&2; exit 1; }
echo "Updating package database..."
sudo pacman -Syu
echo "Installing setup dependencies..."
sudo pacman -S --needed git base-devel
check_command paru || install_paru

# Enable CachyOS repositories
if ! has_cachyos_repos; then
  echo "Adding CachyOS repositories..."
  curl -LfsS https://mirror.cachyos.org/cachyos-repo.tar.xz -o "$WORKDIR/cachyos-repo.tar.xz"
  tar xvf "$WORKDIR/cachyos-repo.tar.xz" -C "$WORKDIR"
  (cd "$WORKDIR/cachyos-repo" && sudo ./cachyos-repo.sh)
fi

# Download files
echo "Downloading package lists..."
curl -LfsS "$PACMAN_GIST_URL" > "$WORKDIR/pacman-list.pkg"
curl -LfsS "$AUR_GIST_URL" | grep -v -- -debug > "$WORKDIR/aur-list.pkg"

echo "Installing packages from official repos..."
paru -S --repo --needed -- $(cat "$WORKDIR/pacman-list.pkg")
echo "Installing packages from AUR..."
paru -S --aur --needed -- $(cat "$WORKDIR/aur-list.pkg")

echo "Installation Complete!"
