# System configuration for the ASUS TUF A15 (Ryzen 7 7435HS, RTX 4060 Mobile).
{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/desktop.nix
    ../../modules/packages.nix
    ../../modules/compat.nix
  ];

  # ---------------------------------------------------------------- nix
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
    trusted-users = [ "root" "@wheel" ];
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
  nixpkgs.config.allowUnfree = true;

  # ---------------------------------------------------------------- boot
  boot.loader.systemd-boot = {
    enable = true;
    # /boot is a ~1 GiB ESP, so keep the number of kernels on it small.
    configurationLimit = 5;
  };
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages;

  boot.kernelParams = [
    "systemd.tpm2_wait=false"
    "8250.nr_uarts=0"
    "pcie_aspm=off"
  ];

  boot.blacklistedKernelModules = [ "tpm" "tpm_crb" ];
  boot.extraModprobeConfig = ''
    install tpm_crb ${pkgs.coreutils}/bin/true
    install tpm ${pkgs.coreutils}/bin/true
    options rtw89_core disable_ps_mode=1
  '';

  hardware.enableRedistributableFirmware = true;

  # ---------------------------------------------------------------- graphics
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # The 7435HS has no iGPU, so the RTX 4060 drives everything (no PRIME setup).
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    open = true;
    modesetting.enable = true;
    powerManagement.enable = true;
    nvidiaSettings = false;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # ---------------------------------------------------------------- locale
  networking.hostName = "tuf-a15-nixos";
  time.timeZone = "America/Costa_Rica";
  i18n.defaultLocale = "en_GB.UTF-8";
  console.keyMap = "uk";
  services.xserver.xkb.layout = "gb";

  # ---------------------------------------------------------------- network
  networking.networkmanager = {
    enable = true;
    dns = "systemd-resolved";
    dispatcherScripts = [
      {
        type = "basic";
        source = pkgs.writeShellScript "99-wifi-ethernet" ''
          export PATH=${lib.makeBinPath [ pkgs.networkmanager pkgs.gawk pkgs.coreutils ]}:$PATH
          exec ${pkgs.bash}/bin/bash ${../../../ignore/NetworkManager/dispatcher.d/99-wifi-ethernet.sh} "$@"
        '';
      }
    ];
  };
  services.resolved.enable = true;

  # Mirrors the ufw rules from the Arch install. KDE Connect and LocalSend open
  # their own ports through their program modules.
  networking.firewall = {
    enable = true;
    trustedInterfaces = [
      "docker0"
      "virbr0"
      "waydroid0"
      # Trusts the whole Wi-Fi interface, same as the ufw rule this replaces.
      "wlp4s0"
    ];
  };

  # ---------------------------------------------------------------- users
  users.users.ammonium = {
    isNormalUser = true;
    description = "Diego Garcia";
    shell = pkgs.bash;
    extraGroups = [
      "wheel"
      "networkmanager"
      "libvirtd"
      "video"
      "audio"
      "input"
      "gamemode"
    ];
  };

  # ---------------------------------------------------------------- hardware services
  hardware.bluetooth.enable = true;
  services.power-profiles-daemon.enable = true;
  services.fstrim.enable = true;
  services.geoclue2.enable = true;
  services.ratbagd.enable = true;
  services.udisks2.enable = true;

  # Keyboard backlight colour, ported from the aurora-controller service.
  systemd.services.asus-kbd-rgb = {
    description = "Set ASUS keyboard backlight colour";
    after = [ "multi-user.target" "suspend.target" "hibernate.target" "hybrid-sleep.target" "suspend-then-hibernate.target" ];
    wantedBy = [ "multi-user.target" "suspend.target" "hibernate.target" "hybrid-sleep.target" "suspend-then-hibernate.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      echo 3 > /sys/class/leds/asus::kbd_backlight/brightness
      echo 1 0 255 0 23 0 > /sys/class/leds/asus::kbd_backlight/kbd_rgb_mode
      echo 1 1 1 0 0 > /sys/class/leds/asus::kbd_backlight/kbd_rgb_state
    '';
  };

  # ---------------------------------------------------------------- system services
  security.apparmor.enable = true;
  security.polkit.enable = true;

  services.locate = {
    enable = true;
    package = pkgs.plocate;
  };

  services.flatpak.enable = true;

  services.qbittorrent.enable = true;

  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  virtualisation.libvirtd = {
    enable = true;
    qemu.swtpm.enable = true;
  };
  programs.virt-manager.enable = true;

  virtualisation.waydroid.enable = true;

  # Lets prebuilt binaries (vcpkg tools, pip wheels, language servers fetched by nvim) run.
  programs.nix-ld.enable = true;

  system.stateVersion = "26.05";
}
