# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nixpkgs.config = {
    allowUnfree = true;
  };

  nixpkgs.overlays =
    let
      moz-rev = "master";
      moz-url = builtins.fetchTarball { url = "https://github.com/mozilla/nixpkgs-mozilla/archive/${moz-rev}.tar.gz";};
      nightlyOverlay = (import "${moz-url}/firefox-overlay.nix");
    in [
      nightlyOverlay
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.useOSProber = true;

  time.timeZone = "America/Chicago";

  networking = {
    hostName = "cbrewster-nixos";
    networkmanager.enable = true;

    # The global useDHCP flag is deprecated, therefore explicitly set to false here.
    # Per-interface useDHCP will be mandatory in the future, so this generated config
    # replicates the default behaviour.
    useDHCP = false;
    interfaces.enp6s0.useDHCP = true;
    # interfaces.wlp5s0.useDHCP = true;

    extraHosts = ''
      192.168.99.100 nix.cacache.replit.com
      34.123.240.239 replit.dev
    '';
  };

  security.pki.certificateFiles = [ ./replit-ca.crt ];

  programs.ssh.startAgent = true;
  programs.dconf.enable = true;

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];
    layout = "us";

    # config = (builtins.readFile ./xorg.conf);

    xkbOptions = "ctrl:nocaps";

    desktopManager = {
      xterm.enable = false;
      xfce = {
        enable = true;
	    noDesktop = true;
	    enableXfwm = false;
      };
    };

    windowManager.i3 = {
      enable = true;
      package = pkgs.i3-gaps;
      extraPackages = with pkgs; [
        dmenu
        i3status
        i3lock
      ];
    };

    displayManager.defaultSession = "xfce+i3";
  };

  # Better nix-shell with direnv integration.
  services.lorri.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  services.actkbd.enable = true;
  sound.mediaKeys.enable = true; # keyboard control for audio

  # Define a user account. Don't forget to set a password with ‘passwd’.
  programs.zsh.enable = true;
  users.users.cbrewster = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" "sound" "video" "vboxusers" "networkmanager" "docker" "sway" ];
    shell = pkgs.zsh;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget vim git lsof
    pavucontrol
    alacritty
    chromium
    latest.firefox-nightly-bin
    libGL
  ];

  environment.sessionVariables.TERMINAL = [ "alacritty" ];

  fonts.fonts = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" ]; })   
  ];

  # Virtualisation
  virtualisation.virtualbox.host.enable = true;
  virtualisation.docker.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?
}

