# Ubuntu Setup Guide

How to get the niri desktop and apps from these dotfiles running on Ubuntu, in install order. The repo works on both Arch and Ubuntu; anything Arch-only (paru, CachyOS, the package-list script) is skipped here.

**Target: Ubuntu 26.04 LTS or newer.** 24.04 is too old for parts of this setup: e.g. its `fzf` (0.44) lacks the `fzf --fish`/`--zsh` integration the shell configs use, and many Wayland tools are missing. Phases 1-6 were run end to end on Ubuntu 26.10 with the duxlabs PPA; Phase 7 and the greetd path in Phase 8 were not.

---

## Phase 1: Base system and GPU

1. Install **Ubuntu Desktop** (not Server). It brings GDM (fallback login), GNOME (fallback session), PipeWire/WirePlumber (`wpctl`), NetworkManager, gnome-keyring and `xdg-desktop-portal-gnome` (niri's screencast portal).
2. Update:
   ```bash
   sudo apt update && sudo apt full-upgrade
   ```
3. NVIDIA: `sudo ubuntu-drivers list`, install the **open** variant (`nvidia-driver-XXX-open`), reboot, and confirm `cat /sys/module/nvidia_drm/parameters/modeset` prints `Y`.
4. Extra sources:
   ```bash
   sudo add-apt-repository multiverse        # steam, unrar
   sudo apt install flatpak
   flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
   ```

## Phase 2: Build tooling and the dotfiles

```bash
sudo apt install git stow build-essential curl wget pkg-config cargo
git clone --recurse-submodules https://github.com/AmmoniumX/Dotfiles.git ~/Projects/Dotfiles
cd ~/Projects/Dotfiles
./install.sh -d n   # dry run first
./install.sh nnnnn
```

The `nnnnn` argument answers the prompts in order:
- **biri configs:** `n` (skips stowing biri files and drops `biri-session` from greetd's environments).
- **greetd, polkit, NetworkManager, delta:** `n` for now; they're revisited in later phases.

The dry run lists stock files (e.g. `.bashrc`, `.profile`, `~/.config/niri/config.kdl`) that get moved to `.backups/<timestamp>/`. Stowing early means each app finds its config as soon as it's installed.

Prefer apt, the duxlabs PPA, Flatpak or upstream release binaries over building from source. Apt's `cargo` is recent enough for the one thing that still needs building (smirk, Phase 4); `rustup` isn't needed.

## Phase 3: Niri and the session plumbing

1. **Niri from the duxlabs PPA:**
   ```bash
   sudo add-apt-repository ppa:duxlabs/dux-repo
   sudo apt update
   apt policy niri          # must be >= 25.11: the config uses `include`
   sudo apt install niri
   ```
   The package provides `niri-session`, `niri.desktop`, `niri.service` and a default `niri-portals.conf`. The stowed `~/.config/xdg-desktop-portal/niri-portals.conf` overrides the default. Check the config with `niri validate`: options that only niri-git supports make it fail to load on the PPA's niri. With niri 26.04, comment out `on-xdg-activate "ignore"` in the steam_proton window rule as a local, untracked change (`git update-index --skip-worktree .config/niri/niri.config.kdl` keeps it out of `git status`).

   This is a third-party PPA: it can run code as root and updates on the maintainer's schedule. If niri breaks after an `apt upgrade`, check the PPA first.
2. **Session tools from the same PPA (and Ubuntu's repos):**
   ```bash
   sudo apt install quickshell xwayland-satellite cliphist matugen
   ```
   `quickshell`, `xwayland-satellite` and `matugen` come from dux-repo; `cliphist` is in Ubuntu's own repos.
3. **Portals, polkit, keyring:**
   ```bash
   sudo apt install xdg-desktop-portal-gnome xdg-desktop-portal-gtk xdg-desktop-portal-kde \
     polkit-kde-agent-1 gnome-keyring
   ```
   `~/.config/niri/scripts/polkit-agent` finds the KDE agent at its Ubuntu path automatically. `oo7-portal` in `niri-portals.conf` isn't needed; it falls back to gnome-keyring.
4. Log out, pick **Niri** in GDM, and confirm a working (bare) session.

## Phase 4: Desktop components

```bash
sudo apt install mako-notifier fuzzel rofi swaybg swaylock wlogout wl-clipboard moreutils \
  brightnessctl playerctl pamixer libnotify-bin mpv sound-theme-freedesktop \
  gammastep wob wtype wev imv nm-connection-editor blueman bluez hyprpicker
```

Don't install `waybar`: its package enables `waybar.service` globally for `graphical-session.target`, which shows a second bar next to Quickshell. If it's already installed, `sudo apt purge waybar` (purge also removes the global enable link).

`niri/scripts/screenlock` works with plain `swaylock`: it shows `~/.config/wallpapers/lockscreen.png` with the same ring colors. The blurred-screenshot look and clock appear only when swaylock-effects is installed, as on Arch.

apt's `rofi` is 2.0, which Mod+V needs for native Wayland. On an older release, change the bind to `cliphist list | fuzzel --dmenu | cliphist decode | ifne wl-copy`.

**smirk** (Mod+Period emoji picker) is the one tool built from source: there are no prebuilt binaries, and on Arch it comes from the AUR (`smirk-git`). The niri bind calls `smirk-toggle`, a small wrapper the AUR package ships, so install that too:
```bash
sudo apt install libgtk-4-dev libadwaita-1-dev
git clone https://github.com/Yiin/smirk.git ~/.local/src/smirk
cd ~/.local/src/smirk && cargo build --release --locked
sudo install -Dm755 target/release/smirk /usr/local/bin/smirk
sudo tee /usr/local/bin/smirk-toggle >/dev/null <<'EOF'
#!/bin/bash
gdbus call --session --dest lt.yiin.smirk --object-path /lt/yiin/smirk \
  --method org.freedesktop.Application.Activate '{}' >/dev/null 2>&1 \
  || exec smirk
EOF
sudo chmod 755 /usr/local/bin/smirk-toggle
cargo clean   # the build directory is ~400 MB
```

The bar's scripts need `nmcli`, `bluetoothctl`, `pactl`, `pamixer` and `brightnessctl`, all covered above. The systemd units call `qs`, `smirk` and `gammastep-indicator` by name, so `/usr/bin` and `/usr/local/bin` installs both work.

Enable the user units:
```bash
systemctl --user daemon-reload
systemctl --user enable quickshell.service smirk.service gammastep-indicator.service
systemctl --user list-unit-files mako.service   # niri.service.d wants it; write a small unit if missing
```

## Phase 5: Shell and terminal

```bash
sudo apt install fish zsh bash-completion foot fzf zoxide direnv eza bat ripgrep fd-find \
  git-delta tealdeer htop btop nvtop fastfetch ncdu trash-cli tmux lf plocate starship kitty unzip
# yazi: prebuilt binaries from its GitHub releases
curl -fsSLO https://github.com/sxyazi/yazi/releases/latest/download/yazi-x86_64-unknown-linux-musl.zip
unzip yazi-x86_64-unknown-linux-musl.zip && install -m755 yazi-x86_64-unknown-linux-musl/{yazi,ya} ~/.local/bin/
chsh -s /usr/bin/fish
```

- `bat` → `batcat` and `fd` → `fdfind` are aliased automatically. `~/.local/bin` is added to `PATH` by `.profile`.
- **Fonts:**
  ```bash
  sudo apt install fonts-noto fonts-noto-cjk fonts-dejavu fonts-font-awesome
  for f in JetBrainsMono Hack; do
    mkdir -p ~/.local/share/fonts/NerdFonts/$f
    curl -fsSL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$f.tar.xz \
      | tar -xJ -C ~/.local/share/fonts/NerdFonts/$f
  done
  fc-cache -f
  ```
- **Neovim** (the `.config/nvim` submodule): apt's is recent enough. Its tool list is in `.config/nvim/REQUIREMENTS.md`; install LSPs via Mason, or `sudo apt install nodejs npm rust-analyzer` and `sudo npm i -g pyright typescript-language-server bash-language-server`.
- Rerun `./install.sh nnnny` to apply only the delta git config.

## Phase 6: Theming

```bash
sudo apt install qt6ct qt5ct breeze-icon-theme breeze nwg-look adwaita-icon-theme
```

`environment.d` already sets `QT_QPA_PLATFORMTHEME=qt6ct` and `GTK_THEME=Adwaita:dark`.

## Phase 7: Applications

| App | Source |
|---|---|
| Firefox | Ubuntu ships a snap; Mozilla's APT repo gives the `.deb`. Window rules match app-id `firefox`; check with `niri msg windows` if keeping the snap |
| Thunderbird | Snap by default; Mozilla's APT repo or Flatpak (`org.mozilla.Thunderbird`) also work |
| Helium | Upstream release. `autostart/helium.desktop` runs `helium-browser`; adjust if the Ubuntu build names it differently |
| Discord | `.deb` from discord.com (installs `/usr/bin/discord`, which `discord-launcher.sh` falls back to) |
| ZapZap | `flatpak install flathub com.rtosta.zapzap` (`zapzap-launcher.sh` falls back to the Flatpak) |
| Steam | `sudo apt install steam-installer` (multiverse) or Valve's `.deb` |
| Gaming | `sudo apt install gamemode mangohud gamescope protontricks wine winetricks`; `umu-launcher` from its GitHub releases |
| VS Code | Microsoft APT repo |
| Claude Code, opencode | Native installers (or `npm i -g`) |
| Signal, Element | Their official APT repos |
| OBS, Kdenlive, GIMP, Audacity, LibreOffice, Pinta, qBittorrent, Dolphin, KDE Connect, Kleopatra, Filelight, scrcpy, virt-manager, docker, timeshift, ufw | apt |
| gpu-screen-recorder, Prism Launcher, LocalSend, CurseForge | Flatpak |
| OpenRazer, Polychromatic | `ppa:openrazer/stable`, `ppa:polychromatic/stable`. The `alex-pt78` fork used on Arch isn't in the PPA; build its DKMS module from source for that device support |
| Waydroid | Official repo script from waydro.id |

## Phase 8: System configs (`ignore/`)

1. **Login manager.** Either keep GDM (it already lists the Niri session), or switch to greetd:
   ```bash
   sudo apt install greetd cage gtkgreet   # apt policy gtkgreet first
   sudo usermod -aG video _greetd
   ./install.sh   # y to the greetd step
   sudo systemctl disable gdm3 && sudo systemctl enable greetd
   ```
   `install.sh` detects Ubuntu's `_greetd` user (Arch uses `greeter`) and writes it into `config.toml` and the `gtkgreet.css` ownership.
2. **Polkit rule:** optional; Ubuntu's admin group is already `sudo`.
3. **NetworkManager dispatcher** (Wi-Fi off while ethernet is up): works unchanged; answer `y`.

## Phase 9: Smoke test

- Keybinds: Mod+T (kitty), Mod+D (fuzzel), Mod+V (clipboard), Mod+K (color picker), Mod+Period (smirk), Mod+X (wlogout), Ctrl+Alt+L (lock), Mod+Ctrl+Comma (layout toggle + notification), Mod+P (PiP cycle), media/brightness/volume keys.
- Quickshell bar modules all populate.
- Screen sharing in Discord/Firefox (portal).
- A polkit prompt appears: `pkexec true`.
- An X11 app (Steam) opens through xwayland-satellite.

**Highest-risk items** are whatever ends up built from source (smirk, and the OpenRazer fork if needed) and the PPA packages (niri, Quickshell): they're the ones that break on dependency updates.
