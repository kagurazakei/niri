{
  craneLib,
  lib,
  libadwaita,
  mkNiriDerivation,
  pipewire,
  wrapGAppsHook4,
}:
let
  cargoToml = builtins.fromTOML (builtins.readFile ../../../niri-visual-tests/Cargo.toml);
in
mkNiriDerivation {
  pname = cargoToml.package.name;

  src =
    let
      niriVisualTestsFilter =
        path: type: builtins.match ".*niri-source/niri-visual-tests/(resources|src).*" path != null;
      niriFilter = path: type: builtins.match ".*niri-source/(resources|src).*" path != null;
      srcFilter =
        path: type:
        (niriFilter path type)
        || (craneLib.filterCargoSources path type)
        || (niriVisualTestsFilter path type);
    in
    lib.cleanSourceWith {
      src = builtins.path {
        path = ../../../.;
        name = "niri-source";
      };
      filter = srcFilter;
      name = "source";
    };

  nativeBuildInputs = [
    wrapGAppsHook4
  ];

  buildInputs = [
    libadwaita
    pipewire
  ];
}
