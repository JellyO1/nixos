{config, pkgs, inputs, ...}:
{
    imports = [
      inputs.zen-browser.homeModules.twilight
    ];
    
    home.username = "jellyo";
    home.homeDirectory = "/home/jellyo";

    home.packages = [ ];

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
