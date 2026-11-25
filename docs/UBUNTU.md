# Ubuntu Setup Guide

How to get the niri desktop and apps from these dotfiles running on Ubuntu, in install order. The repo works on both Arch and Ubuntu; anything Arch-only (paru, CachyOS, the package-list script) is skipped here.

**Target: Ubuntu 26.04 LTS or newer.** 24.04 is too old for parts of this setup: e.g. its `fzf` (0.44) lacks the `fzf --fish`/`--zsh` integration the shell configs use, and many Wayland tools are missing. Package availability below was not verified for every item; where it says "check `apt policy X`", the repo version may be missing or too old.

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
sudo apt install git stow build-essential curl wget cmake ninja-build meson pkg-config clang golang
git clone --recurse-submodules https://github.com/AmmoniumX/Dotfiles.git ~/Projects/Dotfiles
cd ~/Projects/Dotfiles
./install.sh -d   # dry run first
./install.sh
```

At the prompts:
- **biri configs:** `n` (skips stowing biri files and drops `biri-session` from greetd's environments).
- **greetd, polkit, NetworkManager, delta:** `n` for now; they're revisited in later phases.

Stowing early means each app finds its config as soon as it's installed.

`rustup`/`cargo` is only needed if some tool in Phase 3 step 2 isn't packaged:
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

## Phase 3: Niri and the session plumbing

1. **Niri from the duxlabs PPAs:**
   ```bash
   sudo add-apt-repository ppa:duxlabs/dux-repo
   sudo add-apt-repository ppa:duxlabs/dms
   sudo apt update
   apt policy niri          # must be >= 25.11: the config uses `include`
   sudo apt install niri
   ```
   The package provides `niri-session`, `niri.desktop`, `niri.service` and a default `niri-portals.conf`. The stowed `~/.config/xdg-desktop-portal/niri-portals.conf` overrides the default.

   These are third-party PPAs: they can run code as root and update on the maintainer's schedule. If niri breaks after an `apt upgrade`, check the PPA first.
2. **Check the same PPAs for things that would otherwise need building:**
   ```bash
   apt policy quickshell xwayland-satellite cliphist matugen
   ```
   Anything missing: `cargo install --locked xwayland-satellite`, `cargo install --locked matugen`, `go install go.senan.xyz/cliphist@latest`, and Quickshell per Phase 4.
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
  gammastep wob wtype wev imv nm-connection-editor blueman bluez
```

`niri/scripts/screenlock` works with plain `swaylock`: it shows `~/.config/wallpapers/lockscreen.png` with the same ring colors. The blurred-screenshot look and clock appear only when swaylock-effects is installed, as on Arch.

Not well covered by apt:

| Tool | Used by | How to get it |
|---|---|---|
| hyprpicker | Mod+K color picker | `apt policy hyprpicker`, else build from source (cmake; needs hyprutils, hyprwayland-scanner) |
| rofi >= 2.0 | Mod+V clipboard (native Wayland) | If apt's is older, change the bind to `cliphist list \| fuzzel --dmenu \| cliphist decode \| ifne wl-copy` |
| smirk | Mod+Period emoji picker | Build from upstream (AUR-only on Arch) |
| Quickshell | Status bar | From the duxlabs PPA if available, else build per its BUILD.md (`qt6-base-dev qt6-declarative-dev qt6-wayland-dev qt6-shadertools-dev libpipewire-0.3-dev libpam0g-dev` ...) then `cmake -GNinja -B build && cmake --build build && sudo cmake --install build` |

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
  git-delta tealdeer htop btop nvtop fastfetch ncdu trash-cli tmux lf plocate
curl -sS https://starship.rs/install.sh | sh
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin   # newer than apt's; symlink kitty into ~/.local/bin
# yazi: prebuilt binaries from its GitHub releases
curl -fsSLO https://github.com/sxyazi/yazi/releases/latest/download/yazi-x86_64-unknown-linux-musl.zip
unzip yazi-x86_64-unknown-linux-musl.zip && install -m755 yazi-x86_64-unknown-linux-musl/{yazi,ya} ~/.local/bin/
chsh -s /usr/bin/fish
```

- `bat` → `batcat` and `fd` → `fdfind` are aliased automatically.
- **Fonts:** download JetBrainsMono and Hack Nerd Fonts from the nerd-fonts releases into `~/.local/share/fonts`, then `fc-cache -f`. Also:
  ```bash
  sudo apt install fonts-noto fonts-noto-cjk fonts-dejavu fonts-font-awesome
  ```
- **Neovim** (the `.config/nvim` submodule): use the official tarball/AppImage if apt's version is too old. LSPs via Mason, or `rustup component add rust-analyzer` and `npm i -g pyright typescript-language-server bash-language-server`.
- Rerun `./install.sh` and answer `y` only to the delta git config.

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

**Highest-risk items** are whatever ends up built from source (likely smirk, the OpenRazer fork, and Quickshell if the PPA lacks it): they're the ones that break on dependency updates.
