# Links every tracked dotfile into $HOME like `stow --no-folding` does. Links point at
# the live checkout (not the Nix store), so edits apply without a rebuild; only newly
# added files need a `nixos-rebuild switch` to get linked.
{ config, lib, self, ... }:

let
  repo = "${config.home.homeDirectory}/Projects/Dotfiles";
  link = rel: config.lib.file.mkOutOfStoreSymlink "${repo}/${rel}";

  # Same exclusions as .stow-local-ignore, plus the submodule (linked whole below).
  excluded = [
    ".git"
    ".gitignore"
    ".gitmodules"
    ".backups"
    ".stow-local-ignore"
    "install.sh"
    "README.md"
    "GEMINI.md"
    "ignore"
    "nixos"
    "flake.nix"
    "flake.lock"
    ".config/nvim"
  ];

  walk =
    dir:
    lib.concatLists (
      lib.mapAttrsToList (
        name: type:
        let
          rel = if dir == "" then name else "${dir}/${name}";
        in
        if lib.elem rel excluded then
          [ ]
        else if type == "directory" then
          walk rel
        else
          [ rel ]
      ) (builtins.readDir "${self}/${dir}")
    );

  dotfiles = lib.genAttrs (walk "") (rel: { source = link rel; });
in
{
  home.username = "ammonium";
  home.homeDirectory = "/home/ammonium";

  home.file = dotfiles // {
    ".config/nvim".source = link ".config/nvim";
    ".config/systemd/user/graphical-session.target.wants/gammastep-indicator.service".source =
      link ".config/systemd/user/gammastep-indicator.service";
  };

  # Replaces the delta setup step in install.sh.
  programs.git = {
    enable = true;
    settings = {
      user.name = "Diego Garcia";
      user.email = "diego.garcia.cr@gmail.com";
      core.pager = "delta";
      interactive.diffFilter = "delta --color-only";
      delta = {
        navigate = true;
        dark = true;
        line-numbers = true;
        line-numbers-left-format = "";
        file-decoration-style = "gray ol ul";
        hunk-header-decoration-style = "omit";
      };
      merge.conflictStyle = "zdiff3";
    };
  };

  home.stateVersion = "26.05";
}
