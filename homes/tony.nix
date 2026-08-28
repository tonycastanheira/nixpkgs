# One home-manager configuration. The file name is the flake attribute:
#   home-manager switch --flake .#tony
#
# This file receives {self, inputs} and returns arguments for lib.mkHome
# (see lib/default.nix for everything it accepts).
{self, ...}: {
  # TODO: your macOS/Linux login name
  username = "tony";
  system = "aarch64-darwin";

  modules = with self.homeModules; [
    cli
    git

    # Inline config works too — anything home-manager accepts:
    {
      home.packages = [];
      home.shellAliases.nixpkgs = "cd ~/Projects/nixpkgs";
    }
  ];
}
