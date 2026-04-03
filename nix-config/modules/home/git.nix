{ ... }: {
  programs.git = {
    enable = true;
    lfs.enable = true;
    signing = {
      key = "~/.ssh/id_rsa.pub";
      signByDefault = true;
      format = "ssh";
    };
    settings = {
      user = {
        name = "Ayam Dobhal";
        email = "me@iamdobhal.dev";
      };
      push.autoSetupRemote = true;
      pull.rebase = false;
      init.defaultBranch = "main";
    };
  };
}
