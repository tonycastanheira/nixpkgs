{pkgs, ...}: {
  programs.git = {
    enable = true;
    lfs.enable = true;
    settings = {
      user = {
        name = "Tony Castanheira";
        email = "antonio.augusto.castanheira@gmail.com";
      };
      init.defaultBranch = "main";
    };
    ignores = [
      ".direnv"
      ".DS_Store"
    ];
  };

  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = "Tony Castanheira";
        email = "antonio.augusto.castanheira@gmail.com";
      };
      ui = {
        paginate = "never";
        default-command = "log";
        diff-formatter = ["difft" "--color=always" "$left" "$right"];
      };
    };
  };
  programs.jjui.enable = true;
  programs.gh.enable = true;

  home.packages = with pkgs; [
    difftastic
    starship-jj
  ];
}
