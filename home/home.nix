{config, pkgs, lib, inputs, osConfig, ...}:
{
    imports = [
      inputs.zen-browser.homeModules.twilight
      ./shell.nix
    ];

    home.username = "jellyo";
    home.homeDirectory = "/home/jellyo";

    home.packages = with pkgs; [
      # Dev
      git-crypt
      code-cursor
      nil
      scrcpy

      # Games
      protonup-qt
      mangohud
      lutris
      bottles
      heroic

      # misc
      kdePackages.kate
      thunderbird
      zoom-us
      rustdesk-flutter
      anydesk
      spotify
      discord
      signal-desktop
      remmina
      parsec-bin
      #plex-desktop
      input-leap
      kdePackages.filelight
    ];

    programs.git = {
      enable = true;
    };

    programs.zen-browser = {
      enable = true;
      policies = {
        AutofillCreditCardEnabled = false;
        DisableAppUpdate = true;
        DisableTelemetry = true;
        DisableFeedbackCommands = true;
        DisableFirefoxStudies = true;
        DisablePocket = true;
        NoDefaultBookmarks = true;
        OfferToSaveLogins = false;
      };
      profiles.default = {
        settings = {
          id = 0;
          "browser.startup.homepage" = "http://dashy.lan/";
        };
        extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
          ublock-origin
          bitwarden
          fakespot-fake-reviews-amazon
        ];
      };
    };

    # Fixes input-mapper autoload (https://github.com/NixOS/nixpkgs/issues/304006#issuecomment-2054130342)
    xdg.configFile."autostart/input-mapper-autoload.desktop" = lib.mkIf osConfig.services.input-remapper.enable {
      source = "${osConfig.services.input-remapper.package}/share/applications/input-remapper-autoload.desktop";
    };

    #programs.zsh.enable = true;
    # This value determines the Home Manager release that your configuration is 
    # compatible with. This helps avoid breakage when a new Home Manager release 
    # introduces backwards incompatible changes. 
    #
    # You should not change this value, even if you update Home Manager. If you do 
    # want to update the value, then make sure to first check the Home Manager 
    # release notes. 
    home.stateVersion = "25.05"; # Please read the comment before changing. 
}
