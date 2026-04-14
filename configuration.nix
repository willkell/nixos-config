# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  inputs,
  pkgs-unstable,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./cider.nix
    inputs.dms.nixosModules.greeter
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  home-manager.users.wk = import ./home.nix;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_6_12;

  networking.hostName = "nixos"; # Define your hostname.

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # audio
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # xdg portal, let apps open websites
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    config.common.default = "*";
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  nixpkgs.config.allowUnfree = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.wk = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "mlocate"
    ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      tree
    ];
  };

  programs.firefox.enable = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    wget
    kitty
    fuzzel
    ripgrep
    fd
    git
    gcc
    pciutils
    iosevka
    nodejs
    btop
    tree-sitter
    lua
    gnumake
    luarocks
    discord
    cheese
    cameractrls
    tinymist
    websocat
    hyprwire
    hyprtoolkit
    bibata-cursors
    unzip
    lazygit
    pkgs-unstable.ticktick
    tidal-hifi
    grimblast
    (catppuccin-sddm.override {
      flavor = "mocha";
      disableBackground = true;
    })
    cargo
    rustc
    xfce.thunar
    python3
    python3Packages.gpustat
    papirus-icon-theme # or adwaita-icon-theme
    mangowc
    xwayland-satellite
    qmk
    dos2unix
    claude-code
    hyprlandPlugins.hyprsplit
    protonvpn-gui
    heroic
    ghostty
  ];
  fonts.packages = with pkgs; [
    nerd-fonts.iosevka-term
    nerd-fonts.iosevka
  ];

  # hyprland
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  programs.dank-material-shell.greeter = {
    enable = true;
    compositor.name = "hyprland";
    compositor.customConfig = ''
      env = XCURSOR_THEME,Bibata-Modern-Classic
      env = XCURSOR_SIZE,24

      monitor = DP-5, preferred, auto, 1
      monitor = DP-4, disable
      monitor = HDMI-A-3, disable
      misc {
        disable_splash_rendering = true
        disable_hyprland_logo = true
      }
    '';
    configHome = "/home/wk";
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    WLR_NO_HARDWARE_CURSORS = "1";
  };

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  # 1password
  programs._1password.enable = true;

  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "wk" ];
  };

  # keyring for 1password
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;
  security.pam.services.sddm.enableGnomeKeyring = true;

  # chromium sandbox
  security.chromiumSuidSandbox.enable = true;

  # ssh
  programs.ssh = {
    extraConfig = ''
      Host *
        IdentityAgent ~/.1password/agent.sock
        AddressFamily inet
    '';
  };

  users.groups.plocate = { };

  services.locate = {
    enable = true;
    package = pkgs.plocate;
  };

  programs.nix-ld.enable = true;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Also trim the boot entries to last N generations
  boot.loader.systemd-boot.configurationLimit = 5;
  nix.optimise.automatic = true;

  system.activationScripts.copyWindowsBootloader = {
    deps = [ "specialfs" ];
    text = ''
      if [ ! -d /boot/EFI/Microsoft ]; then
        mkdir -p /mnt/winefi
        mount /dev/nvme1n1p1 /mnt/winefi
        cp -r /mnt/winefi/EFI/Microsoft /boot/EFI/
        umount /mnt/winefi
        rmdir /mnt/winefi
      fi
    '';
  };

  services.displayManager.sddm.wayland.compositorCommand =
    let
      westonIni = pkgs.writeText "weston.ini" ''
        [keyboard]
        keymap_layout=us
        keymap_model=pc104
        keymap_options=terminate:ctrl_alt_bksp
        keymap_variant=

        [libinput]
        enable-tap=true
        left-handed=false

        [output]
        name=DP-5
        mode=2560x1440
        transform=normal

        [output]
        name=DP-4
        mode=off

        [output]
        name=HDMI-A-3
        mode=off
      '';
    in
    "${pkgs.weston}/bin/weston --shell=kiosk -c ${westonIni}";

  programs.xwayland.enable = true;

  services.udisks2.enable = true;

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  programs.niri.enable = true;
  programs.sway.enable = true;
  programs.gamescope.enable = true;
  services.input-remapper.enable = true;

  hardware.keyboard.qmk.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  modules.cider = {
    enable = true;
    pkg = "cider-2";
  };
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.11"; # Did you read the comment?

}
