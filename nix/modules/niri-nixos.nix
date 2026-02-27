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

    useThunar = mkEnableOption "Use Thunar integration" // {
      default = true;
    };

    withUWSM = mkEnableOption "Enable UWSM support" // {
      default = true;
    };

    withXDG = mkEnableOption "Enable XDG portal support" // {
      default = true;
    };
  };

  config = mkIf cfg.enable (mkMerge [

    {
      nixpkgs.overlays = [ overlay ];

      # Use overlay-provided niri
      programs.niri.package = cfg.package;

      services.displayManager.sessionPackages = [ cfg.package ];

      security.polkit.enable = true;

      programs.dconf.enable = lib.mkDefault true;

      services.gnome.gnome-keyring.enable = lib.mkDefault true;

      services.xserver.desktopManager.runXdgAutostartIfNone = lib.mkDefault true;

      services.dbus.packages = mkIf cfg.useThunar [ pkgs.thunar ];
    }

    (mkIf cfg.withUWSM {
      programs.uwsm = {
        enable = true;
        waylandCompositors = {
          niri = {
            prettyName = "Niri";
            comment = "Scrollable-tiling Wayland compositor";
            binPath = "${cfg.package}/bin/niri-session";
          };
        };
      };
    })

    (mkIf cfg.withXDG {
      xdg.portal = {
        enable = true;

        extraPortals = with pkgs; [
          xdg-desktop-portal-gtk
          xdg-desktop-portal-gnome
        ];

        config = {
          niri = lib.mkDefault {
            default = [
              "gtk"
              "gnome"
            ];

            "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
            "org.freedesktop.impl.portal.Notification" = [ "gtk" ];
            "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
          };
        };
      };
    })

  ]);
}
