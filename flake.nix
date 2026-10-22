{
  description = "AmmoniumX NixOS configuration (ASUS TUF A15) built from these dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # niri soft-fork, renamed to biri in nixos/pkgs/biri.nix so it installs next to niri
    biri = {
      url = "github:barrulus/biri";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    helium = {
      url = "github:schembriaiden/helium-browser-nix-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    curseforge = {
      url = "github:spitfire05/curseforge-appimage-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    smirk = {
      url = "github:Yiin/smirk";
      flake = false;
    };
  };

  outputs =
    { self, nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
    in
    {
      overlays.default = final: prev: {
        biri = final.callPackage ./nixos/pkgs/biri.nix {
          niri = inputs.biri.packages.${system}.niri;
        };
        smirk = final.callPackage ./nixos/pkgs/smirk.nix { src = inputs.smirk; };
      };

      nixosConfigurations.tuf-a15 = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs self; };
        modules = [
          {
            nixpkgs.overlays = [
              self.overlays.default
              inputs.helium.overlays.default
              inputs.curseforge.overlays.default
            ];
          }
          ./nixos/hosts/tuf-a15/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "hm-bak";
              extraSpecialArgs = { inherit inputs self; };
              users.ammonium = import ./nixos/home.nix;
            };
          }
        ];
      };
    };
}
