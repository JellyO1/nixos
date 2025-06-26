{ config, pkgs, ...}:
{
  programs.direnv.enable = true;

  # Zsh
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    #enableBashCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = ["git" "dirhistory" "history"];
      theme = "robbyrussell";
    };
  };
}