{ overlay }:
{
  pkgs,
  config,
  lib,
  ...
}:

let
  cfg = config.programs.niri;
in
{
  options.programs.niri = {
    enable = lib.mkEnableOption "Custom Niri with overlay";

    withUWSM = lib.mkEnableOption "Enable UWSM support";

    withXDG = lib.mkEnableOption "Enable XDG portal support" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {

    # Apply overlay
    nixpkgs.overlays = [ overlay ];

    # Use overlay niri
    programs.niri.package = pkgs.niriPackages.niri;

    # Make session available
    services.displayManager.sessionPackages = [
      pkgs.niriPackages.niri
    ];

    # Required basics
    security.polkit.enable = true;
    programs.dconf.enable = lib.mkDefault true;
    services.gnome.gnome-keyring.enable = lib.mkDefault true;

    # -------------------------
    # Optional UWSM
    # -------------------------
    programs.uwsm = lib.mkIf cfg.withUWSM {
      enable = true;
      waylandCompositors.niri = {
        prettyName = "Niri";
        comment = "Scrollable-tiling Wayland compositor";
        binPath = "${pkgs.niriPackages.niri}/bin/niri-session";
      };
    };

    # -------------------------
    # Optional XDG Portal
    # -------------------------
    xdg.portal = lib.mkIf cfg.withXDG {
      enable = true;

      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-gnome
      ];

      config.niri = lib.mkDefault {
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
}
