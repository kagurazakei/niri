{
  pkgs,
  config,
  overlay,
  lib,
  ...
}:

let
  cfg = config.programs.niri;
  inherit (lib)
    mkIf
    mkMerge
    mkEnableOption
    mkPackageOption
    ;
in
{
  options.programs.niri = {
    enable = mkEnableOption "Custom Niri with overlay";

    package = mkPackageOption pkgs "niri" { };

    useThunar = mkEnableOption "Nautilus as file chooser" // {
      default = true;
    };

    withUWSM = mkEnableOption "Enable UWSM support";

    withXDG = mkEnableOption "Enable XDG portal support" // {
      default = true;
    };
  };

  config = mkIf cfg.enable (mkMerge [

    {
      nixpkgs.overlays = [ overlay ];

      programs.niri.package = pkgs.niriPackages.niri;

      environment.systemPackages = [
        cfg.package
      ];

      services.dbus.packages = mkIf cfg.useThunar [ pkgs.thunar ];

      services = {
        displayManager.sessionPackages = [ cfg.package ];

        gnome.gnome-keyring.enable = lib.mkDefault true;

        graphical-desktop.enable = true;

        xserver.desktopManager.runXdgAutostartIfNone = lib.mkDefault true;
      };

      security.polkit.enable = true;

      programs.dconf.enable = lib.mkDefault true;

      systemd.packages = [ cfg.package ];
    }

    (mkIf cfg.withUWSM {
      programs.uwsm = {
        enable = true;
        waylandCompositors = {
          niri = {
            prettyName = "Niri The Goat";
            comment = "A scrollable-tiling Wayland compositor";
            binPath = "/run/current-system/sw/bin/niri-session";
          };
        };
      };
    })

    (mkIf cfg.withXDG {
      xdg.portal = {
        enable = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-gnome
          xdg-desktop-portal-gtk
        ];
        config = {
          niri = lib.mkDefault {
            default = [
              "gnome"
              "gtk"
            ];
            "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
            "org.freedesktop.impl.portal.Access" = [ "gtk" ];
            "org.freedesktop.impl.portal.Notification" = [ "gtk" ];
            "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
          };
        };
        configPackages = [ cfg.package ];
      };
    })

  ]);
}
