# Packages from the Arch pacman/AUR lists. Arch-only tooling (paru, pacman-contrib,
# reflector, cachyos-*, devtools, namcap, pug, ...) has no counterpart and is left out.
{ pkgs, ... }:

let
  python = pkgs.python3.withPackages (ps: with ps; [
    numpy
    pip
    setuptools
    virtualenv
  ]);

  dotnet = pkgs.dotnetCorePackages.combinePackages [
    pkgs.dotnetCorePackages.sdk_8_0
    pkgs.dotnetCorePackages.aspnetcore_8_0
  ];
in
{
  environment.systemPackages = with pkgs; [
    # ---------------------------------------------------------------- shell & CLI
    _7zz
    aria2
    bat
    bc
    cmatrix
    delta
    direnv
    eza
    fastfetch
    fd
    figlet
    fzf
    gh
    gist
    git
    hexedit
    htop
    lf
    less
    moreutils
    most
    ncdu
    neovim
    nvtopPackages.nvidia
    rlwrap
    screen
    starship
    stow
    tailspin
    tealdeer
    tmux
    trash-cli
    tree-sitter
    unrar
    wget
    yazi
    zoxide

    # ---------------------------------------------------------------- system & hardware
    alsa-utils
    android-tools
    btrfs-progs
    chntpw
    perf
    dosfstools
    efitools
    exfatprogs
    inetutils
    man-pages
    mokutil
    net-tools
    ntfs3g
    nvme-cli
    partclone
    sbctl
    sbsigntool
    scrcpy
    tcpdump

    # ---------------------------------------------------------------- development
    cargo
    cargo-cache
    ccache
    clang
    clippy
    cmake
    gcc
    gdb
    gnumake
    go
    lldb
    nodejs
    pipx
    pkg-config
    pre-commit
    python
    python312
    rust-analyzer
    rustc
    rustfmt
    sccache
    tectonic
    vcpkg
    dotnet
    jdk17
    jre8

    # language servers
    bash-language-server
    copilot-language-server
    gopls
    kdePackages.qtdeclarative # qmlls
    lua-language-server
    luarocks
    pyright
    ruff
    typescript-language-server

    # AI tools
    claude-code
    opencode

    # ---------------------------------------------------------------- wayland desktop
    brightnessctl
    cava
    cliphist
    foot
    fuzzel
    gammastep
    hyprpicker
    imv
    kitty
    libnotify
    mako
    matugen
    mpv
    networkmanagerapplet
    nwg-look
    pamixer
    pavucontrol
    playerctl
    pulsemixer
    quickshell
    rofi
    smirk
    swaybg
    swaylock-effects
    waylock
    wev
    wl-clipboard
    wlogout
    wob
    wtype
    xwayland-satellite
    libsForQt5.qt5ct
    qt6Packages.qt6ct
    kdePackages.polkit-kde-agent-1

    # ---------------------------------------------------------------- KDE apps
    kdePackages.dolphin
    kdePackages.filelight
    kdePackages.isoimagewriter
    kdePackages.kdenlive
    kdePackages.kio-admin
    kdePackages.kio-extras
    kdePackages.kleopatra
    kdePackages.kwalletmanager
    kdePackages.qtsvg

    # ---------------------------------------------------------------- apps
    audacity
    discord
    element-desktop
    firefox
    gimp
    helium
    libreoffice
    mpc
    mpd
    obs-studio
    pinta
    qbittorrent
    signal-desktop
    snapshot
    thunderbird
    zapzap

    # ---------------------------------------------------------------- gaming
    curseforge
    mangohud
    piper
    prismlauncher
    protonplus
    umu-launcher
    wineWow64Packages.waylandFull
    winetricks
  ];

  environment.variables.EDITOR = "nvim";
}
