# One home-manager configuration. The file name is the flake attribute:
#   home-manager switch --flake .#tony@work
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
    ({lib, ...}: {
      home.packages = [];
      home.shellAliases.nixpkgs = "cd ~/Projects/nixpkgs";
      home.shellAliases.nightingale = "cd ~/Projects/nightingale";
      programs.git.settings.user.email = lib.mkForce "acastanhiera@hmacademy.com";
    })
  ];
}
