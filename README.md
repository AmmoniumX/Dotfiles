# Linux Dotfiles

A collection of personal linux dotfiles, comes with an `install.sh` script.

The following programs are recommended to be installed on the system:
- eza
- bat
- fzf
- starship prompt

## Installation

1. Clone the repository:
```bash
git clone https://github.com/AmmoniumX/Dotfiles.git && cd ./Dotfiles
```

2. Download and installed required packages:
```bash
./Scripts/get-and-install-packages.sh
```

3. Install dotfiles
```bash
./install.sh
```

Then, restart your shell or source the appropriate file (`.bashrc` or `.zshrc`).

## Special Thanks

- [yurihikari/garuda-hyprdots](https://github.com/yurihikari/garuda-hyprdots): Dotfiles and scripts for hyprland, waybar, and rofi
- [basecamp/omarchy](https://github.com/basecamp/omarchy): Fuzzy package install script
- [MahdiMirzadeh/qbittorrent](https://github.com/MahdiMirzadeh/qbittorrent): Qbittorrent dracula theme
