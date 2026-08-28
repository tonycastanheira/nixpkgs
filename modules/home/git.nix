{pkgs, ...}: {
  programs.git = {
    enable = true;
    lfs.enable = true;
    settings = {
      user = {
        # TODO: your name and email
        name = "Tony Castanheira";
        email = "tony@example.com";
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
        # TODO: your name and email
        name = "Tony Castanheira";
        email = "tony@example.com";
      };
      ui = {
        paginate = "never";
        default-command = "log";
        diff-formatter = ["difft" "--color=always" "$left" "$right"];
      };
    };
  };

  programs.gh.enable = true;

  home.packages = with pkgs; [
    difftastic
  ];
}
