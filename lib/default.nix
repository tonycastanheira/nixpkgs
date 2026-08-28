# The flake's inputs, applied at the top of flake.nix.
inputs @ {
  nixpkgs,
  nixpkgs-unstable,
  home-manager,
  darwin,
  ...
}: let
  l = nixpkgs.lib // builtins;

  pkgsFor = system:
    import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };

  unstableFor = system:
    import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };

  # Every module gets `inputs` and `unstable` alongside the usual pkgs/lib/config.
  specialArgsFor = system: {
    inherit inputs;
    unstable = unstableFor system;
  };
in rec {
  # Import every entry of a directory as an attrset keyed by file name:
  #   git.nix -> git, cli/default.nix -> cli
  # Directories without a default.nix (e.g. asset folders) are skipped, and a
  # missing directory just yields {}.
  importDir = dir:
    if !(l.pathExists dir)
    then {}
    else
      l.mapAttrs'
      (name: _: l.nameValuePair (l.removeSuffix ".nix" name) (import (dir + "/${name}")))
      (l.filterAttrs
        (name: type:
          (type == "directory" && l.pathExists (dir + "/${name}/default.nix"))
          || (type == "regular" && l.hasSuffix ".nix" name && name != "default.nix"))
        (l.readDir dir));

  # Standalone home-manager configuration (no root required).
  mkHome = {
    username,
    system ? "aarch64-darwin",
    homeDirectory ?
      (
        if l.hasSuffix "darwin" system
        then "/Users/${username}"
        else "/home/${username}"
      ),
    stateVersion ? "26.05",
    modules ? [],
  }:
    home-manager.lib.homeManagerConfiguration {
      pkgs = pkgsFor system;
      extraSpecialArgs = specialArgsFor system;
      modules =
        [
          {
            home = {inherit username homeDirectory stateVersion;};
            programs.home-manager.enable = true;
          }
        ]
        ++ modules;
    };

  # nix-darwin system, with home-manager wired in: pass
  #   homes.<username> = [ ...home-manager modules... ];
  mkDarwin = {
    system ? "aarch64-darwin",
    modules ? [],
    homes ? {},
  }:
    darwin.lib.darwinSystem {
      inherit system;
      pkgs = pkgsFor system;
      specialArgs = specialArgsFor system;
      modules =
        [
          home-manager.darwinModules.home-manager
          {
            users.users = l.mapAttrs (name: _: {home = "/Users/${name}";}) homes;
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = specialArgsFor system;
              users = l.mapAttrs (_: mods: {imports = mods;}) homes;
            };
          }
        ]
        ++ modules;
    };

  # NixOS system, same shape as mkDarwin.
  mkNixos = {
    system ? "x86_64-linux",
    stateVersion ? "26.05",
    modules ? [],
    homes ? {},
  }:
    nixpkgs.lib.nixosSystem {
      inherit system;
      pkgs = pkgsFor system;
      specialArgs = specialArgsFor system;
      modules =
        [
          home-manager.nixosModules.home-manager
          {
            system.stateVersion = stateVersion;
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = specialArgsFor system;
              users = l.mapAttrs (_: mods: {imports = mods;}) homes;
            };
          }
        ]
        ++ modules;
    };
}
