# Arch Linux Dotfiles

A collection of Arch Linux dotfiles, packages, and scripts. For personal use. Installs NVIDIA packages, may not work with AMD/Intel GPUs.

## Installation

1. Clone the repository:
```bash
git clone https://github.com/AmmoniumX/Dotfiles.git && cd ./Dotfiles
```

2. Download and installed packages:
```bash
./Scripts/get-and-install-packages.sh
```
(Note: this installs *all* official repository and AUR packages, including apps and NVIDIA drives. TODO: Create a separate list of required dependencies only)

3. Install dotfiles (requires [GNU Stow](https://www.gnu.org/software/stow/), e.g. `sudo pacman -S stow`)
```bash
./install.sh
```
This backs up any conflicting existing files under `.backups/<timestamp>` and then symlinks everything into `$HOME` via `stow`. Pass `-d` to preview the changes first (dry run).

Then, restart your shell or source the appropriate file (`.bashrc` or `.zshrc`).

## Credits

- [yurihikari/garuda-hyprdots](https://github.com/yurihikari/garuda-hyprdots): Dotfiles, scripts and background images for hyprland, waybar, and rofi
- [basecamp/omarchy](https://github.com/basecamp/omarchy): Fuzzy package install script
- [MahdiMirzadeh/qbittorrent](https://github.com/MahdiMirzadeh/qbittorrent): Qbittorrent dracula theme
