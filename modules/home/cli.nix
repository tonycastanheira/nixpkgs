# A comfortable baseline CLI environment. This is a plain home-manager
# module — `pkgs` is stable nixpkgs, `unstable` is nixos-unstable, and
# `inputs` exposes the flake's inputs if you ever need them.
{
  lib,
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

    # Stale parent environments (VS Code, tmux, ...) carry the
    # __HM_SESS_VARS_SOURCED guard from an older generation, which makes
    # hm-session-vars.sh return before exporting anything new. Clear the
    # guard and re-source so every interactive shell gets the current vars.
    initContent = lib.mkOrder 500 ''
      unset __HM_SESS_VARS_SOURCED __HM_ZSH_SESS_VARS_SOURCED
      source "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
    '';
  };

  home.shellAliases = {
    cat = "bat";
    ls = "eza";
  };
}
