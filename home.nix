{
  inputs,
  pkgs,
  pkgs-unstable,
  ...
}:

{
  imports = [
    inputs.dms.homeModules.dank-material-shell
    inputs.niri.homeModules.niri
    inputs.danksearch.homeModules.dsearch
  ];
  home.packages = [
    pkgs.atool
    pkgs.httpie
  ];
  programs.bash.enable = true;

  programs.dank-material-shell = {
    enable = true;
    enableSystemMonitoring = true;
    dgop.package = inputs.dgop.packages.${pkgs.system}.default;
    systemd.enable = true;
  };
  programs.dsearch.enable = true;
  home.stateVersion = "25.11";

  services.udiskie = {
    enable = true;
    automount = true;
    notify = true;
    tray = "auto";
    settings = {
      program_options = {
        file_manager = "thunar";
      };
    };
  };

  gtk.iconTheme = {
    name = "Papirus-Dark";
    package = pkgs.papirus-icon-theme;
  };
  programs.neovim = {
    enable = true;
    package = pkgs-unstable.neovim-unwrapped;
    extraLuaPackages =
      ps: with ps; [
        lua-utils-nvim
        nvim-nio
        nui-nvim
        pathlib-nvim
        tree-sitter-norg
      ];
  };

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
  };
}
