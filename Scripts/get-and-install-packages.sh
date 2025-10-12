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
  git clone https://aur.archlinux.org/paru-bin.git paru-bin
  cd paru-bin
  makepkg -si
  echo "Paru installation done."
}

check_command() {
  command -v "$1" >/dev/null 2>&1
}

check_package() {
  pacman -Qq "$1" > /dev/null 2>&1
}

# Cannot run as root
[[ $EUID -ne 0 ]] || (echo "ERROR: Cannot run as root" >2; exit)

if [ -f /etc/pug ]; then
  sudo cp /etc/pug /etc/pug.old
fi

echo "GIST_NAT="$GIST_NAT"
GIST_AUR="$GIST_AUR | sudo tee /etc/pug

# Ensure dependencies
check_command pacman || (echo "ERROR: Pacman not found" >2; exit)
echo "Updating package database..."
sudo pacman -Syu
if ! check_package git; then
  echo "Installing setup dependencies..."
  sudo pacman -S git --needed
fi
check_command paru || install_paru

# Download files
echo "Downloading package lists..."
curl -LfsS "$PACMAN_GIST_URL" > pacman-list.pkg
curl -LfsS "$AUR_GIST_URL" | grep -v -- -debug > aur-list.pkg

echo "Installing packages from official repos..."
paru -S --repo --needed -- $(cat pacman-list.pkg) 
echo "Installing packages from AUR..."
paru -S --aur --needed -- $(cat aur-list.pkg)
