# Provides the FHS paths the dotfiles hardcode, so the same files work on Arch and NixOS.
{ pkgs, ... }:

{
  # Resolves /usr/bin/* and /bin/* against the caller's PATH
  # (kitty's `shell /usr/bin/fish`, Exec=/usr/bin/steam, the user systemd units, ...).
  services.envfs.enable = true;

  systemd.tmpfiles.rules = [
    "d /usr/share 0755 root root -"
    "d /usr/lib 0755 root root -"
    # .bashrc
    "L+ /usr/share/bash-completion - - - - ${pkgs.bash-completion}/share/bash-completion"
    # .nanorc
    "L+ /usr/share/nano - - - - ${pkgs.nano}/share/nano"
    # mako on-notify sound, notify-me in .functions.*
    "L+ /usr/share/sounds/freedesktop - - - - ${pkgs.sound-theme-freedesktop}/share/sounds/freedesktop"
    # wlogout/style.css icons
    "L+ /usr/share/wlogout - - - - ${pkgs.wlogout}/share/wlogout"
    # niri/biri spawn-at-startup polkit agent
    "L+ /usr/lib/polkit-kde-authentication-agent-1 - - - - ${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1"
  ];
}
