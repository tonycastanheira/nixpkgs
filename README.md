# nixpkgs

Personal Nix configurations: home-manager today, nix-darwin / NixOS whenever
you want them. No framework — just a flake and three conventions:

```
lib/            mkHome / mkDarwin / mkNixos + the directory importer
modules/
  home/         reusable home-manager modules  -> flake.homeModules.<name>
  darwin/       reusable nix-darwin modules    -> flake.darwinModules.<name>   (create when needed)
  nixos/        reusable NixOS modules         -> flake.nixosModules.<name>    (create when needed)
homes/          one file per home-manager config -> flake.homeConfigurations.<name>
machines/
  darwin/       one file per Mac  -> flake.darwinConfigurations.<hostname>     (create when needed)
  nixos/        one file per box  -> flake.nixosConfigurations.<hostname>      (create when needed)
```

Files are discovered automatically: drop `modules/home/tmux.nix` in and
`self.homeModules.tmux` exists; drop `homes/tony@work.nix` in and
`home-manager switch --flake .#tony@work` works. `foo.nix` and
`foo/default.nix` (for modules that carry config files with them) are both
fine. Missing directories are fine too.

## Install Nix
```sh
curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install | sh
```

## First run

Edit the TODOs in `homes/tony.nix` and `modules/home/git.nix`, then:


```sh
nix run home-manager/release-26.05 -- switch --flake .#tony@work
```

After that, `home-manager` is on your PATH, so it's just:

```sh
home-manager switch --flake .#tony@work
```

## Writing modules

Modules in `modules/home/` are plain [home-manager modules](https://nix-community.github.io/home-manager/options.xhtml).
Besides the usual `pkgs`, `lib`, and `config`, every module also receives:

- `unstable` — nixpkgs-unstable, for when a package is too old on stable:
  `home.packages = [ unstable.neovim ];`
- `inputs` — the flake's inputs, for packages that live in other flakes:
  `inputs.helix.packages.${pkgs.stdenv.hostPlatform.system}.default`

Compose them per machine in `homes/<name>.nix` — pick modules by name,
mix in inline config, done.

## Later: a whole Mac (or NixOS box)

When you want Nix to manage the OS too, create `machines/darwin/<hostname>.nix`:

```nix
{self, ...}: {
  system = "aarch64-darwin";
  homes.tony = with self.homeModules; [cli git];
  modules = [
    {
      system.primaryUser = "tony";
      nix.settings.experimental-features = "nix-command flakes";
    }
  ];
}
```

then `darwin-rebuild switch --flake .#<hostname>`. NixOS is the same shape
under `machines/nixos/`. Reusable OS-level modules go in `modules/darwin/`
and `modules/nixos/`.

## Housekeeping

```sh
nix fmt              # format everything (alejandra)
nix flake update     # bump inputs
nix flake check      # sanity-check after big changes
```
