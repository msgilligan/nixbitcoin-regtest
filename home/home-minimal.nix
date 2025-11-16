# Minimal Home Manager configuration for Test VMs with services, etc.
# It provides basic tools for exploration and debugging
{ config, pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    # base (minimal essential)
    lazygit
    systemctl-tui
  ];

  programs.bash = {
    enable = true;
    sessionVariables = {
      MORE = "-e";
      EDITOR = "vi";
    };
    shellAliases = {
      h = "history 30";
      userctl = "systemctl --user";
      userctl-tui = "systemctl-tui -s user";
    };
  };

  programs.btop = {
    enable = true;
    settings = {
      truecolor = false;
    };
  };

#  programs.delta = {
#      enable = true;
#      enableGitIntegration = true;
#      options = {
#        side-by-side = true;
#        tabs = 4;
#      };
#  };

  programs.git = {
    enable = true;
    aliases = {
      ci = "commit";
      co = "checkout";
      st = "status";
      sg = "log --pretty=format:'%h %an %s' --graph";
    };
    extraConfig = {
      init = {
        defaultBranch = "master";
      };
      push = {
        default = "simple";
      };
      core = {
        editor = "vi";
      };
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "25.05";
}
