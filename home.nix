{
  inputs,
  pkgs,
  pkgs-unstable,
  lib,
  config,
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
    pkgs-unstable.neovim-unwrapped
    pkgs.lua5_1
    pkgs.lua51Packages.luarocks
  ];
  programs.bash.enable = true;
  programs.zsh.enable = true;

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
  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };
  programs.eza = {
    enable = true;
    colors = "always";
    enableZshIntegration = true;
    icons = "auto";
  };
  programs.bat = {
    enable = true;
  };

  programs.btop = {
    enable = true;
  };
  programs.tmux = {
    enable = true;
  };

  programs.firefox = {
    enable = true;

    policies = {
      AppAutoUpdate = false;
      BackgroundAppUpdate = false;

      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableTelemetry = true;
      DisableFormHistory = true;
      DisablePasswordReveal = true;
      OfferToSaveLogins = false;
      DontCheckDefaultBrowser = true;
      HardwareAcceleration = true;

      DefaultDownloadDirectory = "${config.home.homeDirectory}/Downloads";
      OverrideFirstRunPage = "";
      OverridePostUpdatePage = "";
      DisplayBookmarksToolbar = "never";

      ExtensionSettings =
        let
          moz = short: "https://addons.mozilla.org/firefox/downloads/latest/${short}/latest.xpi";
        in
        {
          "*".installation_mode = "blocked";

          "uBlock0@raymondhill.net" = {
            install_url = moz "ublock-origin";
            installation_mode = "force_installed";
            updates_disabled = true;
            private_browsing_allowed = true;
          };

          "{d634138d-c276-4fc8-924b-40a0ea21d284}" = {
            install_url = moz "1password-x-password-manager";
            installation_mode = "force_installed";
            updates_disabled = true;
            private_browsing_allowed = true;
          };

        };

      "3rdparty".Extensions = {
        "uBlock0@raymondhill.net".adminSettings = {
          userSettings = rec {
            uiTheme = "dark";
            uiAccentCustom = true;
            uiAccentCustom0 = "#8300ff";
            cloudStorageEnabled = lib.mkForce false;

            importedLists = [
              "https://filters.adtidy.org/extension/ublock/filters/3.txt"
              "https://github.com/DandelionSprout/adfilt/raw/master/LegitimateURLShortener.txt"
            ];

            externalLists = lib.concatStringsSep "\n" importedLists;
          };

          selectedFilterLists = [
            "adguard-generic"
            "adguard-annoyance"
            "adguard-social"
            "adguard-spyware-url"
            "easylist"
            "easyprivacy"
            "https://github.com/DandelionSprout/adfilt/raw/master/LegitimateURLShortener.txt"
            "ublock-abuse"
            "ublock-badware"
            "ublock-filters"
            "ublock-privacy"
            "ublock-quick-fixes"
            "ublock-unbreak"
            "urlhaus-1"
          ];
        };
      };
    };

    profiles.default = {
      search = {
        force = true;
        default = "SearXNG";
        privateDefault = "SearXNG";

        engines = {
          "SearXNG" = {
            urls = [
              {
                template = "https://search.willkelley.com/search";
                params = [
                  {
                    name = "q";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            definedAliases = [ "@s" ];
          };

          "Nix Packages" = {
            urls = [
              {
                template = "https://search.nixos.org/packages";
                params = [
                  {
                    name = "channel";
                    value = "unstable";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@np" ];
          };

          "Nix Options" = {
            urls = [
              {
                template = "https://search.nixos.org/options";
                params = [
                  {
                    name = "channel";
                    value = "unstable";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@no" ];
          };

          "NixOS Wiki" = {
            urls = [
              {
                template = "https://wiki.nixos.org/w/index.php";
                params = [
                  {
                    name = "search";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@nw" ];
          };
        };
      };

      settings = {
        # Disable sponsored/suggested noise
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.newtabpage.activity-stream.feeds.snippets" = false;
        "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;
        "browser.urlbar.suggest.quicksuggest.sponsored" = false;
        "browser.urlbar.suggest.engines" = false;

        # Privacy
        "privacy.donottrackheader.enabled" = true;
        "privacy.globalprivacycontrol.enabled" = true;

        # Hardware acceleration (NVIDIA/Wayland)
        "gfx.webrender.all" = true;
        "media.ffmpeg.vaapi.enabled" = true;

        # Vertical tabs — remove all sidebar tools except extensions + settings
        "sidebar.revamp" = true;
        "sidebar.verticalTabs" = true;
        "sidebar.main.tools" = "";
        "sidebar.visibility" = "expand-on-hover";

        # Bookmarks bar
        "browser.toolbars.bookmarks.visibility" = "never";

        # Address bar — remove shortcuts/top sites
        "browser.urlbar.suggest.topsites" = false;

        # Main menu — remove shortcuts (top sites) and recent browsing (Firefox View)
        "browser.newtabpage.activity-stream.feeds.topsites" = false;
        "browser.firefox-view.enabled" = false;

        # Top toolbar — remove list all tabs button
        "browser.tabs.tabmanager.enabled" = false;

        # Disable AI
        "browser.ml.chat.enabled" = false;
        "browser.ml.chat.sidebar" = false;

        # Skip first-run noise
        "browser.aboutwelcome.enabled" = false;
        "browser.startup.homepage_override.mstone" = "ignore";
      };
    };
  };

}
