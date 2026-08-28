# A comfortable baseline CLI environment. This is a plain home-manager
# module — `pkgs` is stable nixpkgs, `unstable` is nixos-unstable, and
# `inputs` exposes the flake's inputs if you ever need them.
{
  pkgs,
  unstable,
  ...
}: {
  home.packages = with pkgs; [
    jq
    htop
    wget
    unzip
    watch
  ];

  xdg.enable = true;

  programs.eza.enable = true;
  programs.fzf.enable = true;
  programs.zoxide.enable = true;

  programs.bat = {
    enable = true;
    config = {
      pager = "less -FR --mouse";
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.starship.enable = true;

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
  };

  home.shellAliases = {
    cat = "bat";
    ls = "eza";
  };
}
