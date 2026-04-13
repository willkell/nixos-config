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
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    inputs.dms.nixosModules.greeter
  ];

  # Enable flakes
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

  # networking.hostName = "nixos"; # Define your hostname.

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;
  # Enable sound.
  # services.pulseaudio.enable = true;
  # ORoouts
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;
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
    pkgs-unstable.neovim
    kitty
    fuzzel
    ripgrep
    fd
    kdePackages.sddm
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
    pkgs-unstable.claude-code-bin
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
    greetd
  ];

  # hyprland
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  # services.displayManager.sddm = {
  #   package = pkgs.kdePackages.sddm;
  #   enable = true;
  #   wayland.enable = true;
  #   autoNumlock = true;
  #   # theme = "catppuccin-mocha-mauve";
  #   enableHidpi = true;
  # };
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

  # Force wayland when possible
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Fix disappearing cursor on Hyprland
  environment.sessionVariables.WLR_NO_HARDWARE_CURSORS = "1";

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports for Source Dedicated Server hosting
    # Other general flags if available can be set here.
  };

  # 1password
  # Enables the 1Password CLI
  programs._1password = {
    enable = true;
  };

  # Enables the 1Password desktop app
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "wk" ];
  };

  # keyring for 1password
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;
  security.pam.services.sddm.enableGnomeKeyring = true;

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

  # Optional: If you encounter amdgpu issues with newer kernels (e.g., 6.10+ reported issues),
  # you might consider using the LTS kernel or a known stable version.
  # boot.kernelPackages = pkgs.linuxPackages_lts; # Example for LTS
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.11"; # Did you read the comment?

}
