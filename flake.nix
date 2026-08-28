{
  description = "Tony's Nix configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    lib = import ./lib inputs;
    inherit (lib) importDir;

    # Each file in homes/ and machines/ describes one configuration. It's a
    # function of {self, inputs} so it can pull modules from self.homeModules
    # (and anything else the flake exports) by name.
    specs = dir: builtins.mapAttrs (_: spec: spec {inherit self inputs;}) (importDir dir);
  in {
    inherit lib;

    # Reusable modules, exported under the name of their file (or directory).
    # modules/home/git.nix -> homeModules.git
    homeModules = importDir ./modules/home;
    darwinModules = importDir ./modules/darwin;
    nixosModules = importDir ./modules/nixos;

    # homes/tony.nix -> homeConfigurations.tony
    #   home-manager switch --flake .#tony
    homeConfigurations = builtins.mapAttrs (_: lib.mkHome) (specs ./homes);

    # machines/darwin/<hostname>.nix -> darwinConfigurations.<hostname>
    #   darwin-rebuild switch --flake .#<hostname>
    darwinConfigurations = builtins.mapAttrs (_: lib.mkDarwin) (specs ./machines/darwin);

    # machines/nixos/<hostname>.nix -> nixosConfigurations.<hostname>
    #   nixos-rebuild switch --flake .#<hostname>
    nixosConfigurations = builtins.mapAttrs (_: lib.mkNixos) (specs ./machines/nixos);

    formatter = nixpkgs.lib.genAttrs ["aarch64-darwin" "x86_64-darwin" "aarch64-linux" "x86_64-linux"] (
      system: nixpkgs.legacyPackages.${system}.alejandra
    );
  };
}
