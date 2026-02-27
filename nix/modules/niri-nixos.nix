{ overlay }:
{
  pkgs,
  config,
  lib,
  ...
}:

let
  cfg = config.programs.niriBlur;
in
{
  options.programs.niriBlur = {
    enable = lib.mkEnableOption "Custom Niri with overlay";

    withUWSM = lib.mkEnableOption "Enable UWSM support";

    withXDG = lib.mkEnableOption "Enable XDG portal support" // {
      default = true;
    };

    useThunar = lib.mkEnableOption "Use Thunar integration" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {

    # Apply overlay
    nixpkgs.overlays = [ overlay ];

    # Enable upstream Niri module properly
    programs.niri = {
      enable = true;
      package = pkgs.niriPackages.niri;
    };

    services.displayManager.sessionPackages = [
      pkgs.niriPackages.niri
    ];

    services.xserver.desktopManager.runXdgAutostartIfNone = lib.mkDefault true;

    services.dbus.packages = lib.mkIf cfg.useThunar [ pkgs.thunar ];

    security.polkit.enable = true;
    programs.dconf.enable = lib.mkDefault true;
    services.gnome.gnome-keyring.enable = lib.mkDefault true;

    # -------------------------
    # Optional UWSM
    # -------------------------
    programs.uwsm = lib.mkIf cfg.withUWSM {
      enable = true;
      waylandCompositors.niri = {
        prettyName = "Niri The Goat";
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

      config.niri = lib.mkForce {
        default = [
          "gnome"
          "gtk"
        ];
        "org.freedesktop.impl.portal.Access" = [ "gtk" ];
        "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
        "org.freedesktop.impl.portal.Notification" = [ "gtk" ];
        "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
      };
    };
  };
}
