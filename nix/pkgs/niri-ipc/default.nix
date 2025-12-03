{
  craneLib,
  mkNiriDerivation,
}:
let
  cargoToml = builtins.fromTOML (builtins.readFile ../../../niri-ipc/Cargo.toml);
in
mkNiriDerivation {
  pname = cargoToml.package.name;

  src = craneLib.cleanCargoSource ../../../.;
}
