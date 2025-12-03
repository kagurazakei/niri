{
  craneLib,
  lib,
  mkNiriDerivation,
}:
let
  cargoToml = builtins.fromTOML (builtins.readFile ../../../niri-config/Cargo.toml);
in
mkNiriDerivation {
  pname = cargoToml.package.name;

  src =
    let
      niriFilter = path: type: builtins.match ".*niri-source/resources.*" path != null;
      srcFilter = path: type: (niriFilter path type) || (craneLib.filterCargoSources path type);
    in
    lib.cleanSourceWith {
      src = builtins.path {
        path = ../../../.;
        name = "niri-source";
      };
      filter = srcFilter;
      name = "source";
    };
}
