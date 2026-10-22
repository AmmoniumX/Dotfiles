# Wayland desktop: niri + biri, greetd/gtkgreet login, audio, portals, fonts, gaming.
{ pkgs, ... }:

{
  # ---------------------------------------------------------------- compositors
  programs.niri.enable = true;

  environment.systemPackages = [ pkgs.biri ];
  systemd.packages = [ pkgs.biri ];
  services.displayManager.sessionPackages = [ pkgs.biri ];

  # ---------------------------------------------------------------- login
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.cage}/bin/cage -s -- ${pkgs.gtkgreet}/bin/gtkgreet -s ${../../ignore/greetd/gtkgreet.css}";
      user = "greeter";
    };
  };
  environment.etc."greetd/environments".source = ../../ignore/greetd/environments;

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;
  security.pam.services.swaylock = { };
  security.pam.services.waylock = { };

  # ---------------------------------------------------------------- portals
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-gnome
    ];
    configPackages = [ pkgs.biri ];
  };

  programs.dconf.enable = true;

  # ---------------------------------------------------------------- audio
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # ---------------------------------------------------------------- fonts
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    dejavu_fonts
    font-awesome
    nerd-fonts.dejavu-sans-mono
    nerd-fonts.fira-code
    nerd-fonts.hack
    nerd-fonts.jetbrains-mono
    nerd-fonts.noto
  ];

  # ---------------------------------------------------------------- apps with NixOS modules
  programs.fish.enable = true;
  programs.zsh.enable = true;

  programs.kdeconnect.enable = true;
  programs.localsend = {
    enable = true;
    openFirewall = true;
  };
  programs.partition-manager.enable = true;
  programs.gpu-screen-recorder.enable = true;

  programs.steam = {
    enable = true;
    protontricks.enable = true;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };
  programs.gamescope.enable = true;
  programs.gamemode.enable = true;
  hardware.steam-hardware.enable = true;
  services.udev.packages = [ pkgs.game-devices-udev-rules ];
}
