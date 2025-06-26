# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nixpkgs.config.permittedInsecurePackages = [
    "electron-33.4.11"
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "jellyodsk"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Lisbon";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_PT.UTF-8";
    LC_IDENTIFICATION = "pt_PT.UTF-8";
    LC_MEASUREMENT = "pt_PT.UTF-8";
    LC_MONETARY = "pt_PT.UTF-8";
    LC_NAME = "pt_PT.UTF-8";
    LC_NUMERIC = "pt_PT.UTF-8";
    LC_PAPER = "pt_PT.UTF-8";
    LC_TELEPHONE = "pt_PT.UTF-8";
    LC_TIME = "pt_PT.UTF-8";
  };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm = {
    enable = true;
    theme = "sddm-astronaut-theme";
  };
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "pt";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "pt-latin1";

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Enable single auth
  security.sudo.extraConfig = ''
    #Defaults	!tty_tickets

    # Disable sudo timeout
    Defaults timestamp_timeout=-1
  '';

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.jellyo = {
    isNormalUser = true;
    description = "Daniel Evangelista";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" ];
    packages = with pkgs; [];
  };

  #users.defaultUserShell = pkgs.zsh;

  # Install firefox.
  # programs.firefox.enable = true;

  # Gaming
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
  };

  programs.gamemode.enable = true;
  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };

  programs.nano.nanorc = ''
    set tabstospaces
    set tabsize 2
  '';

  programs.dconf.enable = true;

  programs.ssh.startAgent = true;

  #environment.shells = with pkgs; [zsh];
  
  # Hyprland
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  
  # Fix user not being able to cache with cachix on devenv
  nix.settings.trusted-users = [ "root" "jellyo" ];


  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # Dev
    go
    delve
    coreutils
    devenv
    pciutils
    
    # hyprland
    kitty

    libreoffice-qt6-fresh
    gparted
    qemu
    quickemu
    openvpn3    
    qalculate-qt
    vlc
    kdePackages.qtmultimedia
    kdePackages.qtsvg
    kdePackages.qtvirtualkeyboard
    unrar

    # Printer
    epson-escpr
    (epsonscan2.override {
      withNonFreePlugins = true;
    })

    # theming
    (sddm-astronaut.override {
      embeddedTheme = "pixel_sakura";
    })
    catppuccin-cursors.mochaSky
    (catppuccin-gtk.override { variant = "mocha"; accents = ["sky"]; })
    (catppuccin-kde.override { flavour = ["mocha"]; accents = ["sky"]; })
    (catppuccin-papirus-folders.override { flavor = "mocha"; accent =  "sky"; })
  ];

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };

    amdgpu.amdvlk = {
      enable = true;
      support32Bit.enable = true;
    };
  };

  hardware.logitech.wireless.enable = true;
  hardware.logitech.wireless.enableGraphical = true;

  # mount bigdata share
  fileSystems."/mnt/bigdata" = {
    device = "//fs.home/bigdata";
    fsType = "cifs";
    options = let
      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
    in ["${automount_opts},credentials=/etc/nixos/secrets/fs-smb-secrets,uid=${toString config.users.users.jellyo.uid},gid=${toString config.users.groups.users.gid}"];
  };

  # mount 1TB disk
  fileSystems."/mnt/1TB" = {
    device = "/dev/disk/by-uuid/6678468C78465AC7";
    fsType = "ntfs";
    options = [
      "users"
      "nofail"
      "exec"
      "uid=1000"
      "gid=100"
    ];
  };

  # Nix settings
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Virtualization
  programs.virt-manager.enable = true;
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
      vhostUserPackages = with pkgs; [ virtiofsd ];
      ovmf = {
        enable = true;
        packages = [(pkgs.OVMF.override {
          secureBoot = true;
          tpmSupport = true;
        }).fd];
      };
    };
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      kdePackages.xdg-desktop-portal-kde
    ];
  };
  
  # Enable USB redirection
  #virtualisation.spiceUSBRedirection.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
  
  # List services that you want to enable:

  # Steam
  #services.getty.autologinUser = "jellyo";
  #environment.loginShellInit = ''
  #  [[ "$(tty)" = "/dev/tty1" ]] && ./gs.sh
  #'';
  environment.pathsToLink = [ "/share/zsh" ]; # required for zsh system packages completion

  # Input remapper
  services.input-remapper = {
    enable = true;
    enableUdevRules = true;
  };

  # Enable CUPS to print documents.  
  services.printing = {
    enable = true;
    drivers = [ pkgs.epson-escpr ];
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
  };
  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    5555 # scrcpy adb
    24800 # InputLeap
  ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
