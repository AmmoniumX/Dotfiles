# NixOS configuration

A NixOS flake that rebuilds the Arch setup from this repo: same packages, services
and desktop (niri + biri, greetd/gtkgreet, quickshell, mako...), with the dotfiles
linked into `$HOME` by home-manager instead of stow.

```
flake.nix                         inputs + nixosConfigurations.tuf-a15
nixos/hosts/tuf-a15/              boot, NVIDIA, locale, network, users, services
nixos/modules/desktop.nix         compositors, greetd, portals, audio, fonts, Steam
nixos/modules/packages.nix        the pacman/AUR package list
nixos/modules/compat.nix          /usr/bin, /usr/share paths the dotfiles hardcode
nixos/home.nix                    dotfile links + git/delta config
nixos/pkgs/{biri,smirk}.nix       packages that only exist in the AUR
```

## Installing

1. Boot the NixOS installer, partition/format, and mount the target at `/mnt`
   (reuse the btrfs `@home`, `@data` and `@steam` subvolumes to keep your data).
2. Run `nixos-generate-config --root /mnt --show-hardware-config` and copy the
   new root and `/boot` UUIDs into `nixos/hosts/tuf-a15/hardware-configuration.nix`.
3. Clone this repo to `/mnt/home/ammonium/Projects/Dotfiles` (home.nix links to that path).
4. `nixos-install --flake /mnt/home/ammonium/Projects/Dotfiles#tuf-a15`
5. Set a password: `nixos-enter --root /mnt -c 'passwd ammonium'`

Afterwards: `sudo nixos-rebuild switch --flake ~/Projects/Dotfiles#tuf-a15`.
Update inputs with `nix flake update`.

Edits to existing dotfiles take effect immediately (the links point into the
checkout). New files need a rebuild to get linked.

## Differences from the Arch install

- **Kernel**: the default NixOS kernel (`linuxPackages`) instead of linux-cachyos.
- **Hostname**: `tuf-a15-nixos`.
- **niri** comes from nixpkgs (stable), not niri-git. **biri** is built from source
  with the same renames as the AUR package.
- **Docker** runs rootless only; **qbittorrent-nox** uses the NixOS module's own
  `qbittorrent` user instead of `qbt`.
- **ProtonPlus** is a native package instead of a Flatpak. Stremio stays a Flatpak.
- **Polkit**: `wheel` is admin by default, so the extra `sudo` group rule isn't needed.

Not carried over (no nixpkgs package, or Arch-only):
cubyz, twintaillauncher, nm-wifi-gui, waydroid-script, timeshift,
kamoso, kwallet5, blueberry/bluedevil, dotnet-runtime-6.0 (EOL), keyd and cronie
(installed but disabled on Arch), and the C/C++ dev libraries (glfw, glm, sfml,
gtkmm3, libc++), which belong in per-project dev shells with direnv on NixOS.
Arch tooling (paru, pug, reflector, cachyos-*, pacman-contrib, devtools, namcap,
downgrade, arch-manwarn) has no equivalent.
